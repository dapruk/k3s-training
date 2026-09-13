#!/usr/bin/env sh
set -eu

command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required" >&2; exit 1; }

kubectl get deployments,pods,services -n k3s-training -o wide

for deployment in training-fe-only training-be-only training-fullstack-be training-fullstack-fe; do
  kubectl rollout status "deployment/$deployment" -n k3s-training --timeout=10s
done

if [ -n "${NODE_ADDRESS:-}" ]; then
  command -v curl >/dev/null 2>&1 || { echo "curl is required for HTTP checks" >&2; exit 1; }
  curl --fail --show-error "http://$NODE_ADDRESS:30081"
  curl --fail --show-error "http://$NODE_ADDRESS:30082"
  curl --fail --show-error "http://$NODE_ADDRESS:30082/health"
  curl --fail --show-error "http://$NODE_ADDRESS:30083"
  curl --fail --show-error "http://$NODE_ADDRESS:30083/api/name"
else
  echo "NODE_ADDRESS not set; skipped HTTP checks. Example: NODE_ADDRESS=127.0.0.1 $0"
fi

