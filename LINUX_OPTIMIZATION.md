# Linux Optimization Guide for Ubuntu 24.04 LTS

This document provides detailed information about the Linux-specific optimizations implemented in Hitomi Downloader to ensure optimal performance on Ubuntu 24.04 LTS without lag or performance degradation.

## Performance Optimizations

### 1. Adaptive Concurrency

The application automatically adjusts download concurrency based on your system's CPU cores:

- **Comic Downloads**: `(CPU cores / 2)`, minimum 2, maximum 4 concurrent downloads
- **Image Downloads**: `(CPU cores * 2)`, minimum 8, maximum 16 concurrent downloads

This ensures optimal resource utilization without overwhelming your system.

### 2. HTTP Client Optimizations

#### Connection Pooling
- **API Client**: 10 idle connections per host
- **Image Client**: 20 idle connections per host (optimized for high throughput)
- **Cover Client**: 15 idle connections per host

#### TCP Optimizations
- **TCP Keep-Alive**: Enabled with 60-75 second intervals to maintain connections
- **TCP No-Delay**: Enabled for image downloads to reduce latency
- **HTTP/2 Adaptive Window**: Enabled for better flow control

#### Idle Timeout Management
- Connections are kept alive for 90-120 seconds to maximize reuse
- Automatic cleanup of idle connections to prevent resource exhaustion

### 3. Rust Compiler Optimizations

The release build is configured with maximum optimization settings:

- **LTO (Link Time Optimization)**: "fat" mode for best performance
- **Optimization Level**: 3 (maximum)
- **Codegen Units**: 1 (better optimization, longer compile time)
- **Binary Stripping**: Enabled to reduce size
- **Panic**: "abort" to reduce binary size and overhead

### 4. Compression Support

Enabled multiple compression algorithms for bandwidth optimization:
- **Gzip**: Standard compression
- **Brotli**: High compression ratio
- **Deflate**: Fallback compression

## System Requirements

### Minimum Requirements
- Ubuntu 24.04 LTS (or compatible Linux distribution)
- 2 CPU cores
- 2 GB RAM
- 100 MB free disk space (excluding downloads)

### Recommended Requirements
- Ubuntu 24.04 LTS
- 4+ CPU cores
- 4+ GB RAM
- SSD storage for download directory
- Stable internet connection

## Installation

### From Pre-built Packages

#### DEB Package (Debian/Ubuntu)
```bash
sudo dpkg -i hitomi-downloader_*_linux_amd64.deb
sudo apt-get install -f  # Install dependencies if needed
```

#### RPM Package (Fedora/RHEL)
```bash
sudo rpm -i hitomi-downloader_*_linux_amd64.rpm
```

#### Portable Version
```bash
tar -xzf hitomi-downloader_*_linux_amd64_portable.tar.gz
cd hitomi-downloader
./hitomi-downloader
```

### Building from Source

For optimal performance on your specific hardware:

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y libwebkit2gtk-4.1-dev libappindicator3-dev librsvg2-dev patchelf

# Install Rust, Node.js, and pnpm
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g pnpm

# Clone and build
git clone https://github.com/lanyeeee/hitomi-downloader.git
cd hitomi-downloader
pnpm install
pnpm tauri build
```

The built application will be in `src-tauri/target/release/`.

## Performance Tuning Tips

### 1. File System Optimization

**Use SSD for Downloads**
```bash
# Check if your download directory is on SSD
df -Th /path/to/download/directory
```

**Disable Access Time Updates** (optional, for SSD longevity)
```bash
# Add 'noatime' to your mount options in /etc/fstab
# Example: /dev/sda1 /home ext4 defaults,noatime 0 2
```

### 2. Network Optimization

**Increase System Network Buffers**
```bash
# Add to /etc/sysctl.conf
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Apply changes
sudo sysctl -p
```

**Enable BBR Congestion Control** (Ubuntu 24.04 default, but verify)
```bash
# Check current congestion control
sysctl net.ipv4.tcp_congestion_control

