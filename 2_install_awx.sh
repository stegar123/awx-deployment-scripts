#!/bin/bash
set -e

echo "🚀 Starting AWX deployment on Kubernetes..."

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check if kubectl is installed and configured
if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Error: kubectl cannot connect to Kubernetes cluster."
    exit 1
fi

# Check required environment variables
if [ -z "$TENANTS_LB_CRT" ] || [ -z "$TENANTS_LB_KEY" ]; then
    echo "❌ Error: Required environment variables not set:"
    echo "   TENANTS_LB_CRT - Base64 encoded certificate"
    echo "   TENANTS_LB_KEY - Base64 encoded private key"
    exit 1
fi

# Check required files
required_files=("nfs-server.yml" "linode-nfs-storage.yml" "awx-cr.yaml" "awx-operator/Makefile")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: Required file '$file' not found."
        exit 1
    fi
done

echo "✅ Prerequisites check passed!"

# Install NGINX Ingress Controller
echo "🔧 Installing NGINX Ingress Controller (v1.8.1)..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# Wait for ingress controller to be ready
echo "⏳ Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

# Install NFS CSI drivers
echo "🔧 Installing NFS CSI drivers (v4.9.0)..."
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/heads/master/deploy/install-driver.sh | bash -s v4.9.0 --

# Create AWX namespace
echo "🏗️  Creating AWX namespace..."
kubectl create namespace awx --dry-run=client -o yaml | kubectl apply -f -

# Set namespace context
echo "🔄 Setting kubectl context to awx namespace..."
kubectl config set-context --current --namespace=awx

# Create TLS secret
echo "🔐 Creating TLS secret..."
kubectl create secret tls awx-tls-secret \
  --cert=<(echo "$TENANTS_LB_CRT" | base64 -d) \
  --key=<(echo "$TENANTS_LB_KEY" | base64 -d) \
  -n awx \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy NFS server
echo "🗄️  Deploying NFS server..."
kubectl apply -f nfs-server.yml

# Wait for NFS server to be ready
echo "⏳ Waiting for NFS server to be ready..."
kubectl wait --for=condition=ready pod -l app=nfs-server -n nfs-server --timeout=300s

# Apply storage class
echo "💾 Applying NFS storage class..."
kubectl apply -f linode-nfs-storage.yml

# Deploy AWX Operator
echo "🎯 Deploying AWX Operator..."
cd awx-operator/
make deploy

# Wait for operator to be ready
echo "⏳ Waiting for AWX Operator to be ready..."
kubectl wait --for=condition=available deployment/awx-operator-controller-manager -n awx --timeout=300s

# Create AWX instance
echo "🏗️  Creating AWX instance..."
kubectl apply -f ../awx-cr.yaml

# Return to original directory
cd -

echo "✅ AWX deployment completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Check deployment status: kubectl get pods -n awx"
echo "2. Check services: kubectl get svc -n awx"
echo "3. Check ingress: kubectl get ingress -n awx"
echo "4. Monitor AWX instance: kubectl get awx -n awx"
echo ""
echo "⏳ Note: AWX instance may take several minutes to fully initialize."
