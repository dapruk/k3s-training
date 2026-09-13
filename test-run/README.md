# Server test run

Smoke-test instructor baseline on server after CI/CD has pushed four images.

This folder does not install K3s or configure aaPanel. Server needs:

- working K3s and `kubectl` access;
- access to container registry;
- repository checkout;
- four images already built and pushed by CI/CD.

## Configure images

```bash
cd test-run
cp images.env.example images.env
```

Edit `images.env`. Use immutable image tags from CI/CD, never shared `latest` only.

## Deploy baseline

```bash
./deploy.sh
```

Script creates namespace `k3s-training`, renders image placeholders in memory, applies instructor baseline, then waits for all rollouts.

## Verify

```bash
./verify.sh
```

For HTTP checks, provide K3s node address:

```bash
NODE_ADDRESS=127.0.0.1 ./verify.sh
```

Remote example:

```bash
NODE_ADDRESS=192.0.2.10 ./verify.sh
```

## Inspect

```bash
../scripts/inspect-active-deployment.sh 01-fe-only
../scripts/inspect-active-deployment.sh 02-be-only
../scripts/inspect-active-deployment.sh 03-fe-be
```

## Cleanup

```bash
./cleanup.sh
```

Cleanup removes training workloads and namespace. Do not use it while participant deployments must remain available.

