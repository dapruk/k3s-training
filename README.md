# K3s deployment training

Beginner-friendly Kubernetes deployment practice for experienced developers. Three shared slots run in namespace `k3s-training`:

- FE-only: `training-fe-only`, NodePort `30081`
- BE-only: `training-be-only`, NodePort `30082`
- FE + BE: frontend `training-fullstack-fe`, NodePort `30083`; private backend `training-fullstack-be`

Instructor deploys baseline, replacement demo, then Akmal → Fajrian → Zal → Fahmi → Jale → Akhdan. Every submission uses same resource names. `kubectl apply` updates existing objects; same Services, domains, NodePorts stay active.

## Why Dockerfiles and YAML?

Participants need no local Docker, K3s, WSL, or kubectl. Dockerfile tells CI/CD how to build image. CI/CD pushes immutable image. Kubernetes YAML tells K3s how to run it.

Expected image pattern:

```text
<registry>/k3s-training/fe-only:<participant>-<git-sha>
<registry>/k3s-training/be-only:<participant>-<git-sha>
<registry>/k3s-training/fullstack-fe:<participant>-<git-sha>
<registry>/k3s-training/fullstack-be:<participant>-<git-sha>
```

Registry remains configurable because repo contains no existing CI/CD convention.

## Failure types

- Application failure: image runs, app behavior wrong.
- Image build failure: CI cannot build Dockerfile.
- YAML validation failure: manifest syntax/policy wrong; deployment never starts.
- Rollout failure: valid manifest applied, new Pod never becomes Ready. RollingUpdate plus readiness probes keep previous healthy Pod serving.

See [training flow](docs/TRAINING_FLOW.md), [participant guide](docs/PARTICIPANT_GUIDE.md), [instructor guide](docs/INSTRUCTOR_GUIDE.md).

Server smoke-test workflow: [test-run guide](test-run/README.md). It deploys baseline using CI-built immutable images; it does not install or configure server infrastructure.
