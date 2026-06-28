# Guestbook Application on Kubernetes

A cloud-native Guestbook web application built using Go and containerized with Docker, then deployed on Kubernetes with rolling updates, autoscaling, and container orchestration.

This project was completed as part of the IBM Full Stack Developer Professional Certificate and demonstrates modern DevOps and cloud deployment practices.

---

## Features

- Guestbook web application
- Docker containerization
- Kubernetes Deployment
- Kubernetes Service
- Horizontal Pod Autoscaler (HPA)
- Rolling Updates
- Rollback support
- CPU resource requests and limits
- Container image hosted on IBM Container Registry
- Git and GitHub version control

---

## Technology Stack

- Go
- HTML
- CSS
- JavaScript
- Docker
- Kubernetes
- IBM Cloud Container Registry
- Git
- GitHub

---

## Project Structure

```
guestbook/
│
├── public/
│   ├── index.html
│   ├── script.js
│   ├── style.css
│   └── jquery.min.js
│
├── Dockerfile
├── deployment.yml
├── service.yml
├── hpa.yml
└── main.go
```

---

## Docker

Build the image

```bash
docker build -t guestbook:v1 .
```

Run locally

```bash
docker run -p 3000:3000 guestbook:v1
```

---

## Kubernetes Deployment

Deploy the application

```bash
kubectl apply -f deployment.yml
```

Check deployment

```bash
kubectl get deployments
```

Check pods

```bash
kubectl get pods
```

Expose the service

```bash
kubectl apply -f service.yml
```

---

## Horizontal Pod Autoscaling

Create the HPA

```bash
kubectl autoscale deployment guestbook \
--cpu-percent=5 \
--min=1 \
--max=10
```

Verify

```bash
kubectl get hpa
```

---

## Rolling Updates

Updated the application UI from

```
Guestbook - v1
```

to

```
Guestbook - v2
```

Performed a rolling update using Kubernetes Deployment.

Verified rollout status

```bash
kubectl rollout status deployment/guestbook
```

Restart deployment

```bash
kubectl rollout restart deployment guestbook
```

Rollback if required

```bash
kubectl rollout undo deployment guestbook
```

---

## Resource Configuration

Configured CPU resource limits

```yaml
resources:
  requests:
    cpu: 2m
  limits:
    cpu: 5m
```

---

## Skills Demonstrated

- Docker Image Creation
- Docker Registry Push
- Kubernetes Deployments
- ReplicaSets
- Pods
- Services
- Horizontal Pod Autoscaler
- Rolling Updates
- Rollbacks
- Resource Management
- Git Version Control
- GitHub Collaboration

---

## Learning Outcomes

Through this project I gained hands-on experience with

- Building containerized applications
- Deploying applications to Kubernetes
- Managing application scalability
- Rolling application updates with zero downtime
- Debugging Kubernetes deployments
- Using IBM Cloud Container Registry
- Version controlling cloud-native applications

---

## Author

**Debayan Nath**

B.Tech Cyber Security Engineering

Dayananda Sagar University

GitHub: https://github.com/debayan66# Guestbook Application on Kubernetes

A cloud-native Guestbook web application built using Go and containerized with Docker, then deployed on Kubernetes with rolling updates, autoscaling, and container orchestration.

This project was completed as part of the IBM Full Stack Developer Professional Certificate and demonstrates modern DevOps and cloud deployment practices.

---

## Features

- Guestbook web application
- Docker containerization
- Kubernetes Deployment
- Kubernetes Service
- Horizontal Pod Autoscaler (HPA)
- Rolling Updates
- Rollback support
- CPU resource requests and limits
- Container image hosted on IBM Container Registry
- Git and GitHub version control

---

## Technology Stack

- Go
- HTML
- CSS
- JavaScript
- Docker
- Kubernetes
- IBM Cloud Container Registry
- Git
- GitHub

---

## Project Structure

```
guestbook/
│
├── public/
│   ├── index.html
│   ├── script.js
│   ├── style.css
│   └── jquery.min.js
│
├── Dockerfile
├── deployment.yml
├── service.yml
├── hpa.yml
└── main.go
```

---

## Docker

Build the image

```bash
docker build -t guestbook:v1 .
```

Run locally

```bash
docker run -p 3000:3000 guestbook:v1
```

---

## Kubernetes Deployment

Deploy the application

```bash
kubectl apply -f deployment.yml
```

Check deployment

```bash
kubectl get deployments
```

Check pods

```bash
kubectl get pods
```

Expose the service

```bash
kubectl apply -f service.yml
```

---

## Horizontal Pod Autoscaling

Create the HPA

```bash
kubectl autoscale deployment guestbook \
--cpu-percent=5 \
--min=1 \
--max=10
```

Verify

```bash
kubectl get hpa
```

---

## Rolling Updates

Updated the application UI from

```
Guestbook - v1
```

to

```
Guestbook - v2
```

Performed a rolling update using Kubernetes Deployment.

Verified rollout status

```bash
kubectl rollout status deployment/guestbook
```

Restart deployment

```bash
kubectl rollout restart deployment guestbook
```

Rollback if required

```bash
kubectl rollout undo deployment guestbook
```

---

## Resource Configuration

Configured CPU resource limits

```yaml
resources:
  requests:
    cpu: 2m
  limits:
    cpu: 5m
```

---

## Skills Demonstrated

- Docker Image Creation
- Docker Registry Push
- Kubernetes Deployments
- ReplicaSets
- Pods
- Services
- Horizontal Pod Autoscaler
- Rolling Updates
- Rollbacks
- Resource Management
- Git Version Control
- GitHub Collaboration

---

## Learning Outcomes

Through this project I gained hands-on experience with

- Building containerized applications
- Deploying applications to Kubernetes
- Managing application scalability
- Rolling application updates with zero downtime
- Debugging Kubernetes deployments
- Using IBM Cloud Container Registry
- Version controlling cloud-native applications

---

## Author

**Debayan Nath**

B.Tech Cyber Security Engineering

Dayananda Sagar University

GitHub: https://github.com/debayan66
