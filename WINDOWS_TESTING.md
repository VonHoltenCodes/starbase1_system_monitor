# Windows Testing Guide for Starbase1 System Monitor

## Quick Diagnostic Steps

When the dashboard shows "Loading..." for all data:

### 1. Check Container Status
```cmd
docker ps
```
Verify the container shows as "Up" and "healthy"

### 2. Test API Endpoints Directly

Open a new Command Prompt and test each API endpoint:

```cmd
# Test system endpoint
curl http://localhost:8080/api/system

# Test security endpoint  
curl http://localhost:8080/api/security

# Test services endpoint
curl http://localhost:8080/api/services

# Test combined status
curl http://localhost:8080/api/status

# Test health check
curl http://localhost:8080/health
```

### 3. Check Container Logs

```cmd
docker logs starbase1_system_monitor --tail 100
```

Look for any Python errors or exceptions.

### 4. Check Browser Console

1. Open the dashboard in your browser (http://localhost:8080)
2. Press F12 to open Developer Tools
3. Go to the Console tab
4. Look for any JavaScript errors
5. Go to the Network tab
6. Refresh the page
7. Check if API calls are returning errors (red entries)

### 5. Use Debug Build

If standard build isn't working, try the debug build:

```cmd
# Stop current container
docker stop starbase1_system_monitor
docker rm starbase1_system_monitor

# Build debug version
docker build -f Dockerfile.debug -t starbase1-monitor-debug .

# Run debug version
docker run -d --name starbase1_system_monitor -p 8080:8080 -e CONTAINER_MODE=true -e DISABLE_HARDWARE_MONITORING=true -e DISABLE_TEMPERATURE_MONITORING=true starbase1-monitor-debug

# Check debug endpoint
curl http://localhost:8080/debug
```

## Common Issues and Solutions

### Issue: All sections show "Loading..."
**Cause:** API endpoints are failing
**Solution:** 
1. Check container logs for Python errors
2. Use the debug build to get more information
3. Test API endpoints individually with curl

### Issue: 500 Internal Server Error
**Cause:** Python exception in collectors
**Solution:**
1. The safe collectors should prevent this
2. Check if you're using the latest code
3. Ensure environment variables are set correctly

### Issue: Connection Refused
**Cause:** Container not running or port issue
**Solution:**
1. Verify container is running: `docker ps`
2. Check port 8080 is not in use: `netstat -an | findstr :8080`
3. Try stopping and restarting the container

### Issue: CORS or Network Errors in Browser
**Cause:** JavaScript can't reach the API
**Solution:**
1. Ensure you're accessing via http://localhost:8080, not file://
2. Check Windows Firewall isn't blocking the connection
3. Try accessing from a different browser

## Manual API Testing

To manually verify the API is working, create a test HTML file:

```html
<!DOCTYPE html>
<html>
<head>
    <title>API Test</title>
</head>
<body>
    <h1>API Test Results</h1>
    <div id="results"></div>
    
    <script>
        async function testAPIs() {
            const endpoints = [
                '/api/system',
                '/api/security', 
                '/api/services',
                '/api/status',
                '/health'
            ];
            
            const results = document.getElementById('results');
            
            for (const endpoint of endpoints) {
                try {
                    const response = await fetch(`http://localhost:8080${endpoint}`);
                    const data = await response.json();
                    results.innerHTML += `<h3>${endpoint}</h3><pre>${JSON.stringify(data, null, 2)}</pre>`;
                } catch (error) {
                    results.innerHTML += `<h3>${endpoint}</h3><p style="color:red">Error: ${error}</p>`;
                }
            }
        }
        
        testAPIs();
    </script>
</body>
</html>
```

Save this as `test.html` and open it in your browser to see raw API responses.

## Rebuilding After Code Changes

If you pull new changes:

```cmd
# Stop and remove old container
docker stop starbase1_system_monitor
docker rm starbase1_system_monitor

# Rebuild image
docker build -t starbase1-monitor .

# Run new container
docker run -d --name starbase1_system_monitor -p 8080:8080 -e CONTAINER_MODE=true -e DISABLE_HARDWARE_MONITORING=true -e DISABLE_TEMPERATURE_MONITORING=true --restart unless-stopped starbase1-monitor
```

## Getting Help

If issues persist after trying these steps:

1. Save the output of `docker logs starbase1_system_monitor > container_logs.txt`
2. Save browser console errors
3. Note which API endpoints are failing
4. Check if the issue occurs in different browsers
5. Try the manual curl tests and save the output