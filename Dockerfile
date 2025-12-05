# Multi-stage Dockerfile for Hitomi Downloader
# This creates a containerized version accessible via web browser through noVNC

FROM ubuntu:24.04 AS builder

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Ho_Chi_Minh

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    patchelf \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@9.5.0

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install Node dependencies
RUN pnpm install

# Copy source files
COPY . .

# Build the application
RUN pnpm tauri build

# Runtime stage with VNC/noVNC for web access
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Ho_Chi_Minh
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NOVNC_PORT=6080

# Install runtime dependencies, VNC server, and noVNC
RUN apt-get update && apt-get install -y \
    libwebkit2gtk-4.1-0 \
    libgtk-3-0 \
    libayatana-appindicator3-1 \
    x11vnc \
    xvfb \
    fluxbox \
    net-tools \
    novnc \
    websockify \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create app user
RUN useradd -m -s /bin/bash appuser

# Copy built application from builder
COPY --from=builder /app/src-tauri/target/release/hitomi-downloader /usr/local/bin/

# Create directories
RUN mkdir -p /home/appuser/.local/share/hitomi-downloader \
    && mkdir -p /home/appuser/Downloads \
    && chown -R appuser:appuser /home/appuser

# Setup VNC password
RUN mkdir -p /home/appuser/.vnc \
    && x11vnc -storepasswd hitomi123 /home/appuser/.vnc/passwd \
    && chown -R appuser:appuser /home/appuser/.vnc

# Create supervisor configuration
RUN mkdir -p /var/log/supervisor
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root

[program:xvfb]
command=/usr/bin/Xvfb :1 -screen 0 1280x720x24
autorestart=true
priority=100
user=appuser

[program:fluxbox]
command=/usr/bin/fluxbox
environment=DISPLAY=":1"
autorestart=true
priority=200
user=appuser

[program:x11vnc]
command=/usr/bin/x11vnc -display :1 -rfbauth /home/appuser/.vnc/passwd -rfbport 5901 -shared -forever
autorestart=true
priority=300
user=appuser

[program:novnc]
command=/usr/share/novnc/utils/novnc_proxy --vnc localhost:5901 --listen 6080
autorestart=true
priority=400
user=appuser

[program:hitomi-downloader]
command=/usr/local/bin/hitomi-downloader
environment=DISPLAY=":1"
autorestart=true
priority=500
user=appuser
startsecs=10
EOF

# Expose ports
EXPOSE 6080 5901

# Set volumes for persistent data
VOLUME ["/home/appuser/.local/share/hitomi-downloader", "/home/appuser/Downloads"]

# Switch to app user
USER appuser
WORKDIR /home/appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:6080/ || exit 1

# Start supervisor
USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
