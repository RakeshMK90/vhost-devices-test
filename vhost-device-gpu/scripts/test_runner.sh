#!/bin/bash
mkdir -p logs results
: > results/result_summary.txt

echo "[RUNNER] Running vhost-device-gpu test suite..."
bash scripts/host_setup.sh
bash scripts/guest_gpu_test.sh

echo "[RUNNER] Test complete. Summary below:"
cat results/result_summary.txt
