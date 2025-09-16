# IMPORTANT: use the Debian-based image
FROM n8nio/n8n:latest-debian

USER root

# Switch to archive repositories for Debian Buster (EOL)
# This is necessary because the base image uses a version of Debian
# that is no longer supported on the main package servers.
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    sed -i '/buster-updates/d' /etc/apt/sources.list

# Base deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 wget ca-certificates xz-utils \
    ffmpeg imagemagick ghostscript \
 && rm -rf /var/lib/apt/lists/*

# Install Calibre (CLI tools like ebook-convert, ebook-meta)
RUN wget -nv -O- https://download.calibre-ebook.com/linux-installer.py \
  | python3 -c "import sys; exec(sys.stdin.read())"

# Put Calibre on PATH
ENV PATH="/opt/calibre:${PATH}"

# (optional) allow ImageMagick to read/write PDF/PS if you need that
# RUN sed -i 's/rights="none" pattern="PDF"/rights="read|write" pattern="PDF"/' /etc/ImageMagick-6/policy.xml || true

# back to default n8n user
USER node