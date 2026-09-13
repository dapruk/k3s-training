#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
repo_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
env_file=${IMAGE_ENV_FILE:-"$script_dir/images.env"}

[ -f "$env_file" ] || {
  echo "Missing $env_file. Copy images.env.example to images.env and set image values." >&2
  exit 1
}

# shellcheck disable=SC1090
. "$env_file"

for variable in FE_ONLY_IMAGE BE_ONLY_IMAGE FULLSTACK_FE_IMAGE FULLSTACK_BE_IMAGE GIT_SHA; do
  eval "value=\${$variable:-}"
  [ -n "$value" ] || { echo "Missing $variable in $env_file" >&2; exit 1; }
done

command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required" >&2; exit 1; }

apply_manifest() {
  sed \
    -e "s|<registry>/k3s-training/fe-only:instructor-baseline-IMAGE_GIT_SHA|$FE_ONLY_IMAGE|g" \
    -e "s|<registry>/k3s-training/be-only:instructor-baseline-IMAGE_GIT_SHA|$BE_ONLY_IMAGE|g" \
    -e "s|<registry>/k3s-training/fullstack-fe:instructor-baseline-IMAGE_GIT_SHA|$FULLSTACK_FE_IMAGE|g" \
    -e "s|<registry>/k3s-training/fullstack-be:instructor-baseline-IMAGE_GIT_SHA|$FULLSTACK_BE_IMAGE|g" \
    -e "s|IMAGE_GIT_SHA|$GIT_SHA|g" \
    "$1" | kubectl apply -f -
}

kubectl apply -f "$script_dir/namespace.yaml"

for manifest in \
  "$repo_root/instructor/baseline/01-fe-only/k8s/deployment.yaml" \
  "$repo_root/instructor/baseline/01-fe-only/k8s/service.yaml" \
  "$repo_root/instructor/baseline/02-be-only/k8s/deployment.yaml" \
  "$repo_root/instructor/baseline/02-be-only/k8s/service.yaml" \
  "$repo_root/instructor/baseline/03-fe-be/k8s/backend-deployment.yaml" \
  "$repo_root/instructor/baseline/03-fe-be/k8s/backend-service.yaml" \
  "$repo_root/instructor/baseline/03-fe-be/k8s/frontend-deployment.yaml" \
  "$repo_root/instructor/baseline/03-fe-be/k8s/frontend-service.yaml"
do
  apply_manifest "$manifest"
done

for deployment in training-fe-only training-be-only training-fullstack-be training-fullstack-fe; do
  kubectl rollout status "deployment/$deployment" -n k3s-training --timeout=180s
done

echo "Baseline deployed. Run: $script_dir/verify.sh"

