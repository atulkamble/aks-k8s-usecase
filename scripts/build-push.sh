#!/bin/bash

################################################################################
# Docker Build and Push Script
################################################################################
# This script builds Docker images for frontend and backend services
# and pushes them to Azure Container Registry (ACR)
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
ACR_NAME="${ACR_NAME:-aksdemoregistry}"
VERSION="${VERSION:-v1.0.0}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_info "Docker Build and Push Script"
log_info "ACR Name: $ACR_NAME"
log_info "Version: $VERSION"
log_info "Project Root: $PROJECT_ROOT"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

log_success "Docker found"

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    log_error "Azure CLI is not installed. Please install it first."
    exit 1
fi

log_success "Azure CLI found"

# Login to ACR
log_info "Logging in to Azure Container Registry: $ACR_NAME"
az acr login --name "$ACR_NAME"
log_success "Logged in to ACR"

# Get ACR login server
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer --output tsv)
log_info "ACR Login Server: $ACR_LOGIN_SERVER"

# Build and push frontend image
log_info "Building frontend Docker image..."
cd "$PROJECT_ROOT/src/frontend"
docker build -t frontend:$VERSION \
    --build-arg VERSION=$VERSION \
    -f Dockerfile .

log_success "Frontend image built"

log_info "Tagging frontend image for ACR..."
docker tag frontend:$VERSION $ACR_LOGIN_SERVER/frontend:$VERSION
docker tag frontend:$VERSION $ACR_LOGIN_SERVER/frontend:latest

log_info "Pushing frontend image to ACR..."
docker push $ACR_LOGIN_SERVER/frontend:$VERSION
docker push $ACR_LOGIN_SERVER/frontend:latest

log_success "Frontend image pushed to ACR"

# Build and push backend image
log_info "Building backend Docker image..."
cd "$PROJECT_ROOT/src/backend"
docker build -t backend:$VERSION \
    --build-arg VERSION=$VERSION \
    -f Dockerfile .

log_success "Backend image built"

log_info "Tagging backend image for ACR..."
docker tag backend:$VERSION $ACR_LOGIN_SERVER/backend:$VERSION
docker tag backend:$VERSION $ACR_LOGIN_SERVER/backend:latest

log_info "Pushing backend image to ACR..."
docker push $ACR_LOGIN_SERVER/backend:$VERSION
docker push $ACR_LOGIN_SERVER/backend:latest

log_success "Backend image pushed to ACR"

# List images in ACR
log_info "Listing images in ACR repository..."
echo ""
az acr repository list --name "$ACR_NAME" --output table
echo ""
log_info "Frontend tags:"
az acr repository show-tags --name "$ACR_NAME" --repository frontend --output table
echo ""
log_info "Backend tags:"
az acr repository show-tags --name "$ACR_NAME" --repository backend --output table

log_success "All images built and pushed successfully!"
echo ""
echo "======================================================================"
echo "Image URLs:"
echo "======================================================================"
echo "Frontend: $ACR_LOGIN_SERVER/frontend:$VERSION"
echo "Backend:  $ACR_LOGIN_SERVER/backend:$VERSION"
echo ""
echo "Update your Kubernetes manifests with these image URLs"
echo "======================================================================"
