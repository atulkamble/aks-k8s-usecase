<div align="center">
<h1>🚀 Production-Ready Microservices on AKS</h1>
<p><strong>Complete Kubernetes Implementation with Flask Microservices</strong></p>
<p><strong>Built with ❤️ by <a href="https://github.com/atulkamble">Atul Kamble</a></strong></p>

<p>
<img src="https://img.shields.io/badge/Azure-AKS-0078D4?logo=microsoftazure&style=for-the-badge" alt="Azure AKS" />
<img src="https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white&style=for-the-badge" alt="Kubernetes" />
<img src="https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white&style=for-the-badge" alt="Python" />
<img src="https://img.shields.io/badge/Flask-000000?logo=flask&logoColor=white&style=for-the-badge" alt="Flask" />
<img src="https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white&style=for-the-badge" alt="Docker" />
</p>

<p>
<a href="https://github.com/atulkamble">
<img src="https://img.shields.io/badge/GitHub-atulkamble-181717?logo=github&style=flat-square" />
</a>
<a href="https://www.linkedin.com/in/atuljkamble/">
<img src="https://img.shields.io/badge/LinkedIn-atuljkamble-0A66C2?logo=linkedin&style=flat-square" />
</a>
<a href="https://x.com/atul_kamble">
<img src="https://img.shields.io/badge/X-@atul_kamble-000000?logo=x&style=flat-square" />
</a>
</p>

<p><strong>Version 1.0.0</strong> | <strong>Last Updated:</strong> January 2026</p>

</div>

---

## 📖 Overview

This repository contains a **complete, production-ready microservices application** designed for Azure Kubernetes Service (AKS). It includes fully functional Flask-based microservices, comprehensive Kubernetes manifests, automation scripts, CI/CD pipeline, and extensive documentation.

**Perfect for:**
- ✅ Learning Kubernetes and AKS
- ✅ DevOps interviews and demonstrations
- ✅ Production deployment reference
- ✅ Training and workshops
- ✅ Proof of concept implementations

## ✨ Features

- 🎯 **Two Microservices**: Frontend (Web UI) + Backend (REST API)
- 🐳 **Dockerized Applications**: Multi-stage builds with security best practices
- ☸️ **Production Kubernetes Manifests**: Deployments, Services, Ingress, HPA, Network Policies
- 🔄 **CI/CD Pipeline**: GitHub Actions with automated build, test, and deployment
- 🔒 **Security**: RBAC, Network Policies, Secret management, non-root containers
- 📈 **Auto-scaling**: Horizontal Pod Autoscaler (HPA) + Cluster Autoscaler
- 🛠️ **Automation Scripts**: One-command cluster setup and deployment
- 📊 **Monitoring**: Azure Monitor integration, health checks, metrics endpoints
- 🧪 **Local Development**: Docker Compose for testing locally

## 📁 Project Structure

```
aks-k8s-usecase/
├── src/
│   ├── frontend/              # Flask web application
│   │   ├── app.py            # Main application
│   │   ├── requirements.txt  # Dependencies
│   │   ├── Dockerfile        # Multi-stage build
│   │   └── templates/        # HTML templates
│   └── backend/               # Flask REST API
│       ├── app.py            # API endpoints
│       ├── requirements.txt  # Dependencies
│       └── Dockerfile        # Multi-stage build
├── k8s/                       # Kubernetes manifests
│   ├── frontend-deployment.yaml
│   ├── backend-deployment.yaml
│   ├── ingress.yaml
│   └── configmap-network-policies.yaml
├── scripts/                   # Automation scripts
│   ├── setup-aks.sh          # AKS cluster setup
│   ├── build-push.sh         # Build & push images
│   └── deploy.sh             # Deploy to Kubernetes
├── .github/workflows/         # CI/CD pipeline
│   └── ci-cd.yml
├── docker-compose.yml         # Local development
├── IMPLEMENTATION.md          # Detailed documentation
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) (v2.50+)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) (v1.28+)
- [Docker](https://docs.docker.com/get-docker/) (v24+)
- Azure subscription ([Free account](https://azure.microsoft.com/free/))

### 1️⃣ Clone Repository

```bash
git clone https://github.com/atulkamble/aks-k8s-usecase.git
cd aks-k8s-usecase
```

### 2️⃣ Set Environment Variables

```bash
export RESOURCE_GROUP="aks"
export LOCATION="eastus"
export CLUSTER_NAME="mycluster"
export ACR_NAME="atulkamble"  # Must be globally unique
```

### 3️⃣ Deploy to Azure

```bash
# Login to Azure
az login

