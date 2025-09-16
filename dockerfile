# Debian-based Node LTS (Bookworm)
FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg \
    python3 wget xz-utils \
    ffmpeg imagemagick ghostscript fontconfig \
  && rm -rf /var/lib/apt/lists/*

# n8n
RUN npm install -g --omit=dev n8n

# Calibre: upstream on amd64, Debian pkg on arm64
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      wget -nv -O- https://download.calibre-ebook.com/linux-installer.py \
      | python3 -c "import sys; exec(sys.stdin.read())"; \
    else \
      apt-get update && apt-get install -y --no-install-recommends calibre && \
      rm -rf /var/lib/apt/lists/*; \
    fi
ENV PATH="/opt/calibre:${PATH}"

# Non-root user
RUN useradd -m -u 1000 -s /bin/bash node \
 && mkdir -p /home/node/.n8n /data \
 && chown -R node:node /home/node /data
USER node
ENV N8N_USER_FOLDER=/home/node/.n8n
WORKDIR /home/node

EXPOSE 5678
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD curl -fsS http://localhost:5678/healthz || exit 1
CMD ["n8n"]
