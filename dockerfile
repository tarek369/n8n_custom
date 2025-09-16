# Modern Debian base
FROM debian:bookworm-slim

# -------- system deps --------
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg \
    python3 wget xz-utils \
    ffmpeg imagemagick ghostscript \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*

# -------- Node.js LTS (20.x) --------
# (n8n supports Node >= 18; 20 LTS is a safe choice)
RUN mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x bookworm main" \
    > /etc/apt/sources.list.d/nodesource.list \
 && apt-get update && apt-get install -y --no-install-recommends nodejs \
 && rm -rf /var/lib/apt/lists/*

# -------- n8n (latest) --------
# Pin if you prefer: `npm i -g n8n@1.112.0`
RUN npm install -g --omit=dev n8n

# -------- Calibre CLI --------
RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.py \
  | python3 -c "import sys; exec(sys.stdin.read())"
ENV PATH="/opt/calibre:${PATH}"

# (optional) allow ImageMagick to read/write PDF/PS if you need that
# RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml || true

# -------- non-root user & folders --------
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
