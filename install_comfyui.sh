#!/usr/bin/env bash
set -euxo pipefail

mkdir -p /workspace
exec > >(tee -a /workspace/comfyui_install.log) 2>&1

echo "=== Starting ComfyUI Installation ==="
date

cd /workspace

if [ -d "ComfyUI" ]; then
    rm -rf ComfyUI
fi

echo "=== Cloning ComfyUI from GitHub ==="
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

echo "=== Creating & Activating Python venv ==="
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

echo "=== Installing PyTorch (CUDA 12.1) ==="
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

echo "=== Installing ComfyUI requirements ==="
pip install -r requirements.txt

echo "=== Installing ComfyUI-Manager ==="
mkdir -p custom_nodes
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
pip install -r requirements.txt

echo "=== Making main.py executable ==="
chmod +x /workspace/ComfyUI/main.py

echo "=== Environment Info ==="
python --version
pip --version
pip freeze | grep -E 'torch|comfyui|pillow|numpy|py|manager|ltdr' || true

echo "=== Freeing port 3001 ==="
fuser -k 3001/tcp || true

echo "=== Done installing. Now the Docker CMD will launch Jupyter & ComfyUI. ==="
