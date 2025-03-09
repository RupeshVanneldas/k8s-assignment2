#!/bin/bash
set -ex # Exit immediately if a command exits with a non-zero status
curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
# local-windows: curl -Lo ./kind.exe https://kind.sigs.k8s.io/dl/v0.26.0/kind-windows-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/
# local-windows: Move kind.exe to C:\Program Files\kind\kind.exe and set PATH environment variable
curl -LO https://dl.k8s.io/release/v1.29.13/bin/linux/amd64/kubectl
# local-windows: curl -LO https://dl.k8s.io/release/v1.29.13/bin/windows/amd64/kubectl.exe
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
# local-windows: Move kubectl.exe to C:\Program Files\Kubernetes\kubectl.exe and set PATH environment variable for both kind and kubectl.
# local-windows: Restart the shell/terminal and check the version of kind and kubectl
kind create cluster --config kind.yaml