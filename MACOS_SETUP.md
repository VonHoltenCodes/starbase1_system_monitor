# Starbase1 System Monitor - macOS Setup Guide

## Prerequisites

1. **Install Docker Desktop for Mac**
   - Download from: https://www.docker.com/products/docker-desktop
   - Requires macOS 10.15 or newer
   - After installation, start Docker Desktop from Applications
   - Wait for Docker to fully initialize (icon in menu bar shows "Docker Desktop is running")

2. **Verify Docker Installation**
   Open Terminal and run:
   ```bash
   docker --version
   docker ps
   ```
   Both commands should complete without errors.

## Installation

### Method 1: Using the macOS Installer (Recommended)

1. Navigate to the starbase1_system_monitor directory in Finder
2. Double-click `install.command`
3. If prompted, enter your password to allow Terminal to run
4. The installer will:
   - Verify Docker is installed and running
   - Build the Docker image
   - Start the container with macOS-compatible settings
   - Offer to open the dashboard in your browser

### Method 2: Using Terminal

```bash
cd /path/to/starbase1_system_monitor
./install.sh
```

### Method 3: Using Docker Compose

```bash
docker-compose -f docker-compose.macos.yml up -d --build
```

### Method 4: Manual Docker Commands

```bash
# Build the image
docker build -t starbase1-monitor .

# Run with macOS-compatible settings
docker run -d \
  --name starbase1_system_monitor \
  -p 8080:8080 \
  -e CONTAINER_MODE=true \
  -e DISABLE_HARDWARE_MONITORING=true \
  -e DISABLE_TEMPERATURE_MONITORING=true \
  --restart unless-stopped \
  starbase1-monitor
```

## Testing Your Setup

Run the test script before installation:
```bash
./test_macos.sh
```

This will verify:
- Docker is installed
- Docker daemon is running
- Port 8080 is available
- All required files are present

## macOS-Specific Limitations

Due to macOS architecture and Docker Desktop limitations:

1. **Hardware Monitoring:** Direct hardware access is not available
   - CPU temperatures not accessible
   - BIOS/firmware information not available
   - Hardware sensors not accessible

2. **System Information:** Limited compared to Linux
   - Basic CPU and memory stats are available
   - Disk usage statistics work normally
   - Network statistics are available

3. **Service Monitoring:** macOS services (launchd) cannot be monitored from Linux containers

## Troubleshooting

### Docker Desktop Won't Start

1. Check system requirements (macOS 10.15+)
2. Ensure virtualization is enabled in Security settings
3. Try resetting Docker Desktop to factory defaults

### Container Fails to Start

1. Check if port 8080 is in use:
   ```bash
   lsof -i:8080
   ```

2. Stop any existing containers:
   ```bash
   docker stop starbase1_system_monitor
   docker rm starbase1_system_monitor
   ```

3. Check Docker logs:
   ```bash
   docker logs starbase1_system_monitor
   ```

### Cannot Access Dashboard

1. Verify container is running:
   ```bash
   docker ps
   ```

2. Check container health:
   ```bash
   docker inspect starbase1_system_monitor --format='{{.State.Health.Status}}'
   ```

3. Try accessing via localhost:
   - http://localhost:8080
   - http://127.0.0.1:8080

### Permission Denied Errors

If you get permission errors:
1. Don't run the installer with `sudo`
2. Make sure Docker Desktop is running
3. Ensure your user has permission to run Docker

## Management Commands

**Start the monitor:**
```bash
docker start starbase1_system_monitor
```

**Stop the monitor:**
```bash
docker stop starbase1_system_monitor
```

**View logs:**
```bash
docker logs starbase1_system_monitor
```

**Remove completely:**
```bash
docker stop starbase1_system_monitor
docker rm starbase1_system_monitor
docker rmi starbase1-monitor
```

**Update to latest version:**
```bash
git pull
./install.command
```

## Debug Mode

If you're experiencing issues with data not displaying:

1. Access the debug page:
   http://localhost:8080/debug

2. Check browser console:
   - Safari: Develop > Show JavaScript Console
   - Chrome/Edge: View > Developer > JavaScript Console

3. Run the minimal test version:
   ```bash
   docker build -f Dockerfile.minimal -t starbase1-minimal .
   docker run -d --name starbase1_system_monitor -p 8080:8080 starbase1-minimal
   ```

## Support

If issues persist:

1. Run `docker logs starbase1_system_monitor > container_logs.txt`
2. Check browser console for JavaScript errors
3. Try the debug page at http://localhost:8080/debug
4. Report issues with logs and system information