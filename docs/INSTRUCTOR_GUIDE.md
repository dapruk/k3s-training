# Instructor guide

1. Configure `REGISTRY`/tags in CI.
2. Deploy baseline; verify all three apps.
3. Deploy replacement demo.
4. Show unchanged names, Services, NodePorts.
5. Participants create independent PRs.
6. Validate each PR.
7. Deploy one participant at a time.
8. Wait for rollout before next participant.
9. Diagnose failures.
10. Undo rollout or restore baseline.

Example:

```bash
kubectl apply -f instructor/baseline/01-fe-only/k8s/
kubectl rollout status deployment/training-fe-only -n k3s-training
curl http://NODE_IP:30081
kubectl apply -f instructor/replacement-demo/01-fe-only/k8s/
./scripts/inspect-active-deployment.sh 01-fe-only
```

Replace image placeholders through existing CI/CD before deployment.

Diagnostics:

```bash
kubectl get pods -n k3s-training
kubectl get deployments -n k3s-training
kubectl get services -n k3s-training
kubectl describe pod <pod-name> -n k3s-training
kubectl logs <pod-name> -n k3s-training
kubectl rollout status deployment/<name> -n k3s-training
kubectl rollout history deployment/<name> -n k3s-training
kubectl rollout undo deployment/<name> -n k3s-training
```

If rollout fails, do not delete healthy Deployment. Inspect events/logs; undo or reapply instructor baseline.
