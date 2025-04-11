#!/bin/bash
set -e

source ./config/guest-params.env
mkdir -p logs

echo "[GUEST] Running GPU checks inside the guest..." | tee -a logs/test.log

function gssh() {
  ssh -p "$SSH_PORT" -o StrictHostKeyChecking=no "$SSH_USER@$GUEST_IP" "$1"
}

tests_passed=0
tests_failed=0

run_test() {
  desc=$1
  cmd=$2
  expected=$3
  echo -n "[TEST] $desc... " | tee -a logs/test.log
  out=$(gssh "$cmd" 2>/dev/null)
  echo "$out" >> logs/test.log
  echo "$out" | grep -q "$expected" && { echo "passed" | tee -a logs/test.log; ((tests_passed++)); } || { echo "Failed" | tee -a logs/test.log; ((tests_failed++)); }
}

run_test "Check if GPU is visible via lspci" "lspci | grep -i virtio" "Virtio"
run_test "Check if virtio_gpu module is loaded" "lsmod | grep virtio_gpu || modprobe virtio_gpu" "virtio_gpu"
run_test "Check for /dev/dri/card0" "ls -l /dev/dri/" "card0"
run_test "Check OpenGL renderer is virgl" "glxinfo | grep 'OpenGL renderer'" "virgl"
run_test "Run glxgears for basic rendering" "timeout 5 glxgears -info" "OpenGL renderer"
run_test "Run glmark2 benchmark" "glmark2 --run-forever --benchmark refract --frames 60" "glmark2 Score"

echo -e "\n[GUEST] Passed $tests_passed passed, failed $tests_failed failed" | tee -a results/result_summary.txt

