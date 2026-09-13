# Participant guide

```text
Create branch → edit only your folder → write Dockerfile and YAML → commit → push → create PR → fix validation → wait for turn → inspect rollout through SSH
```

Do not edit instructor folders, another participant folder, shared scripts, or CI/CD unless assigned.

Validate before PR:

```bash
./scripts/validate-submission.sh <your-slug> <case>
```

Required YAML: namespace `k3s-training`; fixed names/ports; one replica; RollingUpdate with `maxUnavailable: 0`, `maxSurge: 1`; matching labels/selectors; backend probes; small resources; correct annotation; immutable CI image placeholder. Never use `imagePullPolicy: Never`. Do not create Namespace, Ingress, PV, PVC, DB, or expose fullstack backend.

Annotations:

```yaml
k3s-training/deployed-by: <slug>
k3s-training/git-sha: IMAGE_GIT_SHA
```
