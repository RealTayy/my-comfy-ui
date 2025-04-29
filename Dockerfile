# Dockerfile
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# 1. Install system dependencies at build time
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git python3 python3-venv python3-pip wget psmisc && \
    rm -rf /var/lib/apt/lists/*

# 2. Also install JupyterLab at build time (so we don't re-download each container start)
RUN pip3 install --no-cache-dir jupyterlab

# 3. Create a scripts directory and copy your ComfyUI install script there
RUN mkdir -p /root/scripts
WORKDIR /root/scripts

COPY install_comfyui.sh /root/scripts/install_comfyui.sh
RUN chmod +x /root/scripts/install_comfyui.sh

# 4. When the container starts on RunPod:
#    - Run the ComfyUI install script (this populates /workspace with a new clone if needed).
#    - Launch Jupyter in background on port 8888.
#    - Launch ComfyUI in foreground on port 3001.
CMD ["/bin/bash", "-c", "\
  /root/scripts/install_comfyui.sh && \
  jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token='' & \
  cd /workspace/ComfyUI && \
  source venv/bin/activate && \
  python main.py --listen --port 3001 \
"]