# Make scripts executable
chmod +x scripts/*.sh

# Setup AKS cluster (10-15 minutes)
./scripts/setup-aks.sh

# Build and push images to ACR
./scripts/build-push.sh

# Deploy applications to AKS
./scripts/deploy.sh
```

### 4️⃣ Test Locally (Optional)

```bash
# Start all services locally
docker-compose up -d

# Access at http://localhost
# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📚 Detailed Documentation

For comprehensive documentation, see [IMPLEMENTATION.md](IMPLEMENTATION.md) which includes:
- Architecture diagrams
- Step-by-step setup guide
- Kubernetes resource explanations
- Troubleshooting guide
- Best practices
- Monitoring and logging

---

## 🏗️ Architecture

### High-Level Architecture

```
                    ┌─────────────┐
                    │   Internet  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Azure LB  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │    NGINX    │
                    │   Ingress   │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │                         │
       ┌──────▼──────┐          ┌──────▼──────┐
       │  Frontend   │──────────│   Backend   │
       │  Service    │          │     API     │
       │  (Flask)    │          │   (Flask)   │
       └─────────────┘          └──────┬──────┘
                                       │
                                ┌──────▼──────┐
                                │  Database   │
                                └─────────────┘
```

### Technology Stack

- **Frontend**: Flask + Python 3.11 + Gunicorn
- **Backend**: Flask REST API + Python 3.11 + Gunicorn
- **Container**: Docker (multi-stage builds)
- **Orchestration**: Kubernetes on AKS
- **Networking**: Azure CNI, NGINX Ingress
- **CI/CD**: GitHub Actions
- **Monitoring**: Azure Monitor + Container Insights
- **Registry**: Azure Container Registry (ACR)

---� Key Features Implemented

### Microservices

#### Frontend Service (Flask Web UI)
- Responsive web interface
- Inter-service communication with backend
- Health check endpoints (`/health`)
- Metrics endpoint (`/api/metrics`)
- Environment-based configuration

#### Backend API Service (Flask REST API)
- RESTful API design with full CRUD operations
- Endpoints: `/api/items` (GET, POST)
- Individual item operations (GET, PUT, DELETE)
- Health and readiness probes
- Structured logging

### Kubernetes Resources

- **Deployments**: 3 replicas for HA, rolling updates, resource limits
- **Services**: ClusterIP for internal communication
- **Ingress**: NGINX with SSL/TLS, CORS, rate limiting
- **HPA**: Auto-scaling (3-10 frontend, 3-20 backend replicas)
- **Network Policies**: Micro-segmentation for security
- **ConfigMaps**: Application configuration
- **Secrets**: Sensitive data management
- **PodDisruptionBudgets**: Maintain availability during disruptions

### Security Best Practices

- ✅ Non-root containers
- ✅ Read-only root filesystem where possible
- ✅ Network policies for traffic control
- ✅ Private container registry (ACR)
- ✅ Secret management with Kubernetes Secrets
- ✅ RBAC with Azure AD integration
- ✅ TLS/SSL encryption

### DevOps & Automation

- **CI/CD Pipeline**: GitHub Actions with automated build, test, deploy
- **Infrastructure Scripts**: Automated AKS setup, image building, deployment
- **Local Development**: Docker Compose for local testing
- **Monitoring**: Azure Monitor + Container Insights integration

---

## 📋 Application Endpoints

### Frontend Service
- `GET /` - Main web UI
- `GET /health` - Health check
- `GET /api/data` - Fetch data from backend
- `GET /api/metrics` - Prometheus metrics

### Backend API Service
- `GET /` - API information
- `GET /health` - Health check
- `GET /ready` - Readiness probe
- `GET /api/items` - List all items
- `GET /api/items/<id>` - Get specific item
- `POST /api/items` - Create new item
- `PUT /api/items/<id>` - Update item
- `DELETE /api/items/<id>` - Delete item
- `GET /api/metrics` - Service metrics

---

## 🛠️ Development Workflow

### Local Development

1. **Start services locally:**
```bash
docker-compose up -d
```

2. **Access application:**
- Frontend: http://localhost
- Backend API: http://localhost:8080
- Database: localhost:5432

3. **View logs:**
```bash
docker-compose logs -f
docker-compose logs -f frontend
docker-compose logs -f backend
```

4. **Stop services:**
```bash
docker-compose down
```

### Build Docker Images

```bash
# Frontend
cd src/frontend
docker build -t frontend:latest .

# Backend
cd src/backend
docker build -t backend:latest .
```

### Deploy to AKS

```bash
# Update image references in k8s manifests
# Deploy to Kubernetes
kubectl apply -f k8s/
```

---

## 📊 Monitoring & Operations

### View Cluster Resources

```bash
# Get cluster info
kubectl cluster-info

# View nodes
kubectl get nodes

# View all resources
kubectl get all -n default

# View pod logs
kubectl logs -f deployment/frontend -n default
kubectl logs -f deployment/backend -n default
```

### Monitor Performance

```bash
# Resource usage
kubectl top nodes
kubectl top pods -n default

# Describe resources
kubectl describe deployment frontend -n default
kubectl describe pod <pod-name> -n default
```

### Access Azure Monitor

```bash
# View container insights
az aks show --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --query addonProfiles.omsagent
```

---

## 🐛 Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl get pods -n default
kubectl describe pod <pod-name> -n default
kubectl logs <pod-name> -n default
```

**Service connectivity issues:**
```bash
kubectl get svc -n default
kubectl get endpoints -n default
kubectl exec -it <pod-name> -n default -- curl http://backend-service:8080/health
```

**Ingress not working:**
```bash
kubectl get ingress -n default
kubectl describe ingress app-ingress -n default
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

**Image pull errors:**
```bash
az aks check-acr --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --acr $ACR_NAME.azurecr.io
```

---

## 📈 Scaling

### Manual Scaling

```bash
# Scale deployments
kubectl scale deployment frontend --replicas=5 -n default
kubectl scale deployment backend --replicas=8 -n default
```

### Auto-scaling (HPA)

HPA is configured automatically based on:
- CPU utilization (70% target)
- Memory utilization (80% target)

View HPA status:
```bash
kubectl get hpa -n default
kubectl describe hpa frontend-hpa -n default
```

---

## 🔒 Security Considerations

1. **Container Security**
   - Use minimal base images (Alpine/Slim)
   - Run as non-root user
   - Scan images for vulnerabilities

2. **Network Security**
   - Implement Network Policies
   - Use private subnets
   - Enable TLS/SSL

3. **Secret Management**
   - Never commit secrets to Git
   - Use Azure Key Vault for sensitive data
   - Rotate secrets regularly

4. **Access Control**
   - Implement RBAC
   - Use Azure AD integration
   - Principle of least privilege

---

## 🎓 Learning Resources

This project demonstrates:
- ✅ Microservices architecture
- ✅ Containerization with Docker
- ✅ Kubernetes orchestration
- ✅ Azure cloud services (AKS, ACR)
- ✅ CI/CD with GitHub Actions
- ✅ Infrastructure as Code
- ✅ DevOps best practices
- ✅ Production-ready configurations

---

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Atul Kamble**
- GitHub: [@atulkamble](https://github.com/atulkamble)
- LinkedIn: [atuljkamble](https://www.linkedin.com/in/atuljkamble/)
- Twitter: [@atul_kamble](https://x.com/atul_kamble)

---

## 🙏 Acknowledgments

- Azure Kubernetes Service documentation
- Kubernetes community
- Flask framework
- NGINX Ingress Controller

---

<div align="center">
<p><strong>⭐ If you find this project helpful, please consider giving it a star!</strong></p>
<p>Made with ❤️ for the DevOps and Cloud Native community</p>
</div>*Cloud-native architecture**

---
