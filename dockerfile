# Debian-based Node LTS (Bookworm) — stable & multi-arch
FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV N8N_USER_FOLDER=/home/node/.n8n
WORKDIR /home/node

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg \
    python3 wget xz-utils \
    ffmpeg imagemagick ghostscript fontconfig \
    # Calibre runtime dependencies
    libgl1 libegl1 libxkbcommon0 libxcb1 libdbus-1-3 libcups2 libnss3 \
    xdg-utils shared-mime-info desktop-file-utils \
  && rm -rf /var/lib/apt/lists/*

# ---- n8n (latest) ----
# Pin if you prefer reproducibility: `npm i -g n8n@<version>`
RUN npm install -g --omit=dev n8n

# ---- Calibre CLI (amd64 only) ----
RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.py \
    | python3 -c "import sys; exec(sys.stdin.read())"

ENV PATH="/opt/calibre:${PATH}"

# (optional) allow ImageMagick to read/write PDF/PS if needed
# RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml || true

# ---- Non-root & data dirs ----
RUN install -d -o node -g node /home/node/.n8n /data

USER node

EXPOSE 5678
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD curl -fsS http://localhost:5678/healthz || exit 1

CMD ["n8n"]
