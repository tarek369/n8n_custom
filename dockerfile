# Debian-based Node LTS (Bookworm) — stable & multi-arch
FROM node:20-bookworm-slim

# BuildKit provides TARGETARCH (amd64/arm64)
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive
ENV N8N_USER_FOLDER=/home/node/.n8n
WORKDIR /home/node

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg \
    python3 wget xz-utils \
    ffmpeg imagemagick ghostscript fontconfig \
  && rm -rf /var/lib/apt/lists/*

# ---- n8n (latest) ----
# Pin if you prefer reproducibility: `npm i -g n8n@<version>`
RUN npm install -g --omit=dev n8n

# ---- Calibre CLI ----
# - amd64: upstream installer (latest)
# - arm64: Debian package (works on ARM; may be older)
RUN if [ "${TARGETARCH}" = "amd64" ]; then \
      wget -nv -O- https://download.calibre-ebook.com/linux-installer.py \
      | python3 -c "import sys; exec(sys.stdin.read())"; \
    else \
      apt-get update && apt-get install -y --no-install-recommends calibre && \
      rm -rf /var/lib/apt/lists/*; \
    fi
ENV PATH="/opt/calibre:${PATH}"

# (optional) allow ImageMagick to read/write PDF/PS if needed
# RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml || true

# ---- Non-root & data dirs ----
# 'node' user already exists in node:* images — just ensure dirs/ownership
RUN install -d -o node -g node /home/node/.n8n /data

USER node

EXPOSE 5678
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD curl -fsS http://localhost:5678/healthz || exit 1

CMD ["n8n"]
