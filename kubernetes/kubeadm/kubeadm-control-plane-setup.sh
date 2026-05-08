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
POD_NETWORK_CIDR="192.168.0.0/16"
CONTROL_PLANE_IP="172.31.89.68"
CONTROL_PLANE_NAME="control-plane"
CALICO_VERSION="3.28.0"

############################################################
# Configure Hostname
############################################################
echo "[INFO] Setting hostname..."
sudo hostnamectl set-hostname "${CONTROL_PLANE_NAME}"
echo "${CONTROL_PLANE_IP} ${CONTROL_PLANE_NAME}" | \
sudo tee -a /etc/hosts

############################################################
# 1. Initialize Kubernetes Control Plane
############################################################
echo "[INFO] Initializing Kubernetes control plane..."
sudo kubeadm init \
--pod-network-cidr=${POD_NETWORK_CIDR} \
--apiserver-advertise-address=${CONTROL_PLANE_IP} \
--node-name ${CONTROL_PLANE_NAME}

############################################################
# 2. Configure kubectl Access
############################################################
echo "[INFO] Configuring kubectl access..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

############################################################
# 3. Install Calico Network Plugin
# Calico provides Kubernetes pod networking
############################################################
echo "[INFO] Installing Calico network plugin..."
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml
curl -LO https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml 
sed -i "s#192.168.0.0/16#${POD_NETWORK_CIDR}#g" custom-resources.yaml
kubectl apply -f custom-resources.yaml

# Restart Container Runtime and Kubelet
# Reload CNI configuration after Calico installation
echo "[INFO] Restarting containerd and kubelet..."
sudo systemctl restart containerd
sudo systemctl restart kubelet

############################################################
# 4. Generate Worker Node Join Command
############################################################
echo "[INFO] Generating worker node join command..."
echo '#!/bin/bash' > join-command.sh
kubeadm token create --print-join-command | tee -a join-command.sh >/dev/null
chmod +x join-command.sh

############################################################
# Verify Cluster Status
############################################################
echo "[INFO] Verifying Kubernetes cluster status..."
kubectl get nodes
kubectl get pods -A

############################################################
# Completed
############################################################
echo "[INFO] Kubernetes control plane setup completed successfully."
echo "[INFO] Worker join command saved to: join-command.sh"

