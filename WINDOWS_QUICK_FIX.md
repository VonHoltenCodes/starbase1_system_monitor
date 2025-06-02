# Quick Fix for Windows "Loading..." Issue

## Option 1: Use the Minimal Test Version

This will help us determine if the issue is with the Python collectors or something else.

```cmd
# Stop current container
docker stop starbase1_system_monitor
docker rm starbase1_system_monitor

# Build minimal test version
docker build -f Dockerfile.minimal -t starbase1-minimal .

# Run minimal version
docker run -d --name starbase1_system_monitor -p 8080:8080 starbase1-minimal

# Test it
start http://localhost:8080
```

If this works (shows data instead of "Loading..."), the issue is with the collectors.
If this still shows "Loading...", the issue might be:
- CORS/Network issue
- JavaScript error
- Firewall blocking

## Option 2: Check What's Actually Happening

Run the simple test script:
```cmd
test_simple.bat
```

This will show you:
- If the container is running
- If the API is responding
- What data the API returns
- Any Python errors in the logs

## Option 3: Quick Manual Test

Open PowerShell and run:
```powershell
# Test if API responds
Invoke-WebRequest -Uri http://localhost:8080/api/system -UseBasicParsing

# If that works, check the data format
(Invoke-WebRequest -Uri http://localhost:8080/api/system -UseBasicParsing).Content
```

## Option 4: Use Browser Developer Tools

1. Open http://localhost:8080 in Chrome/Edge
2. Press F12 for Developer Tools
3. Go to Network tab
4. Refresh the page (F5)
5. Look for red entries (failed requests)
6. Click on any `/api/` request
7. Check the Response tab - is it empty or showing an error?

## Common Solutions

### If container logs show "Permission denied" errors:
The collectors are trying to access Linux files. Use the safe version:
```cmd
docker run -d --name starbase1_system_monitor -p 8080:8080 -e CONTAINER_MODE=true -e DISABLE_HARDWARE_MONITORING=true -e DISABLE_TEMPERATURE_MONITORING=true starbase1-monitor
```

### If API returns data but dashboard shows "Loading...":
There's a JavaScript error. Check browser console for errors.

### If API returns no data or errors:
The Python code is failing. Check docker logs for the specific error.

## Still Not Working?

Create a simple test file called `api_test.html`:

```html
<!DOCTYPE html>
<html>
<body>
<h1>Direct API Test</h1>
<button onclick="testAPI()">Test API</button>
<pre id="result"></pre>

<script>
function testAPI() {
    fetch('http://localhost:8080/api/system')
        .then(response => response.json())
        .then(data => {
            document.getElementById('result').textContent = JSON.stringify(data, null, 2);
        })
        .catch(error => {
            document.getElementById('result').textContent = 'Error: ' + error;
        });
}
</script>
</body>
</html>
```

Save and open this file in your browser. Click "Test API" to see if the API works directly.