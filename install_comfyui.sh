#!/usr/bin/env bash
#
# ComfyUI Install Script
# - Designed for RunPod or similar ephemeral environments
# - Combines best-practice suggestions for robust, future-proof installation
# - Logs everything for easier debugging

##############################################################################
#  1. Enable Strict Modes & Set Up Logging
##############################################################################
# Exit immediately on error (-e), treat unset variables as errors (-u),
# print commands before executing (-x), and capture pipeline failures (pipefail).
set -euxo pipefail

# Redirect all script output (stdout + stderr) to a logfile AND the console.
# This way you can see everything in real-time and also have a saved log.
mkdir -p /workspace
exec > >(tee -a /workspace/comfyui_install.log) 2>&1

##############################################################################
#  2. Check Python & Pip Versions
##############################################################################

echo "=== Checking Python version ==="
python3 --version || true
pip3 --version || true

##############################################################################
#  3. Stop & Disable nginx (If Present)
##############################################################################
# In many RunPod environments, you may not need nginx at all. This ensures
# it won't conflict with ComfyUI on the same ports.
echo "=== Stopping and disabling any existing Nginx ==="
systemctl stop nginx 2>/dev/null || true
systemctl disable nginx 2>/dev/null || true
pkill -f nginx || true
# Optional: remove nginx if you never use it
# apt remove -y nginx || true

##############################################################################
#  4. Set Up Workspace
##############################################################################
echo "=== Ensuring /workspace directory exists and moving there ==="
cd /workspace

##############################################################################
#  5. (Optional) Remove Existing Folders for a Fresh Install
##############################################################################
# If you prefer updating instead of deleting, you can replace this with a
# `git pull` approach. For full “fresh install” reliability, removal is simpler.
if [ -d "ComfyUI" ]; then
  echo "!!! Existing /workspace/ComfyUI found. Removing for a clean install."
  rm -rf ComfyUI
fi

##############################################################################
#  6. Clone ComfyUI & Set Up Python Virtual Environment
##############################################################################
echo "=== Cloning ComfyUI from GitHub ==="
git clone https://github.com/comfyanonymous/ComfyUI.git

cd ComfyUI
echo "=== Creating & Activating Python venv ==="
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

##############################################################################
#  7. Install PyTorch & ComfyUI Requirements
##############################################################################
# Make sure the CUDA version matches your RunPod template (cu121 for CUDA 12.1).
# If, in the future, RunPod changes CUDA versions, you can either update
# cu121 => cu118, cu116, etc., or detect it conditionally.
echo "=== Installing PyTorch (CUDA 12.1) ==="
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

echo "=== Installing ComfyUI requirements ==="
pip install -r requirements.txt

##############################################################################
#  8. Install ComfyUI-Manager (Inside 'custom_nodes')
##############################################################################
echo "=== Installing ComfyUI-Manager ==="
mkdir -p custom_nodes
cd custom_nodes

if [ -d "ComfyUI-Manager" ]; then
  echo "!!! ComfyUI-Manager directory found. Removing for a clean install."
  rm -rf ComfyUI-Manager
fi

git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
pip install -r requirements.txt

##############################################################################
#  9. Permission Fixes & Logging of Final Environment
##############################################################################
echo "=== Making main.py executable ==="
chmod +x /workspace/ComfyUI/main.py

# Log final Python environment details to help with debugging
echo "=== Final Python & Package Versions ==="
python --version
pip --version
pip freeze | grep -E 'torch|comfyui|pillow|numpy|py|manager|ltdr' || true

##############################################################################
#  10. Free Port & Launch ComfyUI
##############################################################################
# In ephemeral container environments, you typically run ComfyUI in the foreground.
# Using fuser ensures port 3001 is freed up in case a leftover process is hanging.
echo "=== Freeing port 3001 (if any process is using it) ==="
fuser -k 3001/tcp || true

echo "=== Launching ComfyUI on port 3001 ==="
cd /workspace/ComfyUI
source venv/bin/activate

# Optionally redirect ComfyUI logs to a file:
# python main.py --listen --port 3001 &> /workspace/comfyui_run.log
# But for now, run in the foreground so we see logs directly:
# python main.py --listen --port 3001
