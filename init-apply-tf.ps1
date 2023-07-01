Write-Host "Initializing the backend..."
terraform init -input=false
Write-Host "Creating or modifying the infrastructure | Add backend"
terraform apply -auto-approve