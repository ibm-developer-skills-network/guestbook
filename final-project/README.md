# Guestbook final project: running it without the IBM lab

`run-final-project.sh` runs every task in the final project on a local Kubernetes
cluster (kind) inside GitHub Codespaces. It saves each task's terminal output to
`final-project/outputs/`.

## How to run (GitHub Codespaces)

1. Open https://github.com/westnur/guestbook and switch to the `final-project` branch.
2. Click **Code → Codespaces → Create codespace on final-project**.
3. Once the terminal opens, run:

   ```bash
   bash final-project/run-final-project.sh
   ```

4. It takes about 10–15 minutes. When it finishes, the results are in `final-project/outputs/`.

## Which file answers which task

| Task | File |
|---|---|
| 1. Dockerfile | `task1_dockerfile.txt` |
| 2. Image pushed with tag v1 | `task2_build_push_v1.txt` (see the note below) |
| 3. Default index.html | `task3_index_v1.txt` |
| 4. HPA created with 0 replicas | `task4_hpa.txt` |
| 5. Replica count increasing | `task5_hpa_scaling.txt` |
| 6. Push of the updated image + digest | `task6_push_v2.txt` (copy from the end through the `digest:` line) |
| 7. `kubectl apply -f deployment.yml` | `task7_apply.txt` |
| 8. index.html "Guestbook - v2" | `task8_index_v2.txt` |
| 9. Rollout history (CPU change) | `task9_rollout_history.txt` |
| 10. `kubectl get rs` after rollback | `task10_rollback_rs.txt` |

## Notes

- IBM Cloud Container Registry (`us.icr.io`) is not available here, so the image
  goes to a local registry (`localhost:5001`). Task 2 needs `ibmcloud cr images`,
  which only runs in the IBM lab. Task 6 shows a real `docker push` and digest,
  but the registry address differs from the IBM one.
- The repository already holds the v2 state (index.html v2, CPU 5m/2m). The
  script builds the original v1 state in a temporary copy for tasks 2–5.
- To delete the cluster afterwards: `kind delete cluster --name guestbook`
