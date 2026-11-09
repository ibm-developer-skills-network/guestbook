#!/usr/bin/env bash
# Runs the Guestbook final project end to end on a local kind cluster
# (for GitHub Codespaces or any Linux machine with Docker; no IBM Cloud needed).
#
# IBM Cloud Container Registry (us.icr.io) is replaced by a local registry on
# localhost:5001, so `docker push` still prints a real digest line.
#
# Each task's terminal output is saved to final-project/outputs/taskN.txt.
#
# Usage:  bash final-project/run-final-project.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/v1/guestbook"
OUT="$ROOT/final-project/outputs"
WORK="$(mktemp -d)"
CLUSTER=guestbook
REG_NAME=kind-registry
REG_PORT=5001
IMAGE="localhost:${REG_PORT}/guestbook:v1"
KIND_VERSION=v0.24.0
KUBECTL_VERSION=v1.31.0
METRICS_SERVER_VERSION=v0.7.2
# Optional extra flags for `docker build` (e.g. behind a proxy).
EXTRA_BUILD_ARGS="${EXTRA_BUILD_ARGS:-}"

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

# run "<command>" <output-file>: prints the command like a terminal prompt,
# runs it, and appends both to outputs/<output-file>.
run() {
  local cmd="$1" file="$2" rc=0
  echo "\$ $cmd" | tee -a "$OUT/$file"
  bash -c "$cmd" 2>&1 | tee -a "$OUT/$file" || rc=$?
  echo | tee -a "$OUT/$file"
  return "$rc"
}

cd "$ROOT"
rm -rf "$OUT"
mkdir -p "$OUT"

# ---------------------------------------------------------------- tools
step "Checking tools (docker, kind, kubectl)"
command -v docker >/dev/null || { echo "Docker is required." >&2; exit 1; }
docker info >/dev/null 2>&1 || { echo "Docker daemon is not running." >&2; exit 1; }

case "$(uname -m)" in
  x86_64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported CPU architecture: $(uname -m)" >&2; exit 1 ;;
esac

if ! command -v kind >/dev/null; then
  curl -fsSLo "$WORK/kind" "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
  $SUDO install -m 0755 "$WORK/kind" /usr/local/bin/kind
fi
if ! command -v kubectl >/dev/null; then
  curl -fsSLo "$WORK/kubectl" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
  $SUDO install -m 0755 "$WORK/kubectl" /usr/local/bin/kubectl
fi
kind version
kubectl version --client

# ------------------------------------------------- registry + cluster
step "Starting local image registry on localhost:${REG_PORT}"
if [ "$(docker inspect -f '{{.State.Running}}' "$REG_NAME" 2>/dev/null || true)" != "true" ]; then
  docker rm -f "$REG_NAME" >/dev/null 2>&1 || true
  docker run -d --restart=always -p "127.0.0.1:${REG_PORT}:5000" --network bridge \
    --name "$REG_NAME" registry:2 >/dev/null
fi

step "Creating kind cluster '${CLUSTER}' (takes 1-2 minutes)"
kind delete cluster --name "$CLUSTER" >/dev/null 2>&1 || true
cat <<EOF | kind create cluster --name "$CLUSTER" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry]
    config_path = "/etc/containerd/certs.d"
EOF

# Let the cluster pull localhost:5001/... from the registry container.
for node in $(kind get nodes --name "$CLUSTER"); do
  docker exec "$node" mkdir -p "/etc/containerd/certs.d/localhost:${REG_PORT}"
  printf '[host."http://%s:5000"]\n' "$REG_NAME" |
    docker exec -i "$node" cp /dev/stdin "/etc/containerd/certs.d/localhost:${REG_PORT}/hosts.toml"
done
docker network connect kind "$REG_NAME" 2>/dev/null || true

# Optional: preload images into the cluster (space-separated list).
for img in ${PRELOAD_IMAGES:-}; do
  kind load docker-image "$img" --name "$CLUSTER"
done

step "Installing metrics-server (needed by the autoscaler)"
kubectl apply -f "https://github.com/kubernetes-sigs/metrics-server/releases/download/${METRICS_SERVER_VERSION}/components.yaml"
kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server --timeout=300s

# ------------------------------------------- v1 sources and manifests
# The repo already holds the v2 changes (index.html v2, CPU 5m/2m), so the
# original v1 state is rebuilt in a temporary copy for tasks 2-5.
cp -r "$APP" "$WORK/v1"
sed -i "s|<title>Guestbook - v2</title>|<title>Lavanya's Guestbook - v1</title>|; s|<h1>Guestbook - v2</h1>|<h1>Guestbook - v1</h1>|" \
  "$WORK/v1/public/index.html"
sed "s|us.icr.io/<your sn labs namespace>/guestbook:v1|${IMAGE}|; s|cpu: 5m|cpu: 50m|; s|cpu: 2m|cpu: 20m|" \
  "$APP/deployment.yml" > "$WORK/deployment-v1.yml"
