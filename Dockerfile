FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

##############################################################################
# 1. OS-level installs at build time
##############################################################################
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git python3 python3-venv python3-pip wget psmisc && \
    rm -rf /var/lib/apt/lists/*

# Install JupyterLab so we don’t re-download it each container start
RUN pip3 install --no-cache-dir jupyterlab

##############################################################################
# 2. Copy your ComfyUI install script, but DO NOT run it yet
##############################################################################
# We do NOT run the ComfyUI install script at build time because RunPod mounts an empty volume 
# at /workspace when the container starts, overwriting anything baked into that path. 
# Instead, we run the script in CMD after the volume is mounted, ensuring ComfyUI is correctly 
# installed inside /workspace every time the container launches.

RUN mkdir -p /root/scripts
WORKDIR /root/scripts

COPY install_comfyui.sh /root/scripts/install_comfyui.sh
RUN chmod +x install_comfyui.sh

##############################################################################
# 3. Final CMD: Install ComfyUI at startup into /workspace + Start Jupyter
##############################################################################
# Explanation:
#  - The script runs after RunPod mounts an empty volume at /workspace.
#  - It clones & pip-installs ComfyUI into /workspace.
#  - We launch Jupyter in background (port 8888), then launch ComfyUI in foreground (port 3001).
CMD ["/bin/bash", "-c", "\
  /root/scripts/install_comfyui.sh && \
  jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' & \
  cd /workspace/ComfyUI && \
  source venv/bin/activate && \
  python main.py --listen --port 3001 \
"]
