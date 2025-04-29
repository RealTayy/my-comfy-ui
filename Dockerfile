FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# 1. Install system dependencies at build time (so they don't have to be re-installed every run)
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git python3 python3-venv python3-pip wget psmisc && \
    rm -rf /var/lib/apt/lists/*

# 2. Create a directory (just for the script)
RUN mkdir -p /root/scripts
WORKDIR /root/scripts

# 3. Copy in your install script (DO NOT run it yet)
COPY install_comfyui.sh /root/scripts/install_comfyui.sh
RUN chmod +x /root/scripts/install_comfyui.sh

# 4. On container startup, run the script.
#    This means each time a new Pod starts, we run the script in the *mounted* /workspace dir.
CMD ["/bin/bash", "-c", "/root/scripts/install_comfyui.sh && cd /workspace/ComfyUI && source venv/bin/activate && python main.py --listen --port 3001" ]
