# Kubernetes Deployment with Kind

## Author: Rupesh Vanneldas  
**Date:** 08/03/2025  

## Description
This project deploys a simple web application with a MySQL database in a Kubernetes cluster using Kind. The setup is tested on Windows 11 with WSL2 and Amazon Linux 2 EC2 instance. 

**Note:** For Windows users, several commands are not supported in Windows Command Prompt, so execution should be done in WSL2 or a Linux-based OS. Check out the assignment.sh file for a more personalized and in-depth approach from me or if you face any errors or are confused about any command.

---

## Prerequisites
- `kind` and `kubectl` installed.
- AWS CLI installed and configured with necessary permissions.
- SSH key pair for accessing the EC2 instance.

## Infrastructure Deployment

1. Clone the repository:
   ```sh
   git clone https://github.com/RupeshVanneldas/docker-assignment1.git
   ```
2. Navigate to Terraform directory:
   ```sh
   cd terraform-code
   ```
3. Generate SSH key pair:
   ```sh
   ssh-keygen -t rsa -f ass1-prod -q -N ""
   ```
4. Update `variables.tf` with the key name.
5. Configure an S3 bucket for Terraform state in `config.tf`.
6. Initialize and apply Terraform:
   ```sh
   terraform init
   terraform validate
   terraform plan
   terraform apply -auto-approve
   ```
7. Retrieve the EC2 instance public IP and SSH into it:
   ```sh
   chmod 400 ass1-prod
   ssh -i ass1-prod ec2-user@<EC2-Instance-IP>
   ```
8. Run the GitHub Workflow of Assignment 1 Repo to build and push the Docker images to ECR from your local machine

---

## Setting Up AWS CLI for ECR

1. Configure AWS credentials:
   ```sh
   vi ~/.aws/credentials   # Add AWS credentials
   vi ~/.aws/config        # Add AWS region
   ```
2. Authenticate Docker with ECR:
   ```sh
   aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>
   ```
3. Verify ECR access:
   ```sh
   aws ecr list-images --repository-name <ECR_REPO_NAME> --region <AWS_REGION>
   ```

---

## Kubernetes Cluster Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/RupeshVanneldas/k8s-assignment2.git
   ```
2. Navigate to the directory:
   ```sh
   cd k8s-assignment2
   ```
3. Create the Kind cluster:
   ```sh
   chmod +x ./init_kind.sh
   ./init_kind.sh
   ```
4. Add `/usr/local/bin` to PATH if necessary:
   ```sh
   echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
   source ~/.bashrc
   ```

### Windows Specific Steps:
For Windows users, install Kind and kubectl manually:
1. Download `kind.exe`:
   ```sh
   curl -Lo ./kind.exe https://kind.sigs.k8s.io/dl/v0.26.0/kind-windows-amd64
   ```
2. Move `kind.exe` to a suitable location and add it to the PATH environment variable.
3. Download `kubectl.exe`:
   ```sh
   curl -LO https://dl.k8s.io/release/v1.29.13/bin/windows/amd64/kubectl.exe
   ```
4. Move `kubectl.exe` to a suitable location and add it to the PATH environment variable.
5. Restart the terminal and verify installations:
   ```sh
   kind version
   kubectl version --client
   ```

---

## Deploying the Application

### MySQL Deployment
1. Create a namespace:
   ```sh
   kubectl create namespace mysql-ns
   ```
2. Create an ECR secret:
   ```sh
   aws ecr get-login-password --region <AWS_REGION> | kubectl create secret docker-registry ecr-secret \
     --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \
     --docker-username=AWS \
     --docker-password=$(aws ecr get-login-password --region <AWS_REGION>) \
     --namespace=mysql-ns
   ```
3. Apply MySQL resources:
   ```sh
   kubectl apply -f mysql/pod.yaml
   kubectl apply -f mysql/service.yaml
   ```
4. Verify MySQL deployment:
   ```sh
   kubectl get pods -n mysql-ns
   kubectl get svc -n mysql-ns
   ```

### Web Application Deployment
1. Create a namespace:
   ```sh
   kubectl create namespace web-ns
   ```
2. Create an ECR secret:
   ```sh
   aws ecr get-login-password --region <AWS_REGION> | kubectl create secret docker-registry ecr-secret \
     --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \
     --docker-username=AWS \
     --docker-password=$(aws ecr get-login-password --region <AWS_REGION>) \
     --namespace=web-ns
   ```
3. Apply web resources:
   ```sh
   kubectl apply -f web/pod.yaml
   kubectl apply -f web/service.yaml
   ```
4. Verify web deployment:
   ```sh
   kubectl get pods -n web-ns
   kubectl get svc -n web-ns
   ```

---

## Rolling Updates

1. Update `web/deployment.yaml` to new image version:
   ```yaml
   image: <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_app_v2
   env:
   - name: APP_COLOR
     value: "pink"
   ```
2. Apply the update:
   ```sh
   kubectl apply -f web/deployment.yaml
   ```
3. Verify the rollout:
   ```sh
   kubectl rollout status deployment/web-deployment -n web-ns
   kubectl get pods -n web-ns
   ```
4. Test the updated application:
   ```sh
   curl http://localhost:30000/
   ```

---

## Debugging and Troubleshooting
- Check logs:
  ```sh
  kubectl logs -n web-ns pod/web-pod
  ```
- Scale replicas:
  ```sh
  kubectl scale --replicas=6 rs/web-rs -n web-ns
  ```
- Verify services:
  ```sh
  kubectl get svc -A
  ```

---

## Conclusion
This deployment project provided hands-on experience with Kubernetes using Kind, including cluster setup, application deployment, service exposure, and rolling updates. Troubleshooting encountered issues helped deepen understanding of container orchestration.

---

## References
- [AWS Workshop](https://catalog.us-east-1.prod.workshops.aws/)
- [YouTube Tutorial 1](https://youtu.be/TlHvYWVUZyc?si=7eAOx1YnsiE1V-j1)
- [YouTube Tutorial 2](https://youtu.be/XuSQU5Grv1g?si=kIGAuRwkGP8-nGoK)
- [AWS ECS Documentation](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html)