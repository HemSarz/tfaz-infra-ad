#!/bin/bash

# Run `terraform init` to initialize the backend
terraform init

# Run `terraform apply` to create or modify the infrastructure
terraform apply -auto-approve
