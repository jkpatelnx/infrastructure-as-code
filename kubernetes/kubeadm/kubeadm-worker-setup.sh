#!/bin/bash

set -e

# Prevent Running Script as Root
if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] Do not run this script as root or with sudo."
    echo "[INFO] Run the script as a normal user."
    exit 1
fi

############################################################
# Variables
############################################################

read -p "Enter Worker Hostname serial [01]: " HOST_SERIAL
HOST_NAME="worker-${HOST_SERIAL:-01}"

read -p "Enter Control Plane IP: " CONTROL_PLANE_IP
read -p "Enter kubeadm Token: " TOKEN
read -p "Enter Discovery Token CA Cert Hash: " DISCOVERY_TOKEN_CA_CERT_HASH

#CONTROL_PLANE_IP="192.168.10.102"
#TOKEN="<token>"
#DISCOVERY_TOKEN_CA_CERT_HASH="<hash>"

############################################################
# Configure Hostname
############################################################
echo "[INFO] Setting hostname..."
sudo hostnamectl set-hostname "${HOST_NAME}"

############################################################
# Reset Existing Kubernetes State
############################################################
if [ -d /etc/kubernetes ]; then
    echo "[INFO] Existing Kubernetes state detected. Resetting node..."
    sudo kubeadm reset -f
    sudo rm -rf /etc/cni/net.d
    sudo rm -rf /var/lib/cni
    sudo rm -rf /var/lib/kubelet
    sudo systemctl restart containerd
    sudo systemctl restart kubelet
fi

############################################################
# Perform pre-flight checks
############################################################
sudo kubeadm reset pre-flight checks

############################################################
# Join Kubernetes Cluster
############################################################
echo "[INFO] Joining Kubernetes cluster..."
sudo kubeadm join ${CONTROL_PLANE_IP}:6443 \
--token ${TOKEN} \
--discovery-token-ca-cert-hash ${DISCOVERY_TOKEN_CA_CERT_HASH} \
--cri-socket unix:///run/containerd/containerd.sock \
--v=5

