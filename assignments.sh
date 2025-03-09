# Author: Rupesh Vanneldas
# Date: 08/03/2025
# Description: This script is used to deploy a simple web application with MySQL database in a Kubernetes cluster using kind.
# Note: This script is tested on Windows 10 with WSL2 and Amazon Linux 2 EC2 instance. For run this script you need to have kind and kubectl installed on your machine (Hint: You can check init_kind.sh script to install kind and kubectl on your machine).

# Create a kind cluster with the provided kind.yaml file for that do the following:
chmod +x ./init_kind.sh
./init_kind.sh

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
kubectl apply -f mysql/pod.yaml
kubectl apply -f mysql/service.yaml
kubectl get pods --all-namespaces # You should see the mysql pod running
kubectl get svc --all-namespaces # You should see the mysql service running

# Second Web
kubectl create namespace web-ns
kubectl apply -f web/pod.yaml
kubectl apply -f web/service.yaml
kubectl get pods --all-namespaces # You should see both web and mysql pod running
kubectl get svc --all-namespaces # You should see both web and mysql service running

# To access the web pod, you can port-forward the web pod to your local machine:
kubectl port-forward -n web-ns pod/web-pod 8080:8080
# Do http://localhost:8080/ in a browser to see the web page or "curl http://localhost:8080/" in a seperate terminal

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

# Update the Web Application
# Tag a new version of your web app image (e.g., v2) and push it to the registry:
# Update web/deployment.yaml to image tag and APP_COLOR=pink and apply the update:
# ...
#       - name: web
#         image: rupeshvanneldas27/my_app:v2
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