# Author: Rupesh Vanneldas
# Date: 08/03/2025
# Description: This script is used to deploy a simple web application with MySQL database in a Kubernetes cluster using kind.

# Note: This script is tested on Windows 11 with WSL2 and Amazon Linux 2 EC2 instance. For run this script you need to have kind and kubectl installed on your machine. For windows there are several commands that are not supported in Windows Command Prompt, so you need to run this script in WSL2 or Linux based OS.

# First we will start with provisioning the EC2 instance and then we will deploy the web application with MySQL database in a Kubernetes cluster using kind. For that we will clone the repository of Assignment 1 and navigate to the directory.

git clone https://github.com/RupeshVanneldas/docker-assignment1.git

cd terraform-code
ssh-keygen -t rsa -f ass1-prod -q -N ""

# Update the key_name in the variables.tf file
# Configure S3 bucket for storing terraform state in config.tf file

terraform init
terraform validate
terraform plan
terraform apply -auto-approve
# Get the public IP of the EC2 instance and SSH into the EC2 instance from your local machine
# For example:
chmod 400 ass1-prod
ssh -i ass1-prod ec2-user@<EC2-Instance-IP>

# Run the GitHub Workflow to build and push the Docker images to ECR
# For that you need to have AWS CLI installed on your EC2 instance and you need to have the AWS credentials configured on the EC2 instance.

# After SSH into the EC2 instance (you can try this in your local machine as well) do the following to test if the AWS CLI is installed and configured and you have the necessary permissions to access the ECR:

# For windows make sure you have the AWS CLI installed and configured on your local machine and you have the necessary permissions to access the ECR.

vi ~/.aws/credentials # Add your AWS credentials
vi ~/.aws/config # Add your AWS region

aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>
aws ecr list-images --repository-name <ECR_REPO_NAME> --region <AWS_REGION> 

# Clone the repository inside EC2 instance or Local machine and navigate to the directory
git clone https://github.com/RupeshVanneldas/k8s-assignment2.git

# For EC2 instance do the following:
# Create a kind cluster with the provided kind.yaml file for that do the following:
cd k8s-assignment2
chmod +x ./init_kind.sh
./init_kind.sh

# Add /usr/local/bin to PATH if not already added
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

# For windows use the following command to download kind.exe
curl -Lo ./kind.exe https://kind.sigs.k8s.io/dl/v0.26.0/kind-windows-amd64
# Mone kind.exe to different location and add it to PATH environment variable.
# For windows you can use the following command to download kubectl.exe
curl -LO https://dl.k8s.io/release/v1.29.13/bin/windows/amd64/kubectl.exe
# Move kubectl.exe to different location and add it to PATH environment variable.
# Restart the terminal and check kind version and kubectl version

# Check the version of kind and kubectl
kind version
kubectl version --client

# Verify the cluster
kubectl cluster-info --context kind-kind
# For example my Kubernetes control plane is running at https://127.0.0.1:52706
kubectl get nodes

# After creating folders and file structure now we will start with the namespaces respectively.
# You can now deploy them as pods in the cluster one by one: 

# First MySQL
kubectl create namespace mysql-ns
aws ecr get-login-password --region <AWS_REGION> | kubectl create secret docker-registry ecr-secret \
  --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region <AWS_REGION>) \
  --namespace=mysql-ns

# First edit the image_name and db_password in the all files in mysql folder
# Apply the pod and service yaml files
kubectl apply -f mysql/pod.yaml
kubectl apply -f mysql/service.yaml
kubectl get pods --all-namespaces # You should see the mysql pod running
kubectl get svc --all-namespaces # You should see the mysql service running

# Second Web, repeat the same steps for web pod and service as well but in web folder
kubectl create namespace web-ns
aws ecr get-login-password --region <AWS_REGION> | kubectl create secret docker-registry ecr-secret \
  --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region <AWS_REGION>) \
  --namespace=web-ns
kubectl apply -f web/pod.yaml
kubectl apply -f web/service.yaml
kubectl get pods --all-namespaces # You should see both web and mysql pod running
kubectl get svc --all-namespaces # You should see both web and mysql service running

# Wait for some time

# To access the web pod, you can port-forward the web pod to your local machine (Completely optional): 
kubectl port-forward -n web-ns pod/web-pod 8080:8080
# Do http://localhost:8080/ in a browser to see the web page or "curl http://localhost:8080/" in a seperate terminal
# For EC2 instance you can use Public IP of the EC2 instance and port 8080

# If it's not working check logs of the web pod:
kubectl logs -n web-ns pod/web-pod

# If it works, start deploying replica sets and services for both MySQL and Web pods
kubectl apply -f mysql/replicaset.yaml
kubectl apply -f web/replicaset.yaml
# Verify by:
kubectl get rs -n mysql-ns
kubectl get rs -n web-ns    
# To scale the replicas of the web pod (Completely optional):
kubectl scale --replicas=6 rs/web-rs -n web-ns
kubectl get rs -n web-ns

# Deploy Deployments:
kubectl apply -f mysql/deployment.yaml
kubectl apply -f web/deployment.yaml
# Verify by:
kubectl get deployment -n mysql-ns
kubectl get deployment -n web-ns

# Do http://localhost:30000/ in a browser to see the web page or "curl http://localhost:30000/" in a seperate terminal
# For EC2 instance you can use Public IP of the EC2 instance and port 30000

# Update the Web Application
# Tag a new version of your web app image (e.g., v2) and push it to the registry:
# Update web/deployment.yaml to image tag and APP_COLOR=pink and apply the update:

# ...
#       - name: web
#         image: <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_app_v2
#         env:
#         - name: APP_COLOR
#           value: "pink"
# ...

# Apply the update:
kubectl apply -f web/deployment.yaml

# Verify the rollout:
kubectl rollout status deployment/web-deployment -n web-ns
kubectl get pods -n web-ns

# Test again with curl or browser to confirm the new version (e.g., color change).

# Clean up
# Delete the resources:
kubectl delete ns mysql-ns
kubectl delete ns web-ns
# Delete the kind cluster:
kind delete cluster --name kind
# Delete the EC2 instance and other resources created by Terraform:
terraform destroy -auto-approve
# Delete the repository:
cd ..
rm -rf docker-assignment1
rm -rf k8s-assignment2
rm -rf terraform-code
# Done!