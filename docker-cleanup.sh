#!/bin/bash

set -e

echo "========================================="
echo "        DOCKER CLEANUP UTILITY"
echo "       by github.com/AhmadShamli"
echo "                 MIT"
echo "========================================="
echo

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root."
  exit 1
fi

echo ">>> Initial Disk Usage"
echo
INITIAL_DISK=$(df -h / | awk 'NR==2 {print $3}')
df -h /
echo
echo ">>> Initial Docker Usage"
docker system df
echo
echo "========================================="
echo "Choose cleanup mode:"
echo "1) Step-by-step cleanup"
echo "2) Single automatic run"
echo "3) Abort"
echo "========================================="
read -p "Enter choice [1-3]: " MODE
echo

run_step() {
  echo
  read -p "Proceed with: $1 ? (y/n): " CONFIRM
  if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
    eval "$2"
  else
    echo "Skipped: $1"
  fi
}

case $MODE in
  1)
    run_step "Remove stopped containers" "docker container prune -f"
    run_step "Remove unused images" "docker image prune -a -f"
    run_step "Remove unused volumes" "docker volume prune -f"
    run_step "Remove build cache" "docker builder prune -a -f"
    ;;
  2)
    echo "Running full cleanup..."
    docker system prune -a --volumes -f
    docker builder prune -a -f
    ;;
  3)
    echo "Aborted."
    exit 0
    ;;
  *)
    echo "Invalid option."
    exit 1
    ;;
esac

echo
echo "========================================="
echo "        CLEANUP COMPLETE"
echo "========================================="
echo

echo ">>> Final Disk Usage"
echo
FINAL_DISK=$(df -h / | awk 'NR==2 {print $3}')
df -h /
echo
echo ">>> Final Docker Usage"
docker system df
echo

echo "========================================="
echo "Storage Difference:"
echo "Before: $INITIAL_DISK used"
echo "After : $FINAL_DISK used"
echo "========================================="
