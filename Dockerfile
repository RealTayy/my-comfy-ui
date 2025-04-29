# Dockerfile
FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

# 1. Update and install system dependencies
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y git python3 python3-venv python3-pip wget psmisc && \
    rm -rf /var/lib/apt/lists/*

# 2. Create a workspace folder
RUN mkdir -p /workspace
WORKDIR /workspace

# 3. Copy in your install script
COPY install_comfyui.sh /workspace/install_comfyui.sh
RUN chmod +x /workspace/install_comfyui.sh

# 4. (Optional but recommended) Run the script at build time
#    This means your final image ALREADY has ComfyUI installed.
#    If you want to run it at container startup instead, skip this step and do a CMD below.
RUN /workspace/install_comfyui.sh

# 5. By default, run ComfyUI when the container starts.
#    Because your install script ends by launching ComfyUI, we might only need:
CMD [ "bash", "-c", "cd /workspace/ComfyUI && source venv/bin/activate && python main.py --listen --port 3001" ]
