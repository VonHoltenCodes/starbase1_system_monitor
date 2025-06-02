@echo off
echo.
echo ====================================
echo  Simple Diagnostic Test
echo ====================================
echo.

echo [1] Checking if container is running...
docker ps | findstr starbase1_system_monitor
if errorlevel 1 (
    echo FAIL: Container is not running!
    echo.
    echo Try running: docker start starbase1_system_monitor
    pause
    exit /b 1
)
echo PASS: Container is running
echo.

echo [2] Testing if web server responds...
curl -s http://localhost:8080/ >nul 2>&1
if errorlevel 1 (
    echo FAIL: Cannot reach web server!
    echo.
    echo This might be a firewall issue.
    pause
    exit /b 1
)
echo PASS: Web server is responding
echo.

echo [3] Testing API health endpoint...
echo Response from /health:
curl -s http://localhost:8080/health
echo.
echo.

echo [4] Testing system API...
echo Response from /api/system:
curl -s http://localhost:8080/api/system
echo.
echo.

echo [5] Checking container logs for errors...
echo Last 20 lines of container logs:
echo ====================================
docker logs starbase1_system_monitor --tail 20
echo ====================================
echo.

echo If you see Python errors above, that's the problem!
echo.
pause