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
    curl \
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

# Create supervisor configuration directory
RUN mkdir -p /var/log/supervisor

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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
