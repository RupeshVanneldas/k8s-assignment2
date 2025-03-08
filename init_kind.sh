#!/bin/bash
set -ex
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
# local-windows: curl -Lo ./kind.exe https://kind.sigs.k8s.io/dl/v0.26.0/kind-windows-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
# local-windows: Move kind.exe to C:\Program Files\kind\kind.exe and set PATH environment variable
curl -LO https://dl.k8s.io/release/v1.29.13/bin/linux/amd64/kubectl
# local-windows: curl -LO https://dl.k8s.io/release/v1.29.13/bin/windows/amd64/kubectl.exe
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
# local-windows: Move kubectl.exe to C:\Program Files\Kubernetes\kubectl.exe and set PATH environment variable
# local-windows: Restart the shell/terminal and check the version of kind and kubectl
kind version
kubectl version --client

# Create a kind cluster
kind create cluster --config kind.yaml
# Verify the cluster
kubectl cluster-info --context kind-kind
# For example my Kubernetes control plane is running at https://127.0.0.1:52706
kubectl get nodes # You should see one node running