#!/usr/bin/env sh
set -eu

usage() {
  echo "Usage: $0 <participant> <01-fe-only|02-be-only|03-fe-be>" >&2
  exit 2
}

[ "$#" -eq 2 ] || usage
participant=$1
case_name=$2

case "$participant" in akmal|fajrian|zal|fahmi|jale|akhdan) ;; *) echo "Unknown participant: $participant" >&2; exit 2;; esac
case "$case_name" in 01-fe-only|02-be-only|03-fe-be) ;; *) echo "Unknown case: $case_name" >&2; exit 2;; esac

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
dir="$root/participants/$participant/$case_name"
[ -d "$dir" ] || { echo "Missing assignment directory: $dir" >&2; exit 1; }

if [ "$case_name" = "03-fe-be" ]; then
  required="frontend/Dockerfile frontend/nginx.conf backend/Dockerfile k8s/frontend-deployment.yaml k8s/frontend-service.yaml k8s/backend-deployment.yaml k8s/backend-service.yaml"
  expected_names="training-fullstack-fe training-fullstack-be"
else
  required="Dockerfile k8s/deployment.yaml k8s/service.yaml"
  [ "$case_name" = "01-fe-only" ] && expected_names="training-fe-only" || expected_names="training-be-only"
fi

failed=0
for file in $required; do
  if [ ! -s "$dir/$file" ]; then echo "ERROR: missing or empty $dir/$file" >&2; failed=1; fi
done
[ "$failed" -eq 0 ] || exit 1

manifest_files=$(find "$dir/k8s" -type f \( -name '*.yaml' -o -name '*.yml' \) -print)
[ -n "$manifest_files" ] || { echo "ERROR: no Kubernetes YAML files" >&2; exit 1; }

if command -v kubectl >/dev/null 2>&1; then
  kubectl apply --dry-run=client --validate=false -f "$dir/k8s"
  echo "PASS: kubectl client-side dry-run"
elif command -v yq >/dev/null 2>&1; then
  for file in $manifest_files; do yq eval '.' "$file" >/dev/null; done
  echo "PASS: YAML parsed by yq"
else
  echo "WARN: kubectl/yq unavailable; YAML parse and dry-run skipped"
fi

all=$(mktemp)
trap 'rm -f "$all"' EXIT
for file in $manifest_files; do sed 's/#.*$//' "$file" >> "$all"; done

check_present() { grep -Eq "$1" "$all" || { echo "ERROR: $2" >&2; failed=1; }; }
check_absent() { if grep -Eq "$1" "$all"; then echo "ERROR: $2" >&2; failed=1; fi; }

check_present 'namespace:[[:space:]]*k3s-training' "namespace must be k3s-training"
for name in $expected_names; do check_present "name:[[:space:]]*$name([[:space:]]|$)" "missing resource name $name"; done
check_present "training\.hairnerds\.id/deployed-by:[[:space:]]*$participant" "deployed-by annotation must be $participant"
check_present 'training\.hairnerds\.id/git-sha:[[:space:]]*IMAGE_GIT_SHA' "Pod template needs IMAGE_GIT_SHA annotation"
check_present 'type:[[:space:]]*RollingUpdate' "Deployment must use RollingUpdate"
check_present 'maxUnavailable:[[:space:]]*0' "maxUnavailable must be 0"
check_present 'maxSurge:[[:space:]]*1' "maxSurge must be 1"
check_absent 'imagePullPolicy:[[:space:]]*Never' "imagePullPolicy Never is forbidden"
check_absent 'kind:[[:space:]]*(Ingress|Namespace|PersistentVolume|PersistentVolumeClaim)([[:space:]]|$)' "Ingress, Namespace, PV, and PVC are forbidden"

case "$case_name" in
  01-fe-only) check_present 'nodePort:[[:space:]]*30081' "NodePort must be 30081" ;;
  02-be-only)
    check_present 'nodePort:[[:space:]]*30082' "NodePort must be 30082"
    check_present 'readinessProbe:' "backend readinessProbe missing"
    check_present 'livenessProbe:' "backend livenessProbe missing" ;;
  03-fe-be)
    check_present 'nodePort:[[:space:]]*30083' "frontend NodePort must be 30083"
    count=$(grep -Ec 'nodePort:' "$all" || true)
    [ "$count" -eq 1 ] || { echo "ERROR: fullstack must contain exactly one NodePort" >&2; failed=1; }
    check_present 'type:[[:space:]]*ClusterIP' "backend Service must be ClusterIP"
    check_present 'readinessProbe:' "backend readinessProbe missing"
    check_present 'livenessProbe:' "backend livenessProbe missing" ;;
esac

# yq enables exact label/selector comparison without adding a project dependency.
if command -v yq >/dev/null 2>&1; then
  for service in "$dir"/k8s/*service.yaml; do
    service_name=$(yq '.metadata.name' "$service")
    deployment="$dir/k8s/deployment.yaml"
    [ "$case_name" = "03-fe-be" ] && deployment="$dir/k8s/$(basename "$service" -service.yaml)-deployment.yaml"
    selector=$(yq -o=json -I=0 '.spec.selector' "$service")
    labels=$(yq -o=json -I=0 '.spec.template.metadata.labels' "$deployment")
    [ "$selector" = "$labels" ] || { echo "ERROR: selector mismatch for $service_name" >&2; failed=1; }
  done
else
  echo "WARN: yq unavailable; exact Service selector comparison skipped"
fi

[ "$failed" -eq 0 ] || exit 1
echo "PASS: $participant $case_name"
