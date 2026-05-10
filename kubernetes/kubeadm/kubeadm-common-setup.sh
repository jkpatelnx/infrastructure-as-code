#!/bin/bash

set -e

# Prevent Running Script as Root
if [[ $EUID -eq 0 ]]; then
    echo "[ERROR] Do not run this script as root or with sudo."
    echo "[INFO] Run the script as a normal user."
    exit 1
fi

############################################################
# Component Versions
############################################################
CONTAINERD_VERSION="1.7.14"
RUNC_VERSION="1.1.12"
CNI_VERSION="1.5.0"
KUBERNETES_VERSION="1.30.1-1.1"
KUBERNETES_REPO_VERSION="1.30"

############################################################
# 1.
# Disable Swap
# Kubernetes requires swap to be disabled
############################################################
echo "[INFO] Disabling swap..."
sudo swapoff -a
# Disable swap permanently across reboots
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sleep 2

############################################################
# 2.
# Load Required Kernel Modules
# Required for Kubernetes networking and container runtime
############################################################
echo "[INFO] Loading kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
# Load modules immediately without reboot
sudo modprobe overlay
sudo modprobe br_netfilter
sleep 2

############################################################
# 3.
# Configure Sysctl Kernel Parameters
# Required for Kubernetes networking
############################################################
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
# Apply sysctl settings immediately
sudo sysctl --system
sleep 2
# Verify Kernel Modules
echo "[INFO] Verifying loaded kernel modules..."
lsmod | grep br_netfilter
lsmod | grep overlay
# Verify Sysctl Parameters
echo "[INFO] Verifying sysctl configuration..."
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward
echo "[INFO] Kubernetes node prerequisites configured successfully."


############################################################
# 4. 
# Install and Configure Containerd Runtime
# Containerd is required as the Kubernetes container runtime
############################################################
echo "[INFO] Installing containerd runtime version ${CONTAINERD_VERSION}..."
curl -LO https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mkdir -p /usr/local/lib/systemd/system/
sudo mv containerd.service /usr/local/lib/systemd/system/
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sleep 2

# Verify Containerd Service Status
echo "[INFO] Verifying containerd service status..."
sudo systemctl is-active containerd
# Troubleshooting:
# sudo systemctl status containerd --no-pager


############################################################
# 5. 
# Install runc
# runc is the low-level OCI container runtime required by containerd
############################################################
echo "[INFO] Installing runc version ${RUNC_VERSION}..."
curl -LO https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
runc --version


############################################################
# 6. 
# Install CNI Plugins
# Required for Kubernetes pod networking
############################################################
echo "[INFO] Installing CNI plugins version ${CNI_VERSION}..."
curl -LO https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${CNI_VERSION}.tgz


############################################################
# 7. 
# Install Kubernetes Components
# Install kubeadm, kubelet and kubectl
############################################################
echo "[INFO] Installing Kubernetes version ${KUBERNETES_VERSION}..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_REPO_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_REPO_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

sudo apt-get install -y \
kubelet=${KUBERNETES_VERSION} \
kubeadm=${KUBERNETES_VERSION} \
kubectl=${KUBERNETES_VERSION} \
--allow-downgrades \
--allow-change-held-packages

sudo apt-mark hold kubelet kubeadm kubectl
kubeadm version
kubelet --version
kubectl version --client


############################################################
# 8.
# Configure crictl
# Configure crictl to use containerd runtime
############################################################
echo "[INFO] Configuring crictl runtime endpoint..."
sudo crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock


############################################################
# Completed
############################################################
echo "Kubernetes setup completed."