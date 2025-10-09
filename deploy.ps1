# AWS ECR Microservices Deployment Script (PowerShell)
# Usage: .\deploy.ps1 [COMMIT_HASH]
# Example: .\deploy.ps1 c4e5004b

param(
    [string]$CommitHash
)

# Get commit hash as parameter or use current git commit (first 8 chars)
if (-not $CommitHash) {
    try {
        $CommitHash = (git rev-parse --short=8 HEAD).Trim()
    } catch {
        Write-Host "❌ Unable to get git commit hash. Please provide it as a parameter." -ForegroundColor Red
        Write-Host "Usage: .\deploy.ps1 c4e5004b" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "🚀 Deploying microservices with commit hash: $CommitHash" -ForegroundColor Green
Write-Host "📦 Using AWS ECR registry: 730335212840.dkr.ecr.eu-north-1.amazonaws.com/my-service" -ForegroundColor Blue
Write-Host ""

# Verify kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ kubectl is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Verify kustomize is available
if (-not (Get-Command kustomize -ErrorAction SilentlyContinue)) {
    Write-Host "❌ kustomize is not installed or not in PATH" -ForegroundColor Red
    Write-Host "💡 Install kustomize: https://kubectl.docs.kubernetes.io/installation/kustomize/" -ForegroundColor Yellow
    exit 1
}

# Set environment variable
$env:COMMIT_HASH = $CommitHash

Write-Host "🔧 Processing kustomization with environment variables..." -ForegroundColor Yellow

# Change to kustomize directory
Set-Location kustomize

try {
    # Read kustomization.yaml, replace environment variables, and apply
    $kustomizeContent = Get-Content kustomization.yaml -Raw
    $processedContent = $kustomizeContent -replace '\$\{COMMIT_HASH\}', $CommitHash
    
    # Apply with kubectl
    $processedContent | kustomize build - | kubectl apply -f -
    
    Write-Host ""
    Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
    Write-Host "🏷️  All services deployed with image tags: servicename-$CommitHash" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 To check deployment status:" -ForegroundColor Yellow
    Write-Host "   kubectl get pods -o wide" -ForegroundColor Gray
    Write-Host "   kubectl get services" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 To get the LoadBalancer IP for frontend access:" -ForegroundColor Yellow
    Write-Host "   kubectl get svc frontend-external" -ForegroundColor Gray
} catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}