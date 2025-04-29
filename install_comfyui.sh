#!/usr/bin/env bash
set -euxo pipefail

mkdir -p /workspace
exec > >(tee -a /workspace/comfyui_install.log) 2>&1

echo "=== Starting ComfyUI Installation ==="
date

# 1. Go into /workspace (the volume mount)
cd /workspace

# 2. Remove old ComfyUI folder if you want a fresh clone each time
if [ -d "ComfyUI" ]; then
    rm -rf ComfyUI
fi

# 3. Clone ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# 4. Create/activate venv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip

# 5. Install PyTorch & ComfyUI deps
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install -r requirements.txt

# 6. Install ComfyUI-Manager
mkdir -p custom_nodes
cd custom_nodes
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
pip install -r requirements.txt

# 7. Make main.py executable
chmod +x /workspace/ComfyUI/main.py

# 8. Log environment info
echo "=== Environment Info ==="
python --version
pip --version
pip freeze | grep -E 'torch|comfyui|pillow|numpy|py|manager|ltdr' || true

# 9. Free port 3001 in case something is stuck
fuser -k 3001/tcp || true

echo "=== Done installing. Jupyter & ComfyUI will be launched now. ==="
