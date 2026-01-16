#!/bin/bash

################################################################################
# Kubernetes Deployment Script
################################################################################
# This script deploys the application to AKS cluster
# Applies all Kubernetes manifests in the correct order
#
# Author: Atul Kamble
# Version: 1.0.0
################################################################################

set -e  # Exit on error

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

# Configuration
NAMESPACE="${NAMESPACE:-default}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
K8S_DIR="$PROJECT_ROOT/k8s"

log_info "Kubernetes Deployment Script"
log_info "Namespace: $NAMESPACE"
log_info "Kubernetes manifests directory: $K8S_DIR"
echo ""

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed. Please install it first."
    exit 1
fi

log_success "kubectl found"

# Check cluster connectivity
log_info "Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

log_success "Connected to cluster"

# Display current context
CURRENT_CONTEXT=$(kubectl config current-context)
log_info "Current context: $CURRENT_CONTEXT"

# Create namespace if it doesn't exist
log_info "Ensuring namespace exists: $NAMESPACE"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Apply ConfigMaps and Secrets first
log_info "Applying ConfigMaps and NetworkPolicies..."
kubectl apply -f "$K8S_DIR/configmap-network-policies.yaml" -n "$NAMESPACE"
log_success "ConfigMaps and NetworkPolicies applied"

# Apply backend deployment
log_info "Deploying backend service..."
kubectl apply -f "$K8S_DIR/backend-deployment.yaml" -n "$NAMESPACE"
log_success "Backend deployment applied"

# Wait for backend to be ready
log_info "Waiting for backend pods to be ready..."
kubectl wait --for=condition=ready pod \
    -l app=backend \
    -n "$NAMESPACE" \
    --timeout=300s

log_success "Backend pods are ready"

# Apply frontend deployment
log_info "Deploying frontend service..."
kubectl apply -f "$K8S_DIR/frontend-deployment.yaml" -n "$NAMESPACE"
log_success "Frontend deployment applied"

# Wait for frontend to be ready
log_info "Waiting for frontend pods to be ready..."
kubectl wait --for=condition=ready pod \
    -l app=frontend \
    -n "$NAMESPACE" \
    --timeout=300s

log_success "Frontend pods are ready"

# Apply ingress
log_info "Applying ingress configuration..."
kubectl apply -f "$K8S_DIR/ingress.yaml" -n "$NAMESPACE"
log_success "Ingress applied"

# Display deployment status
log_info "Deployment Status:"
echo ""
echo "======================================================================"
echo "Deployments:"
echo "======================================================================"
kubectl get deployments -n "$NAMESPACE"
echo ""
echo "======================================================================"
echo "Pods:"
echo "======================================================================"
kubectl get pods -n "$NAMESPACE" -o wide
echo ""
echo "======================================================================"
echo "Services:"
echo "======================================================================"
kubectl get services -n "$NAMESPACE"
echo ""
echo "======================================================================"
echo "HorizontalPodAutoscalers:"
echo "======================================================================"
kubectl get hpa -n "$NAMESPACE"
echo ""
echo "======================================================================"
echo "Ingress:"
echo "======================================================================"
kubectl get ingress -n "$NAMESPACE"
echo ""

# Get ingress external IP
log_info "Getting ingress external IP..."
EXTERNAL_IP=""
RETRY_COUNT=0
MAX_RETRIES=30

while [ -z "$EXTERNAL_IP" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo -n "."
    EXTERNAL_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -z "$EXTERNAL_IP" ]; then
        sleep 10
        RETRY_COUNT=$((RETRY_COUNT + 1))
    fi
done
echo ""

if [ -n "$EXTERNAL_IP" ]; then
    log_success "Ingress external IP: $EXTERNAL_IP"
else
    log_warning "Could not retrieve ingress external IP. It may still be provisioning."
fi

log_success "Deployment completed successfully!"
echo ""
echo "======================================================================"
echo "Next Steps:"
echo "======================================================================"
echo "1. Update your DNS records to point to: $EXTERNAL_IP"
echo "2. Access your application at your configured domain"
echo "3. Monitor your deployment:"
echo "   kubectl logs -f deployment/frontend -n $NAMESPACE"
echo "   kubectl logs -f deployment/backend -n $NAMESPACE"
echo ""
echo "Useful Commands:"
echo "  kubectl get pods -n $NAMESPACE -w       # Watch pods"
echo "  kubectl describe pod <pod-name> -n $NAMESPACE"
echo "  kubectl logs -f <pod-name> -n $NAMESPACE"
echo "  kubectl exec -it <pod-name> -n $NAMESPACE -- /bin/bash"
echo "======================================================================"
