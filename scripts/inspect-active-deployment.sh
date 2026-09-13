#!/usr/bin/env sh
set -eu

[ "$#" -eq 1 ] || { echo "Usage: $0 <01-fe-only|02-be-only|03-fe-be>" >&2; exit 2; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required" >&2; exit 1; }

case "$1" in
  01-fe-only) deployments="training-fe-only"; selector="app=training-fe-only" ;;
  02-be-only) deployments="training-be-only"; selector="app=training-be-only" ;;
  03-fe-be) deployments="training-fullstack-fe training-fullstack-be"; selector="app in (training-fullstack-fe,training-fullstack-be)" ;;
  *) echo "Unknown case: $1" >&2; exit 2 ;;
esac

namespace=k3s-training
for deployment in $deployments; do
  echo "=== $deployment ==="
  kubectl get deployment "$deployment" -n "$namespace" -o custom-columns='NAME:.metadata.name,IMAGE:.spec.template.spec.containers[*].image,DEPLOYED-BY:.spec.template.metadata.annotations.training\.hairnerds\.id/deployed-by,GIT-SHA:.spec.template.metadata.annotations.training\.hairnerds\.id/git-sha'
  kubectl rollout status "deployment/$deployment" -n "$namespace" --timeout=10s || true
done

echo "=== Pods ==="
kubectl get pods -n "$namespace" -l "$selector" -o wide
echo "=== Recent events ==="
kubectl get events -n "$namespace" --sort-by=.lastTimestamp | tail -20
