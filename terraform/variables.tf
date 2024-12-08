# variables.tf


variable "name" {
  type = string
  default = "akscluster"
}

variable "resource_group_name" {
  type = string
  default = "tp4devopsgrp"
}

variable "location" {
  type = string
  default = "northeurope"
}

variable "node_count" {
  type = string
  default = 1
}

  variable "k8s_version" {
    type = string
    default = "1.28.5"
  }