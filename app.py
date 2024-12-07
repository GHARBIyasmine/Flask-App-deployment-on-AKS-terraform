from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def hello_geek():
    name = request.args.get('name', 'Geek')  # Default to 'Geek' if no name is provided
    return render_template('index.html', name=name)

if __name__ == "__main__":
    app.run(debug=True)