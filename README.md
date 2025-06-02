# Starbase1_IO System Monitor

A retro Windows 95-themed system monitoring dashboard that runs in Docker containers. Monitor your system's performance with authentic 90s nostalgia!

![Starbase1_IO Dashboard](https://via.placeholder.com/800x600/c0c0c0/000000?text=Windows+95+System+Monitor)

## Features

- **Authentic Windows 95 UI** - Complete with gray window borders, inset/outset styling, and classic taskbar
- **Real-time System Monitoring** - CPU usage, memory stats, disk space, and temperatures
- **Cross-Platform Support** - Works on Windows, macOS, and Linux via Docker
- **Easy Installation** - One-click installers for all platforms
- **Containerized** - Secure, isolated monitoring with minimal system impact
- **Web-based Dashboard** - Access via any modern web browser

## Quick Start

### Windows
1. Download and double-click `install.bat`
2. Follow the prompts to install Docker Desktop if needed
3. The dashboard will automatically open in your browser

### macOS
1. Download and double-click `install.command`
2. Follow the prompts to install Docker Desktop if needed
3. The dashboard will automatically open in your browser

### Linux
1. Download `install.sh`
2. Run: `chmod +x install.sh && ./install.sh`
3. Follow the prompts to install Docker if needed
4. Open http://localhost:8080 in your browser

## Manual Installation

### Prerequisites
- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- 2GB available RAM
- Modern web browser

### Using Docker Compose
```bash
git clone https://github.com/yourusername/starbase1_system_monitor.git
cd starbase1_system_monitor
docker-compose up -d
```

### Using Docker Run
```bash
docker run -d \
  --name starbase1-monitor \
  -p 8080:8080 \
  -v /proc:/host/proc:ro \
  -v /sys:/host/sys:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --privileged \
  starbase1/system-monitor:latest
```

## System Requirements

### Minimum
- **CPU**: 1 core
- **RAM**: 512MB
- **Storage**: 100MB
- **OS**: Any Docker-supported platform

### Recommended
- **CPU**: 2+ cores
- **RAM**: 1GB+
- **Storage**: 500MB
- **Network**: Local network access for web interface

## Configuration

### Environment Variables
- `CONTAINER_MODE=true` - Enables container-optimized monitoring
- `HOST_PROC=/host/proc` - Path to host /proc filesystem
- `HOST_SYS=/host/sys` - Path to host /sys filesystem
- `PORT=8080` - Web server port (default: 8080)

### Volume Mounts
- `/proc:/host/proc:ro` - Required for CPU and memory monitoring
- `/sys:/host/sys:ro` - Required for hardware sensor data
- `/var/run/docker.sock:/var/run/docker.sock:ro` - Optional Docker monitoring

## Dashboard Features

### System Overview
- **CPU Usage** - Real-time percentage and core count
- **Memory Stats** - Used/available RAM with percentage
- **Disk Space** - Usage across all mounted filesystems
- **System Info** - Hostname, OS, uptime, and load averages

### Hardware Monitoring
- **Temperature Sensors** - CPU and system temperatures where available
- **BIOS Information** - System manufacturer, model, and BIOS version
- **Service Status** - Running processes and system services

### Windows 95 Interface Elements
- **Title Bar** - Classic window controls (minimize, maximize, close)
- **Menu Bar** - File, View, Tools, and Help menus
- **Status Bar** - Current time and system status
- **Taskbar** - Start button and running applications

## Troubleshooting

### Common Issues

**Dashboard shows "Loading..." indefinitely**
- Check if container has proper volume mounts to /proc and /sys
- Verify container is running: `docker ps`
- Check logs: `docker logs starbase1-monitor`

**Temperature data not showing**
- Temperature sensors may not be available in virtualized environments
- Try running with `--privileged` flag for hardware access
- Some systems require additional kernel modules

**High CPU usage**
- Reduce monitoring frequency by modifying refresh intervals
- Check for resource conflicts with other monitoring tools
- Ensure adequate system resources are available

**Cannot access dashboard**
- Verify port 8080 is not in use by another application
- Check firewall settings allow local connections
- Try accessing via `http://127.0.0.1:8080` instead of `localhost`

### Docker Issues

**Permission denied errors**
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo
sudo docker-compose up -d
```

**Port already in use**
```bash
# Find process using port 8080
lsof -i :8080
# Kill process or change port in docker-compose.yml
```

## Development

### Building from Source
```bash
git clone https://github.com/yourusername/starbase1_system_monitor.git
cd starbase1_system_monitor
docker build -t starbase1-monitor .
```

### Local Development
```bash
# Install Python dependencies
pip install flask psutil

# Run development server
python app.py
```

### File Structure
```
starbase1_system_monitor/
├── app.py                 # Flask application
├── Dockerfile            # Container configuration
├── docker-compose.yml    # Docker Compose setup
├── requirements.txt      # Python dependencies
├── install.bat           # Windows installer
├── install.sh            # Linux/Mac installer
├── install.command       # Mac GUI installer
├── templates/
│   └── index.html        # Windows 95 dashboard
├── static/
│   ├── style.css         # Windows 95 styling
│   └── script.js         # Dashboard JavaScript
└── README.md             # This file
```

## Security Considerations

- Container runs as non-root user for security
- Read-only access to host filesystem monitoring points
- No network services exposed beyond local web interface
- Minimal attack surface with Alpine Linux base image

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the classic Windows 95 interface design
- Built with Flask, Docker, and modern web technologies
- System monitoring powered by psutil Python library

## Support

- **Issues**: Report bugs and request features on GitHub Issues
- **Discussions**: Join community discussions on GitHub Discussions
- **Email**: Contact maintainers at support@starbase1.io

---

**Made with ❤️ and 90s nostalgia**