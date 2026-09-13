# Akmal: FE + BE assignment

Create:

- `frontend/Dockerfile`: Nginx Alpine, port 80
- `frontend/nginx.conf`: serve static files; proxy `/api/` to `http://training-fullstack-be:3000`
- `backend/Dockerfile`: Node.js 22 Alpine, port 3000
- `k8s/frontend-deployment.yaml`: `training-fullstack-fe`
- `k8s/frontend-service.yaml`: `training-fullstack-fe`, NodePort `30083`
- `k8s/backend-deployment.yaml`: `training-fullstack-be`, probes on `/health`
- `k8s/backend-service.yaml`: `training-fullstack-be`, ClusterIP only

Frontend browser request must remain `/api/name`; Nginx resolves internal backend Service. Use namespace `k3s-training`, one replica, RollingUpdate (`maxUnavailable: 0`, `maxSurge: 1`), matching labels/selectors, small resource requests/limits, and immutable image `<registry>/k3s-training/fullstack-fe:akmal-<git-sha>`.

Add Deployment and Pod-template annotation `k3s-training/deployed-by: akmal`. Pod template also needs `k3s-training/git-sha: IMAGE_GIT_SHA`. Do not use `imagePullPolicy: Never`. Do not create Namespace, Ingress, PV, or PVC. Backend image: `<registry>/k3s-training/fullstack-be:akmal-<git-sha>`.
