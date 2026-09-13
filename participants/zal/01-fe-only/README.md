# Zal: FE-only assignment

Create:

- `Dockerfile` using Nginx Alpine, listening on port 80
- `k8s/deployment.yaml`: `training-fe-only`
- `k8s/service.yaml`: `training-fe-only`, NodePort `30081`, port/targetPort `80`

Use namespace `k3s-training`, one replica, RollingUpdate (`maxUnavailable: 0`, `maxSurge: 1`), matching labels/selectors, small resource requests/limits, and immutable image `<registry>/k3s-training/fe-only:zal-<git-sha>`.

Add Deployment and Pod-template annotation `training.hairnerds.id/deployed-by: zal`. Pod template also needs `training.hairnerds.id/git-sha: IMAGE_GIT_SHA`. Do not use `imagePullPolicy: Never`. Do not create Namespace, Ingress, PV, or PVC.
