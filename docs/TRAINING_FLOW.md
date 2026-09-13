# Training flow

One namespace, three shared slots, sequential owners:

```text
Instructor baseline → Instructor replacement demo → Akmal → Fajrian → Zal → Fahmi → Jale → Akhdan
```

Each apply targets identical resource names. It updates current Deployment and keeps Service/NodePort stable. Submissions never run concurrently. Readiness probes block unhealthy new backend Pods from traffic. `maxUnavailable: 0` keeps healthy version during rollout.