sed "s|us.icr.io/<your sn labs namespace>/guestbook:v1|${IMAGE}|" \
  "$APP/deployment.yml" > "$WORK/deployment-v2.yml"

# ---------------------------------------------------------------- task 1
step "Task 1: Dockerfile"
run "cat v1/guestbook/Dockerfile" task1_dockerfile.txt >/dev/null
cat "$OUT/task1_dockerfile.txt"

# ---------------------------------------------------------------- task 2
step "Task 2: build and push v1 image"
run "cd '$WORK/v1' && docker build ${EXTRA_BUILD_ARGS:+$EXTRA_BUILD_ARGS }. -t ${IMAGE} && docker push ${IMAGE}" task2_build_push_v1.txt
run "curl -s http://localhost:${REG_PORT}/v2/guestbook/tags/list" task2_build_push_v1.txt
run "docker images localhost:${REG_PORT}/guestbook" task2_build_push_v1.txt

# ---------------------------------------------------------------- task 3
step "Task 3: default index.html"
{ echo "\$ grep -n -E '<title>|<h1>' public/index.html"
  grep -n -E '<title>|<h1>' "$WORK/v1/public/index.html"; } | tee "$OUT/task3_index_v1.txt"

# --------------------------------------------------------- deploy v1
step "Deploying guestbook v1"
run "cd '$WORK' && cp deployment-v1.yml deployment.yml && kubectl apply -f deployment.yml" deploy_v1.txt
kubectl rollout status deployment/guestbook --timeout=300s
run "kubectl expose deployment guestbook --port=3000 --target-port=3000" deploy_v1.txt
run "kubectl get deployments,pods,svc" deploy_v1.txt

# ---------------------------------------------------------------- task 4
step "Task 4: create the Horizontal Pod Autoscaler"
run "kubectl autoscale deployment guestbook --cpu-percent=5 --min=1 --max=10" task4_hpa.txt
run "kubectl get hpa guestbook" task4_hpa.txt

step "Waiting for CPU metrics to show up in the HPA (up to 3 minutes)"
for _ in $(seq 1 36); do
  if kubectl get hpa guestbook --no-headers 2>/dev/null | grep -qv unknown; then break; fi
  sleep 5
done
kubectl get hpa guestbook

# ---------------------------------------------------------------- task 5
step "Task 5: generate load and watch the HPA scale out (about 4 minutes)"
kubectl delete pod load-generator --ignore-not-found >/dev/null
kubectl run load-generator --image=busybox:1.36.0 --restart=Never -- \
  /bin/sh -c "while sleep 0.01; do wget -q -O- http://guestbook:3000; done"
run "timeout 240 kubectl get hpa guestbook --watch || true" task5_hpa_scaling.txt
run "kubectl get hpa guestbook" task5_hpa_scaling.txt
run "kubectl get pods -l app=guestbook" task5_hpa_scaling.txt
kubectl delete pod load-generator --ignore-not-found

# ---------------------------------------------------------------- task 6
step "Task 6: build and push the updated (v2) image"
run "cd '$APP' && docker build ${EXTRA_BUILD_ARGS:+$EXTRA_BUILD_ARGS }. -t ${IMAGE} && docker push ${IMAGE}" task6_push_v2.txt

# ---------------------------------------------------------------- task 7
step "Task 7: apply the updated deployment (CPU 5m / 2m)"
run "cd '$WORK' && cp deployment-v2.yml deployment.yml && kubectl apply -f deployment.yml" task7_apply.txt
kubectl rollout status deployment/guestbook --timeout=300s

# ---------------------------------------------------------------- task 8
step "Task 8: updated index.html"
{ echo "\$ grep -n -E '<title>|<h1>' public/index.html"
  grep -n -E '<title>|<h1>' "$APP/public/index.html"; } | tee "$OUT/task8_index_v2.txt"

# ---------------------------------------------------------------- task 9
step "Task 9: rollout history"
run "kubectl rollout history deployment/guestbook" task9_rollout_history.txt
run "kubectl rollout history deployments guestbook --revision=2" task9_rollout_history.txt

# --------------------------------------------------------------- task 10
step "Task 10: roll back to revision 1 and list ReplicaSets"
run "kubectl rollout undo deployment/guestbook --to-revision=1" task10_rollback_rs.txt
kubectl rollout status deployment/guestbook --timeout=300s
run "kubectl get rs" task10_rollback_rs.txt

# ------------------------------------------------------------------ done
# Hide the temporary directory path from the saved outputs.
sed -i -e "s#cd '$WORK/v1' && ##" -e "s#cd '$WORK' && cp deployment-v[12].yml deployment.yml && ##" \
  -e "s#cd '$APP' && ##" -e "s#timeout 240 ##" -e "s# || true##" "$OUT"/*.txt
rm -rf "$WORK"

step "Done. Outputs saved in final-project/outputs/:"
ls -1 "$OUT"
echo
echo "To delete the cluster afterwards:  kind delete cluster --name ${CLUSTER}"
