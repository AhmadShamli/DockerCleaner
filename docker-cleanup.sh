#!/bin/bash

set -e

# Script configuration
SCRIPT_NAME="docker-cleanup.sh"
SCRIPT_VERSION="1.1.0"
INSTALL_PATH="/usr/local/bin/docker-cleanup"

echo "========================================="
echo "        DOCKER CLEANUP UTILITY"
echo "       by github.com/AhmadShamli"
echo "                 MIT"
echo "           Version: $SCRIPT_VERSION"
echo "========================================="
echo

# Check if script is already installed
check_installation() {
  if [ -f "$INSTALL_PATH" ]; then
    INSTALLED_VERSION=$(grep -E '^SCRIPT_VERSION="' "$INSTALL_PATH" | sed 's/SCRIPT_VERSION="//;s/"//')
    echo "Script is already installed at: $INSTALL_PATH"
    echo "Installed version: $INSTALLED_VERSION"
    echo "Current version: $SCRIPT_VERSION"
    echo
    if [ "$INSTALLED_VERSION" = "$SCRIPT_VERSION" ]; then
      echo "✓ Already running the latest version"
    else
      echo "⚠️  Newer version available"
    fi
    echo
  else
    echo "Script is not installed"
    echo
  fi
}

# Install script to /usr/local/bin
install_script() {
  echo "Installing script to $INSTALL_PATH..."
  
  # Copy current script to installation directory
  cp "$(readlink -f "$0")" "$INSTALL_PATH"
  
  # Make sure it's executable
  chmod +x "$INSTALL_PATH"
  
  echo "✓ Installation successful!"
  echo
  echo "Now you can run the script from anywhere using: docker-cleanup"
}

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
while true; do
  echo "========================================="
  echo "Choose an option:"
  echo "1) Step-by-step cleanup"
  echo "2) Single automatic run"
  echo "3) Install script (system-wide)"
  echo "4) Check installation status"
  echo "5) Exit"
  echo "========================================="
  read -p "Enter choice [1-5]: " MODE
  echo

  case $MODE in
    1)
      run_step() {
        echo
        read -p "Proceed with: $1 ? (y/n): " CONFIRM
        if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
          eval "$2"
        else
          echo "Skipped: $1"
        fi
      }

      run_step "Remove stopped containers" "docker container prune -f"
      run_step "Remove unused images" "docker image prune -a -f"
      run_step "Remove unused volumes" "docker volume prune -f"
      run_step "Remove build cache" "docker builder prune -a -f"
      
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
      ;;
    2)
      echo "Running full cleanup..."
      docker system prune -a --volumes -f
      docker builder prune -a -f
      
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
      ;;
    3)
      install_script
      ;;
    4)
      check_installation
      ;;
    5)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
done
