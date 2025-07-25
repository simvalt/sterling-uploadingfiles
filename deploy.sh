#!/bin/bash

set -euo pipefail

# === CONFIGURACIÓN ===
PROJECT_ID="gentera-proyects"
REGION="us-central1"
REPO_NAME="sterling-repo-dev"
IMAGE_NAME="sterling-poc"
CLUSTER_NAME="sterling-gke-dev"

IMAGE_URI="$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:1.0.3"

echo "🚀 Iniciando pipeline para Sterling POC..."

# === 1. Terraform ===
echo "🔧 Ejecutando Terraform..."
cd iac
terraform init
terraform apply -var-file="env/dev.tfvars" -auto-approve
cd ../

# === 2. Docker Build & Push ===
echo "🐳 Construyendo imagen Docker: $IMAGE_URI"
cd api
docker build -t "$IMAGE_URI" .

echo "🔐 Autenticando Docker con Artifact Registry..."
gcloud auth configure-docker "$REGION-docker.pkg.dev" --quiet

echo "📤 Pusheando imagen a Artifact Registry..."
docker push "$IMAGE_URI"
cd ..

# === 3. Kubernetes Deploy ===
echo "☸️  Obteniendo credenciales del clúster..."
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION-b" --project "$PROJECT_ID"

echo "📦 Aplicando manifests..."
export IMAGE_URI  # Necesario para envsubst
envsubst < api/k8s/deployment.yaml | kubectl apply -f -
kubectl apply -f api/k8s/service.yaml

echo "🔄 Reiniciando despliegue para aplicar cambios..."
kubectl rollout restart deployment sterling-poc

echo "✅ Deploy completo. Verifica con:"
echo ""
echo "kubectl get service sterling-poc-service"
echo ""

