# Windows and macOS Feature Parity

Both Windows and macOS installers now have identical fixes and features:

## Template Fixes ✓
- Both use `dashboard.html` (not index.html)
- Both pass required template variables (app_name, refresh_interval)
- JavaScript updateElement() function is present

## Collector Fixes ✓
- Both use safe collectors that work in containers:
  - `security_collector_safe.py` - Returns mock data in containers
  - `service_collector_safe.py` - Handles missing systemctl
  - `system_collector_fixed.py` - Returns data in correct format

## Environment Variables ✓
Both platforms set:
- `CONTAINER_MODE=true`
- `DISABLE_HARDWARE_MONITORING=true` 
- `DISABLE_TEMPERATURE_MONITORING=true`

## Port Configuration ✓
- Both use port 8080 consistently
- Health checks use correct port

## Data Format Fixes ✓
- CPU usage field: `usage` (not `usage_percent`)
- Memory in bytes (not formatted strings)
- User fields: `name` and `started` (not `username` and `login_time`)
- Failed logins as number (not object)
- Uptime in seconds (not formatted string)

## Platform-Specific Files
- Windows: `docker-compose.windows.yml` (no Linux volume mounts)
- macOS: `docker-compose.macos.yml` (no Linux volume mounts)
- Linux: `docker-compose.yml` (includes /proc, /sys mounts)

## Testing Scripts
- Windows: `test_windows_docker.bat`
- macOS: `test_macos.sh`
- Both check Docker, ports, and prerequisites

## Installation Process
Both follow the same flow:
1. Check Docker is installed and running
2. Clean up existing containers
3. Build image locally
4. Start with platform-appropriate settings
5. Open browser (optional)

## Remaining Known Issues
1. Service status display may show overlay issues (investigating)
2. Some hardware info shows as "N/A" in containers (expected)