# If not BBR, add to /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Apply changes
sudo sysctl -p
```

### 3. Proxy Configuration

For optimal performance with proxies:

1. **System Proxy Mode**: Best for users with properly configured system proxy
2. **Custom Proxy Mode**: Use for specific proxy servers
3. **No Proxy Mode**: Fastest, but use only if you don't need proxy

### 4. Download Directory Organization

The application supports custom directory structure with placeholders:
- `{title}` - Comic title
- `{id}` - Comic ID
- `{type}` - Content type
- `{language}` - Language
- `{artists}` - Artists (comma-separated)

Example: `{type}/{language}/{title} - {id}`

This helps organize downloads efficiently and prevents file system slowdowns.

### 5. Monitor System Resources

Use system monitoring tools to ensure optimal performance:

```bash
# Monitor CPU and memory usage
htop

# Monitor network usage
iftop

# Monitor disk I/O
iotop
```

## Security Features

### 1. Memory Safety
- Written in Rust, eliminating entire classes of memory vulnerabilities
- No buffer overflows, use-after-free, or data races

### 2. Sandboxed Environment
- Tauri provides process isolation between frontend and backend
- Limited API surface reduces attack vectors

### 3. Network Security
- HTTPS/TLS encryption for all communications
- Certificate validation enabled
- Supports system proxy for additional security layers

### 4. File System Security
- Sandboxed file access through Tauri's permission system
- Path traversal protection
- Safe file operations with proper error handling

### 5. Dependency Security
Regular security audits with:
```bash
cargo audit  # For Rust dependencies
pnpm audit   # For Node.js dependencies
```

## Troubleshooting

### Application Feels Slow

1. **Check System Resources**
   ```bash
   top -b -n 1 | head -20
   ```

2. **Verify Network Connection**
   ```bash
   ping -c 5 8.8.8.8
   speedtest-cli
   ```

3. **Check Download Directory**
   - Ensure sufficient free space
   - Verify write permissions
   - Use SSD if available

4. **Adjust Concurrency** (if needed)
   - The application auto-adjusts based on CPU cores
   - More cores = higher concurrency = better performance

### High CPU Usage

This is normal during:
- Active downloads (image processing)
- PDF/CBZ export operations
- Initial search results loading

If CPU usage is high when idle:
1. Check for background tasks
2. Close unused download tasks
3. Reduce concurrent downloads if needed

### High Memory Usage

Expected memory usage:
- Base: ~100-200 MB
- Per active download: ~50-100 MB
- During export: +200-500 MB

If memory usage is excessive:
1. Reduce concurrent downloads
2. Close completed downloads
3. Restart the application

### Network Issues

1. **Connection Timeout**
   - Check internet connection
   - Verify proxy settings
   - Try different proxy mode

2. **Slow Download Speed**
   - Test network speed
   - Check system network buffers (see Network Optimization)
   - Verify proxy isn't bottleneck

## Best Practices

1. **Regular Updates**: Keep the application and system updated
2. **SSD Storage**: Use SSD for download directory for best performance
3. **Adequate Resources**: Ensure system meets recommended requirements
4. **Network Quality**: Use stable, high-speed internet connection
5. **Proxy Configuration**: Use appropriate proxy mode for your setup
6. **Directory Organization**: Use custom directory structure for large collections
7. **Regular Maintenance**: Clean up old downloads, check disk space

## Performance Benchmarks

On a typical Ubuntu 24.04 LTS system with:
- CPU: 4 cores @ 2.5 GHz
- RAM: 8 GB
- Storage: SSD
- Network: 100 Mbps

Expected performance:
- **Concurrent Downloads**: 2 comics, 8-16 images per comic
- **Download Speed**: Up to 10-15 MB/s (network dependent)
- **Memory Usage**: 200-500 MB during active downloads
- **CPU Usage**: 20-40% during downloads
- **Search Response**: < 2 seconds
- **Export Speed**: ~500 images/minute to PDF/CBZ

## Compatibility

This application is tested and optimized for:
- Ubuntu 24.04 LTS (primary target)
- Ubuntu 22.04 LTS
- Debian 12+
- Fedora 38+
- Other modern Linux distributions with GTK 3.0+

## Additional Resources

- [Main README](./README.md)
- [Security Policy](./SECURITY.md)
- [Vietnamese README](./README.vi-VN.md)
- [GitHub Issues](https://github.com/lanyeeee/hitomi-downloader/issues)

## Contributing

If you discover ways to improve Linux performance:
1. Test thoroughly on Ubuntu 24.04 LTS
2. Measure performance improvements
3. Submit a PR with benchmarks
4. Update this document with new tips

## License

This project is licensed under the same license as the main application. See [LICENSE](./LICENSE) for details.
