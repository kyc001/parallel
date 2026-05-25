#!/bin/bash
# Automated Kunpeng testing for non-blocking MPI
# This script syncs code, builds, and runs experiments on Kunpeng server

set -e

REMOTE_USER="s2413575"
JUMP_HOST="10.137.144.91"
JUMP_PORT="9001"
TARGET_HOST="192.168.90.141"
REMOTE_DIR="ann-mpi"

echo "=== Syncing code to Kunpeng server ==="

# Sync main.cc
echo "Syncing main.cc..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o "ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $JUMP_PORT -W %h:%p $REMOTE_USER@$JUMP_HOST" \
  main.cc $REMOTE_USER@$TARGET_HOST:~/$REMOTE_DIR/

# Sync script
echo "Syncing test script..."
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o "ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $JUMP_PORT -W %h:%p $REMOTE_USER@$JUMP_HOST" \
  scripts/run_blocking_vs_nonblocking_kunpeng.sh $REMOTE_USER@$TARGET_HOST:~/$REMOTE_DIR/scripts/

echo "=== Building on Kunpeng server ==="

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o "ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $JUMP_PORT -W %h:%p $REMOTE_USER@$JUMP_HOST" \
  $REMOTE_USER@$TARGET_HOST << 'ENDSSH'
cd ~/ann-mpi
echo "Cleaning..."
make clean
echo "Building..."
make
echo "Build complete!"
ENDSSH

echo "=== Running experiments on Kunpeng server ==="

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o "ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $JUMP_PORT -W %h:%p $REMOTE_USER@$JUMP_HOST" \
  $REMOTE_USER@$TARGET_HOST << 'ENDSSH'
cd ~/ann-mpi
chmod +x scripts/run_blocking_vs_nonblocking_kunpeng.sh
bash scripts/run_blocking_vs_nonblocking_kunpeng.sh
ENDSSH

echo "=== Downloading results ==="

RESULT_FILE=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -o "ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $JUMP_PORT -W %h:%p $REMOTE_USER@$JUMP_HOST" \
  $REMOTE_USER@$TARGET_HOST "ls -t ~/ann-mpi/results/blocking_vs_nonblocking_kunpeng_*.txt 2>/dev/null | head -1" || echo "")

if [ -n "$RESULT_FILE" ]; then
  RESULT_BASENAME=$(basename "$RESULT_FILE")
  scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -o "ProxyCommand=ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $JUMP_PORT -W %h:%p $REMOTE_USER@$JUMP_HOST" \
    $REMOTE_USER@$TARGET_HOST:$RESULT_FILE results/
  echo "Results downloaded to: results/$RESULT_BASENAME"
else
  echo "Warning: No result file found"
fi

echo "=== Done! ==="
