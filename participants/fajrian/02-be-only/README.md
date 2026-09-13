# Fajrian: BE-only assignment

Create:

- `Dockerfile` using Node.js 22 Alpine, listening on port 3000
- `k8s/deployment.yaml`: `training-be-only`, readiness/liveness probes on `/health`
- `k8s/service.yaml`: `training-be-only`, NodePort `30082`, port/targetPort `3000`

Use namespace `k3s-training`, one replica, RollingUpdate (`maxUnavailable: 0`, `maxSurge: 1`), matching labels/selectors, small resource requests/limits, and immutable image `<registry>/k3s-training/be-only:fajrian-<git-sha>`.

Add Deployment and Pod-template annotation `k3s-training/deployed-by: fajrian`. Pod template also needs `k3s-training/git-sha: IMAGE_GIT_SHA`. Do not use `imagePullPolicy: Never`. Do not create Namespace, Ingress, PV, or PVC.
