# Starbase1 System Monitor - Windows Setup Guide

## Prerequisites

1. **Install Docker Desktop for Windows**
   - Download from: https://www.docker.com/products/docker-desktop
   - During installation, ensure WSL 2 backend is enabled
   - After installation, start Docker Desktop and wait for it to fully initialize

2. **Verify Docker Installation**
   Open PowerShell or Command Prompt and run:
   ```cmd
   docker --version
   docker ps
   ```
   Both commands should complete without errors.

## Installation Methods

### Method 1: Using the Windows Installer (Recommended)

1. Navigate to the starbase1_system_monitor directory
2. Double-click `install.bat` or run from command prompt:
   ```cmd
   cd path\to\starbase1_system_monitor
   install.bat
   ```

The installer will:
- Verify Docker is installed and running
- Build the Docker image
- Start the container with Windows-compatible settings
- Open the dashboard in your browser

### Method 2: Using Docker Compose (Advanced)

For users with Docker Compose installed:
```cmd
docker-compose -f docker-compose.windows.yml up -d --build
```

### Method 3: Manual Docker Commands

If the installer fails, use these manual commands:
```cmd
# Build the image
docker build -t starbase1-monitor .

# Run with Windows-compatible settings
docker run -d ^
  --name starbase1_system_monitor ^
  -p 8080:8080 ^
  -e CONTAINER_MODE=true ^
  -e DISABLE_HARDWARE_MONITORING=true ^
  -e DISABLE_TEMPERATURE_MONITORING=true ^
  --restart unless-stopped ^
  starbase1-monitor
```

## Troubleshooting

### Docker Desktop Not Detected

**Symptom:** Installer shows "Docker Desktop is not installed" even though it's installed

**Solutions:**
1. Ensure Docker Desktop is fully started (system tray icon shows "Docker Desktop is running")
2. Try running the installer as Administrator
3. Restart Docker Desktop and try again
4. Use manual installation method

### Container Fails to Start

**Symptom:** Error during container startup

**Solutions:**
1. Check if port 8080 is already in use:
   ```cmd
   netstat -an | findstr :8080
   ```
2. Stop any existing containers:
   ```cmd
   docker stop starbase1_system_monitor
   docker rm starbase1_system_monitor
   ```
3. Check Docker logs:
   ```cmd
   docker logs starbase1_system_monitor
   ```

### Cannot Access Dashboard

**Symptom:** Browser can't connect to http://localhost:8080

**Solutions:**
1. Verify container is running:
   ```cmd
   docker ps
   ```
2. Check container health:
   ```cmd
   docker inspect starbase1_system_monitor --format='{{.State.Health.Status}}'
   ```
3. Try accessing via Docker IP:
   ```cmd
   docker inspect starbase1_system_monitor --format='{{.NetworkSettings.IPAddress}}'
   ```
   Then access http://[container-ip]:8080

### Windows Defender/Firewall Issues

**Symptom:** Connection blocked by firewall

**Solutions:**
1. Add firewall exception for port 8080
2. Temporarily disable Windows Defender Firewall to test
3. Ensure Docker Desktop has firewall permissions

## Windows-Specific Limitations

Due to Windows containerization differences:

1. **Hardware Monitoring:** Direct hardware access is limited
   - CPU temperatures not available
   - BIOS information not accessible
   - Some system metrics may show as "N/A"

2. **Performance Metrics:** Basic metrics are available:
   - CPU usage and model
   - Memory usage
   - Disk space
   - Network statistics

3. **Service Monitoring:** Windows services cannot be monitored from Linux containers

## Management Commands

**Start the monitor:**
```cmd
docker start starbase1_system_monitor
```

**Stop the monitor:**
```cmd
docker stop starbase1_system_monitor
```

**View logs:**
```cmd
docker logs starbase1_system_monitor
```

**Remove completely:**
```cmd
docker stop starbase1_system_monitor
docker rm starbase1_system_monitor
docker rmi starbase1-monitor
```

**Update to latest version:**
```cmd
git pull
install.bat
```

## Support

If you continue to experience issues:

1. Check the logs: `docker logs starbase1_system_monitor`
2. Verify Docker Desktop is updated to the latest version
3. Ensure WSL 2 is properly configured
4. Try running in PowerShell as Administrator
5. Report issues with full error messages and Docker version info