pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = "yasminegharbi/flask-docker-app"
        DOCKER_IMAGE_TAG = "latest"
        NAMESPACE = "default"
        DEPLOYMENT_NAME = "flask-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/GHARBIyasmine/Flask-App-deployment-on-AKS-terraform.git', branch: 'main'
            }
        }

        stage('Setup Terraform') {
            steps {
                script {
                    def terraformPath = tool name: 'terraform'
                    env.PATH = "${terraformPath}:${env.PATH}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_hub_cred', passwordVariable: 'DOCKER_HUB_CREDENTIALS_PSW', usernameVariable: 'DOCKER_HUB_CREDENTIALS_USR')]) {
                        sh "echo \$DOCKER_HUB_CREDENTIALS_PSW | docker login -u \$DOCKER_HUB_CREDENTIALS_USR --password-stdin"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        sh "docker logout" // Clean up Docker login
                    }
                }
            }
        }

        stage('Create AKS Resources with Terraform') {
            steps {
                dir('terraform') {
                    script {
                        withCredentials([azureServicePrincipal('AZURE_CREDENTIALS')]) {
                            sh '''
                            export ARM_CLIENT_ID=$AZURE_CLIENT_ID
                            export ARM_CLIENT_SECRET=$AZURE_CLIENT_SECRET
                            export ARM_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID
                            export ARM_TENANT_ID=$AZURE_TENANT_ID



                            az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID
                            chmod +x check_resources.sh

                            terraform init 
                            terraform plan 
                            terraform apply -auto-approve 
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy Application to AKS') {
            steps {
                script {
                    withCredentials([azureServicePrincipal('AZURE_CREDENTIALS')]) {
                        sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET -t $AZURE_TENANT_ID'

                        dir('terraform') {
                            def resourceGroup = sh(script: 'terraform output -raw resource_group_name', returnStdout: true).trim()
                            def aksCluster = sh(script: 'terraform output -raw aks_cluster_name', returnStdout: true).trim()

                            sh """
                            az aks get-credentials --resource-group ${resourceGroup} --name ${aksCluster} --overwrite-existing
                            """
                        }

                        dir('kubernetes') {
                            sh '''
                            # Check if the deployment exists
                                if kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
                                    kubectl apply -f manifest.yaml
                                    echo "Deployment '$DEPLOYMENT_NAME' exists. Restarting rollout..."
                                    kubectl rollout restart deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
                                else
                                    echo "Deployment '$DEPLOYMENT_NAME' does not exist. Applying manifest for the first time..."
                                    kubectl apply -f manifest.yaml
                                fi
                            '''
                        }

                        sh 'az logout'
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Cleaning up workspace..."
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for more details.'
        }
    }
}
