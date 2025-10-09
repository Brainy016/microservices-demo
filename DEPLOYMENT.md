# AWS ECR Deployment Guide

This directory contains the configuration to deploy the microservices application to AWS using your ECR registry.

## Prerequisites

1. **kubectl** installed and configured for your AWS EKS cluster
2. **kustomize** installed (or use `kubectl apply -k`)
3. **Docker images** built and pushed to ECR via GitHub Actions

## Quick Start

### Option 1: Using the Deployment Scripts

**Linux/macOS:**
```bash
# Make the script executable
chmod +x deploy.sh

# Deploy with specific commit hash
./deploy.sh c4e5004b

# Deploy with current git commit
./deploy.sh
```

**Windows PowerShell:**
```powershell
# Deploy with specific commit hash
.\deploy.ps1 c4e5004b

# Deploy with current git commit
.\deploy.ps1
```

### Option 2: Manual Deployment

```bash
# Set the commit hash from your GitHub Actions build
export COMMIT_HASH=c4e5004b

# Deploy using Kustomize with environment variable substitution
cd kustomize
envsubst < kustomization.yaml | kustomize build - | kubectl apply -f -
```

## How It Works

1. **GitHub Actions** builds and pushes images to ECR with format:
   - `730335212840.dkr.ecr.eu-north-1.amazonaws.com/my-service:adservice-abc1234`
   - `730335212840.dkr.ecr.eu-north-1.amazonaws.com/my-service:frontend-abc1234`

2. **Kustomize** replaces the `${COMMIT_HASH}` variable in the image tags

3. **kubectl** deploys all services with the correct ECR image references

## Getting the Commit Hash

You can find the commit hash in several ways:

### From GitHub Actions
1. Go to your repository's **Actions** tab
2. Click on the latest successful workflow run
3. The commit hash is shown in the run details (first 7-8 characters)

### From Git Command Line
```bash
# Get short commit hash
git rev-parse --short HEAD

# Get full commit hash
git rev-parse HEAD
```

### From ECR Console
1. Go to AWS ECR console
2. Navigate to your `my-service` repository
3. Look at the image tags - they contain the commit hash

## Accessing the Application

After deployment, get the LoadBalancer external IP:

```bash
kubectl get svc frontend-external
```

The application will be accessible at the EXTERNAL-IP shown in the output.

## Troubleshooting

### Check Deployment Status
```bash
kubectl get pods -o wide
kubectl get services
kubectl describe pod <pod-name>
```

### Check Image Pull Issues
```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

### Verify Images in ECR
Make sure your images exist in ECR with the correct tags:
- Repository: `730335212840.dkr.ecr.eu-north-1.amazonaws.com/my-service`
- Tag format: `servicename-commithash` (e.g., `frontend-c4e5004b`)

## Environment Variables

- `COMMIT_HASH`: The git commit hash used for image tags

## Files Structure

```
kustomize/
├── kustomization.yaml          # Main kustomization config with ECR image overrides
├── base/                       # Base Kubernetes manifests
│   ├── adservice.yaml
│   ├── cartservice.yaml
│   ├── checkoutservice.yaml
│   └── ...
└── components/                 # Optional components for different configurations

deploy.sh                       # Linux/macOS deployment script
deploy.ps1                      # Windows PowerShell deployment script
```