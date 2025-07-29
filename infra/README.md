# Terraform EC2 Docker Project

This project provides a Terraform configuration to deploy an EC2 instance on AWS that runs a Docker container from an existing image on Docker Hub.

## Prerequisites

- An AWS account
- Terraform installed on your local machine
- AWS CLI configured with your credentials

## Project Structure

```
terraform-ec2-docker
├── main.tf                # Main Terraform configuration
├── variables.tf           # Input variables for Terraform
├── outputs.tf             # Output values after deployment
├── terraform.tfvars.example # Example variables file
├── user-data.sh           # User data script to install Docker
└── README.md              # Project documentation
```

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone <repository-url>
   cd terraform-ec2-docker
   ```

2. **Configure your variables:**

   Copy the `terraform.tfvars.example` to `terraform.tfvars` and update the values as needed.

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Initialize Terraform:**

   Run the following command to initialize the Terraform configuration:

   ```bash
   terraform init
   ```

4. **Plan the deployment:**

   Generate an execution plan to see what actions Terraform will take:

   ```bash
   terraform plan
   ```

5. **Apply the configuration:**

   Deploy the EC2 instance by applying the configuration:

   ```bash
   terraform apply
   ```

   Confirm the action when prompted.

6. **Access your EC2 instance:**

   After deployment, Terraform will output the public IP address of the EC2 instance. You can SSH into the instance using:

   ```bash
   ssh -i <your-key.pem> ec2-user@<public-ip>
   ```

## Cleaning Up

To remove the resources created by Terraform, run:

```bash
terraform destroy
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.