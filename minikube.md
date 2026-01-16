# 🚀 Minikube Kubernetes Project

**Docker → Kubernetes (Minikube) Deployment**

![Image](https://fusionauth.io/img/docs/get-started/download-and-install/kubernetes/fa-minikube.png)

![Image](https://www.docker.com/app/uploads/2019/10/Docker-Kubernetes-together.png)

![Image](https://platform9.com/media/kubernetes-constructs-concepts-architecture.jpg)

![Image](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

---

## 📌 Project Title

**End-to-End Containerized Application Deployment on Minikube**

---

## 🎯 Project Objectives

* Install and configure **Docker & Docker Compose**
* Run application locally using **Docker Compose**
* Build and push **Docker images**
* Set up **Minikube Kubernetes cluster**
* Deploy **Frontend & Backend** on Kubernetes
* Expose application using **LoadBalancer service**
* Access application using **Minikube Service & Tunnel**

---

## 🧱 Technology Stack

| Layer            | Tool                             |
| ---------------- | -------------------------------- |
| OS               | Ubuntu / WSL                     |
| Containerization | Docker, Docker Compose           |
| Orchestration    | Kubernetes (Minikube)            |
| Registry         | Docker Hub                       |
| CLI Tools        | kubectl, minikube, git           |
| App              | Frontend + Backend (Flask/MySQL) |

---

## 🏗️ Architecture Overview

![Image](https://miro.medium.com/v2/resize%3Afit%3A2000/1%2AcpaLKkIZg3SBZTLdBJKEvw.png)

![Image](https://fusionauth.io/img/docs/get-started/download-and-install/kubernetes/fa-minikube.png)

```
User
 │
 ▼
LoadBalancer Service
 │
 ├── Frontend Pod
 │
 └── Backend Pod
      │
      ▼
   MySQL Database
```

---

## 🔹 Phase 1: Docker & Docker Compose Setup

### 1️⃣ Install Docker

```bash
sudo apt update -y
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

### 2️⃣ Install Docker Compose v2

```bash
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
docker compose version
```

### 3️⃣ Verify Docker

```bash
docker ps
docker images
```

---

## 🔹 Phase 2: Run Application using Docker Compose

### 1️⃣ Clone Repository

```bash
git clone https://github.com/atulkamble/docker-compose-flask-mysql.git
cd docker-compose-flask-mysql
```

### 2️⃣ Start Containers

```bash
sudo docker compose up -d
sudo docker container ls
```

### 3️⃣ Verify MySQL Data

```bash
sudo docker exec -it mysql_db mysql -uroot -proot123 -D flaskdb \
-e "SELECT * FROM entries;"
```

✔️ Application validated successfully using Docker Compose

---

## 🔹 Phase 3: Minikube & Kubernetes Setup

![Image](https://images.ctfassets.net/w1bd7cq683kz/2qZ0Ll6qoEHq7Anx2lVnK1/3fdfb78454b07be02c6277059e721137/minikube.png)

![Image](https://miro.medium.com/1%2AtxtpUibnVfZS2ZYzbf1UhQ.png)

### 1️⃣ Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

### 2️⃣ Install kubectl

```bash
sudo snap install kubectl --classic
kubectl version --client
```

### 3️⃣ Start Minikube Cluster

```bash
minikube start
kubectl get nodes
```

---

## 🔹 Phase 4: Build & Push Docker Images

### 1️⃣ Login to Docker Hub

```bash
sudo docker login -u shashigangurde
```

### 2️⃣ Build & Push Frontend Image

```bash
cd src/frontend
sudo docker build -t docker.io/shashigangurde/frontend .
sudo docker push docker.io/shashigangurde/frontend
```

### 3️⃣ Build & Push Backend Image

```bash
cd ../backend
sudo docker build -t docker.io/shashigangurde/backend .
sudo docker push docker.io/shashigangurde/backend
```

---

## 🔹 Phase 5: Kubernetes Deployment

![Image](https://media.geeksforgeeks.org/wp-content/uploads/20240117124301/deployment12.png)

![Image](https://www.densify.com/wp-content/uploads/article-k8s-capacity-kubernetes-service-overview.svg)

### 1️⃣ Kubernetes Manifests

```bash
cd k8s
backend-deployment.yaml
frontend-deployment.yaml
loadbalancer-service.yaml
```

### 2️⃣ Deploy to Minikube

```bash
kubectl apply -f k8s/
```

### 3️⃣ Verify Resources

```bash
kubectl get pods
kubectl get svc
kubectl get nodes
```

---

## 🔹 Phase 6: Access Application

### 1️⃣ Expose LoadBalancer

```bash
minikube service app-loadbalancer
```

### 2️⃣ Optional (External IP Support)

```bash
minikube tunnel
```

---

## 🔹 Phase 7: Monitoring & Dashboard

![Image](https://cdn.thenewstack.io/media/2023/02/d1975006-minikubedash1.jpg)

![Image](https://raw.githubusercontent.com/digitalocean/marketplace-kubernetes/master/stacks/metrics-server/assets/images/arch_hpa.png)

### Enable Metrics Server

```bash
minikube addons enable metrics-server
```

### Launch Dashboard

```bash
minikube dashboard
```

---

## 🔻 Phase 8: Cluster Shutdown & Cleanup

This phase is used to **stop Minikube** and **clean unused Docker resources** after completing the project or lab practice.

---

### 🛑 Stop Minikube Cluster

Stops the running Minikube Kubernetes cluster without deleting it.

```bash
minikube stop
```

✔️ Use this when:

* You want to save system resources
* You plan to restart the cluster later
* You don’t want to delete cluster state

---

### 🧹 Clean Docker Environment (Optional but Recommended)

Removes **all unused Docker data** including:

* Stopped containers
* Unused images
* Unused networks
* Build cache

```bash
docker system prune -a
```

⚠️ **Warning:**
This will delete **all unused Docker images**, so ensure important images are already pushed to Docker Hub.

---

### 🔁 Restart (If Needed Later)

```bash
minikube start
```

---

## ✅ Final Cleanup Summary

| Task                      | Command                  |
| ------------------------- | ------------------------ |
| Stop Minikube             | `minikube stop`          |
| Remove unused Docker data | `docker system prune -a` |
| Restart cluster           | `minikube start`         |

---

## 🏁 Project Lifecycle Completed

✔ Build → Deploy → Test → Monitor → Stop → Cleanup

This completes the **full Minikube Kubernetes project lifecycle**, making it **lab-ready, interview-ready, and production-practice aligned**.

---


## ✅ Project Outcome

* ✔ Docker Compose validated application locally
* ✔ Images built & pushed to Docker Hub
* ✔ Minikube cluster running successfully
* ✔ Frontend & Backend deployed on Kubernetes
* ✔ LoadBalancer exposed application
* ✔ Dashboard & metrics enabled

---

## 📌 Commands Cheat Sheet

```bash
kubectl get pods
kubectl get svc
kubectl describe pod <pod-name>
kubectl logs <pod-name>
minikube service app-loadbalancer
minikube dashboard
minikube tunnel
```

---

## 🏁 Conclusion

This project demonstrates a **complete DevOps workflow** from **Docker → Kubernetes using Minikube**, ideal for:

* Kubernetes learning
* Interview demonstrations
* Local Kubernetes testing
* Cloud-ready application design

---


