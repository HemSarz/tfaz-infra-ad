Write-Host "Deleting backend.tf file..."
Remove-Item -Path "backend.tf" -Force

Write-Host "Deleting Azure resource groups..."
az group delete --name networkwatcherrg --yes
az group delete --name tfaz-rg-aad --yes

Start-Sleep -Seconds 2

Write-Host "Initializing Terraform..."
terraform init

Start-Sleep -Seconds 2

Write-Host "Destroying infrastructure..."
terraform destroy --auto-approve