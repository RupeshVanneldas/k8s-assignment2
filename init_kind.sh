#!/bin/bash
set -ex # Exit immediately if a command exits with a non-zero status

# Check if /usr/local/bin is in PATH
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    echo "/usr/local/bin is not in PATH, adding it."
    export PATH=$PATH:/usr/local/bin
fi

# Download kind
curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/

# Download kubectl
curl -LO https://dl.k8s.io/release/v1.29.13/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/

# Verify installation of kind and kubectl
kind version
kubectl version --client

# Create a Kind cluster
kind create cluster --config kind.yaml
