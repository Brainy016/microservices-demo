#!/bin/bash

# AWS ECR Microservices Deployment Script
# Usage: ./deploy.sh [COMMIT_HASH]
# Example: ./deploy.sh c4e5004b

set -e

# Get commit hash as parameter or use current git commit (first 8 chars)
COMMIT_HASH=${1:-$(git rev-parse --short=8 HEAD)}

echo "🚀 Deploying microservices with commit hash: $COMMIT_HASH"
echo "📦 Using AWS ECR registry: 730335212840.dkr.ecr.eu-north-1.amazonaws.com/my-service"
echo ""

# Verify kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Verify kustomize is available
if ! command -v kustomize &> /dev/null; then
    echo "❌ kustomize is not installed or not in PATH"
    echo "💡 Install kustomize: https://kubectl.docs.kubernetes.io/installation/kustomize/"
    exit 1
fi

# Export for envsubst
export COMMIT_HASH

echo "🔧 Processing kustomization with environment variables..."

# Change to kustomize directory
cd kustomize

# Apply with Kustomize and environment substitution
envsubst < kustomization.yaml | kustomize build - | kubectl apply -f -

echo ""
echo "✅ Deployment completed successfully!"
echo "🏷️  All services deployed with image tags: servicename-$COMMIT_HASH"
echo ""
echo "📋 To check deployment status:"
echo "   kubectl get pods -o wide"
echo "   kubectl get services"
echo ""
echo "🌐 To get the LoadBalancer IP for frontend access:"
echo "   kubectl get svc frontend-external"