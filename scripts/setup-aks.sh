#!/bin/bash

################################################################################
# AKS Cluster Setup Script
################################################################################
# This script creates and configures an Azure Kubernetes Service (AKS) cluster
# with production-ready settings including:
# - Multiple node pools (system and user)
# - Azure CNI networking
# - Azure AD integration
# - Monitoring and logging
# - Auto-scaling
#
# Author: Atul Kamble
# Version: 1.0.0
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration variables
# Update these values according to your requirements
RESOURCE_GROUP="${RESOURCE_GROUP:-aks}"
LOCATION="${LOCATION:-eastus}"
CLUSTER_NAME="${CLUSTER_NAME:-mycluster}"
ACR_NAME="${ACR_NAME:-atulkamble}"
K8S_VERSION="${K8S_VERSION:-1.28.3}"

# Node pool configuration
SYSTEM_NODE_COUNT="${SYSTEM_NODE_COUNT:-3}"
SYSTEM_NODE_SIZE="${SYSTEM_NODE_SIZE:-Standard_D2s_v3}"
USER_NODE_COUNT="${USER_NODE_COUNT:-3}"
USER_NODE_SIZE="${USER_NODE_SIZE:-Standard_D4s_v3}"

# Network configuration
VNET_NAME="${VNET_NAME:-aks-vnet}"
VNET_ADDRESS_PREFIX="${VNET_ADDRESS_PREFIX:-10.0.0.0/8}"
AKS_SUBNET_NAME="${AKS_SUBNET_NAME:-aks-subnet}"
AKS_SUBNET_PREFIX="${AKS_SUBNET_PREFIX:-10.240.0.0/16}"

log_info "Starting AKS cluster setup..."
log_info "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  ACR Name: $ACR_NAME"
echo "  Kubernetes Version: $K8S_VERSION"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    log_error "Azure CLI is not installed. Please install it first."
    log_info "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

log_success "Azure CLI found"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    log_error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

log_success "Azure authentication verified"

# Create resource group
log_info "Creating resource group: $RESOURCE_GROUP"
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags "Environment=Production" "Project=AKS-Demo" "ManagedBy=Script"

log_success "Resource group created"

# Create virtual network and subnet
log_info "Creating virtual network: $VNET_NAME"
az network vnet create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VNET_NAME" \
    --address-prefixes "$VNET_ADDRESS_PREFIX" \
    --subnet-name "$AKS_SUBNET_NAME" \
    --subnet-prefix "$AKS_SUBNET_PREFIX"

log_success "Virtual network created"

# Get subnet ID
SUBNET_ID=$(az network vnet subnet show \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET_NAME" \
    --name "$AKS_SUBNET_NAME" \
    --query id -o tsv)

log_info "Subnet ID: $SUBNET_ID"

# Create Azure Container Registry
log_info "Creating Azure Container Registry: $ACR_NAME"
az acr create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$ACR_NAME" \
    --sku Standard \
    --admin-enabled true

log_success "Azure Container Registry created"

# Create AKS cluster
log_info "Creating AKS cluster: $CLUSTER_NAME (this may take 10-15 minutes)"
az aks create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --kubernetes-version "$K8S_VERSION" \
    --location "$LOCATION" \
    --node-count "$SYSTEM_NODE_COUNT" \
    --node-vm-size "$SYSTEM_NODE_SIZE" \
    --nodepool-name systempool \
    --nodepool-labels nodepool-type=system nodepoolos=linux \
    --network-plugin azure \
    --vnet-subnet-id "$SUBNET_ID" \
    --service-cidr 10.2.0.0/24 \
    --dns-service-ip 10.2.0.10 \
    --enable-managed-identity \
    --enable-addons monitoring \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 5 \
    --max-pods 110 \
    --vm-set-type VirtualMachineScaleSets \
    --load-balancer-sku standard \
    --network-policy azure \
    --generate-ssh-keys \
    --attach-acr "$ACR_NAME" \
    --tags "Environment=Production" "Project=AKS-Demo"

log_success "AKS cluster created"

# Add user node pool
log_info "Adding user node pool"
az aks nodepool add \
    --resource-group "$RESOURCE_GROUP" \
    --cluster-name "$CLUSTER_NAME" \
    --name userpool \
    --node-count "$USER_NODE_COUNT" \
    --node-vm-size "$USER_NODE_SIZE" \
    --node-taints CriticalAddonsOnly=true:NoSchedule \
    --labels nodepool-type=user nodepoolos=linux \
    --enable-cluster-autoscaler \
    --min-count 2 \
    --max-count 10 \
    --max-pods 110

log_success "User node pool added"

# Get AKS credentials
log_info "Getting AKS credentials"
az aks get-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --overwrite-existing

log_success "Credentials configured"

# Verify cluster access
log_info "Verifying cluster access"
kubectl get nodes

log_success "Cluster is accessible"

# Install NGINX Ingress Controller
log_info "Installing NGINX Ingress Controller"
kubectl create namespace ingress-nginx --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

log_success "NGINX Ingress Controller installed"

# Wait for ingress controller to be ready
log_info "Waiting for ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

log_success "Ingress controller is ready"

# Get ingress external IP
log_info "Getting ingress external IP (this may take a few minutes)..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
    echo -n "."
    EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    sleep 10
done
echo ""
log_success "Ingress external IP: $EXTERNAL_IP"

# Display cluster information
log_success "AKS cluster setup completed successfully!"
echo ""
echo "======================================================================"
echo "Cluster Information:"
echo "======================================================================"
echo "Resource Group: $RESOURCE_GROUP"
echo "Cluster Name: $CLUSTER_NAME"
echo "ACR Name: $ACR_NAME"
echo "Ingress External IP: $EXTERNAL_IP"
echo "Kubernetes Version: $K8S_VERSION"
echo ""
echo "Next Steps:"
echo "1. Update your DNS records to point to: $EXTERNAL_IP"
echo "2. Build and push your Docker images to ACR"
echo "3. Deploy your applications using kubectl"
echo ""
echo "Useful Commands:"
echo "  kubectl get nodes              # View cluster nodes"
echo "  kubectl get pods -A            # View all pods"
echo "  kubectl get svc -A             # View all services"
echo "  az aks browse --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME"
echo "======================================================================"
