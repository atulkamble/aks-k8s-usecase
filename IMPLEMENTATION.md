# AKS Kubernetes Use Case - Comprehensive Implementation
# Author: Atul Kamble

This repository contains a **production-ready microservices application** deployed on Azure Kubernetes Service (AKS). It demonstrates best practices for containerization, orchestration, CI/CD, monitoring, and security.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Application Services](#application-services)
- [Kubernetes Resources](#kubernetes-resources)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Logging](#monitoring-and-logging)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)
- [License](#license)

## 🎯 Overview

This project demonstrates a complete microservices architecture on AKS with:

- ✅ **Two microservices**: Frontend (UI) and Backend (API)
- ✅ **Production-ready configurations**: Health checks, resource limits, auto-scaling
- ✅ **Advanced networking**: Ingress, Network Policies, Load Balancing
- ✅ **CI/CD automation**: GitHub Actions pipeline
- ✅ **Security**: RBAC, Network Policies, Secret management
- ✅ **Observability**: Logging, monitoring, and metrics
- ✅ **High availability**: Multi-replica deployments, auto-scaling

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                         Internet                              │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
              ┌──────────────┐
              │ Azure Load   │
              │  Balancer    │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │    NGINX     │
              │   Ingress    │
              └──────┬───────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌──────────────┐          ┌──────────────┐
│   Frontend   │──────────│   Backend    │
│   Service    │          │     API      │
│   (Flask)    │          │   (Flask)    │
└──────────────┘          └──────┬───────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   Database   │
                          │ (PostgreSQL) │
                          └──────────────┘
```

## 📁 Project Structure

```
aks-k8s-usecase/
├── .github/
│   └── workflows/
│       └── ci-cd.yml                 # GitHub Actions CI/CD pipeline
├── src/
│   ├── frontend/                     # Frontend microservice
│   │   ├── app.py                   # Flask application
│   │   ├── requirements.txt         # Python dependencies
│   │   ├── Dockerfile               # Container image definition
│   │   └── templates/
│   │       └── index.html           # Web UI
│   └── backend/                      # Backend API microservice
│       ├── app.py                   # REST API application
│       ├── requirements.txt         # Python dependencies
│       └── Dockerfile               # Container image definition
├── k8s/                              # Kubernetes manifests
│   ├── frontend-deployment.yaml     # Frontend deployment, service, HPA
│   ├── backend-deployment.yaml      # Backend deployment, service, HPA
│   ├── ingress.yaml                 # Ingress configuration
│   └── configmap-network-policies.yaml  # ConfigMaps, Network Policies
├── scripts/                          # Automation scripts
│   ├── setup-aks.sh                 # AKS cluster setup
│   ├── build-push.sh                # Docker build and push
│   └── deploy.sh                    # Kubernetes deployment
├── docker-compose.yml                # Local development environment
├── README.md                         # This file
└── LICENSE

```

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **Azure CLI** (v2.50+): [Install](https://docs.microsoft.com/cli/azure/install-azure-cli)
- **kubectl** (v1.28+): [Install](https://kubernetes.io/docs/tasks/tools/)
- **Docker** (v24+): [Install](https://docs.docker.com/get-docker/)
- **Git**: [Install](https://git-scm.com/downloads)
- **Azure Subscription**: [Get Free Account](https://azure.microsoft.com/free/)

### System Requirements

- Linux, macOS, or Windows with WSL2
- 8GB RAM minimum
- 20GB free disk space

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/atulkamble/aks-k8s-usecase.git
cd aks-k8s-usecase
```

### 2. Login to Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Setup AKS Cluster

```bash
chmod +x scripts/*.sh
./scripts/setup-aks.sh
```

This script will:
- Create resource group
- Create virtual network
- Create Azure Container Registry
- Create AKS cluster with auto-scaling
- Configure kubectl access
- Install NGINX Ingress Controller

### 4. Build and Push Docker Images

```bash
./scripts/build-push.sh
```

### 5. Deploy Applications

```bash
./scripts/deploy.sh
```

### 6. Access Your Application

```bash
# Get the external IP
kubectl get ingress -n default

# Access in browser
# Update your /etc/hosts or DNS to point to the external IP
```

## 📖 Detailed Setup

### Environment Variables

Set these environment variables before running scripts:

```bash
export RESOURCE_GROUP="aks-demo-rg"
export LOCATION="eastus"
export CLUSTER_NAME="aks-demo-cluster"
export ACR_NAME="aksdemoregistry"  # Must be globally unique
export K8S_VERSION="1.28.3"
```

### Manual AKS Setup

If you prefer manual setup instead of using the script:

```bash
# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create ACR
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard

# Create AKS cluster
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 3 \
  --enable-managed-identity \
  --enable-addons monitoring \
  --enable-cluster-autoscaler \
  --min-count 2 \
  --max-count 5 \
  --attach-acr $ACR_NAME \
  --generate-ssh-keys

# Get credentials
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

## 🔨 Application Services

### Frontend Service

**Technology**: Flask + Python 3.11

**Features**:
- Responsive web UI
- Inter-service communication with backend
- Health check endpoints
- Prometheus metrics

**Endpoints**:
- `GET /` - Main UI
- `GET /health` - Health check
- `GET /api/data` - Fetch data from backend
- `GET /api/metrics` - Prometheus metrics

### Backend API Service

**Technology**: Flask REST API + Python 3.11

**Features**:
- RESTful API design
- CRUD operations
- Database connectivity
- Request validation

**Endpoints**:
- `GET /` - API information
- `GET /health` - Health check
- `GET /ready` - Readiness probe
- `GET /api/items` - List all items
- `GET /api/items/<id>` - Get specific item
- `POST /api/items` - Create item
- `PUT /api/items/<id>` - Update item
- `DELETE /api/items/<id>` - Delete item

## ☸️ Kubernetes Resources

### Deployments

Both frontend and backend use the following configurations:

- **Replicas**: 3 (high availability)
- **Rolling Updates**: Zero-downtime deployments
- **Health Checks**: Liveness, readiness, and startup probes
- **Resource Limits**: CPU and memory constraints
- **Security**: Non-root user, read-only filesystem

### Services

- **Type**: ClusterIP (internal)
- **Session Affinity**: Configured for sticky sessions
- **Port Mapping**: Service port to container port

### HorizontalPodAutoscaler (HPA)

- **Min Replicas**: 3
- **Max Replicas**: 10 (frontend), 20 (backend)
- **Metrics**: CPU (70%) and Memory (80%)
- **Scale-up**: Immediate
- **Scale-down**: 5-minute stabilization window

### Ingress

- **Controller**: NGINX
- **Features**: SSL/TLS, CORS, Rate limiting
- **Routing**: Host-based and path-based

### Network Policies

- **Frontend**: Can access backend and external HTTPS
- **Backend**: Can access database and external HTTPS
- **Principle**: Least privilege access

## 🔄 CI/CD Pipeline

The GitHub Actions workflow automates:

1. **Build and Test**
   - Python linting
   - Unit tests
   - Code quality checks

2. **Build and Push Images**
   - Docker image building
   - Push to Azure Container Registry
   - Vulnerability scanning

3. **Deploy to AKS**
   - Update Kubernetes manifests
   - Rolling deployment
   - Health check verification

4. **Security Scanning**
   - Trivy vulnerability scanning
   - Upload to GitHub Security

### Setup CI/CD

1. Create Azure Service Principal:

```bash
az ad sp create-for-rbac --name "aks-demo-github" --role contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} \
  --sdk-auth
```

2. Add secrets to GitHub repository:
   - `AZURE_CREDENTIALS`: Output from above command
   - Other configuration in workflow file

## 📊 Monitoring and Logging

### Azure Monitor

```bash
# View container insights
az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME \
  --query addonProfiles.omsagent
```

### Kubectl Commands

```bash
# View logs
kubectl logs -f deployment/frontend -n default
kubectl logs -f deployment/backend -n default

# View events
kubectl get events -n default --sort-by='.lastTimestamp'

# View resource usage
kubectl top nodes
kubectl top pods -n default
```

## 🔒 Security

### Best Practices Implemented

1. **Container Security**
   - Non-root user
   - Read-only filesystem where possible
   - No privilege escalation
   - Minimal base images

2. **Network Security**
   - Network policies
   - TLS/SSL encryption
   - Private container registry

3. **Secret Management**
   - Kubernetes Secrets
   - Consider Azure Key Vault integration

4. **RBAC**
   - Azure AD integration
   - Least privilege access

## 🐛 Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
```

**Service not accessible:**
```bash
kubectl get svc -n default
kubectl get endpoints -n default
```

**Ingress not working:**
```bash
kubectl describe ingress app-ingress -n default
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

**Image pull errors:**
```bash
# Verify ACR integration
az aks check-acr --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME --acr $ACR_NAME.azurecr.io
```

## ✅ Best Practices

1. **Resource Management**
   - Always set resource requests and limits
   - Use HPA for auto-scaling
   - Monitor resource usage

2. **High Availability**
   - Run multiple replicas
   - Use pod anti-affinity
   - Implement PodDisruptionBudgets

3. **Security**
   - Regular security updates
   - Scan images for vulnerabilities
   - Use network policies
   - Rotate secrets regularly

4. **Monitoring**
   - Set up alerts
   - Monitor application logs
   - Track metrics and KPIs

5. **CI/CD**
   - Automate deployments
   - Use blue-green or canary deployments
   - Implement automated testing

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Atul Kamble**

- GitHub: [@atulkamble](https://github.com/atulkamble)
- LinkedIn: [atuljkamble](https://www.linkedin.com/in/atuljkamble/)
- Twitter: [@atul_kamble](https://x.com/atul_kamble)

## 🙏 Acknowledgments

- Azure Kubernetes Service documentation
- Kubernetes community
- Flask framework
- NGINX Ingress Controller

---

**⭐ If you find this project helpful, please consider giving it a star!**
