@echo off
cls
echo.
echo  ===============================================
echo   Starbase1 System Monitor - Windows Installer
echo   Windows 95 Style System Monitoring Dashboard
echo  ===============================================
echo.

REM Check if Docker is installed and running
echo [1/5] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  ERROR: Docker Desktop is not installed or not running!
    echo.
    echo  Please install Docker Desktop from:
    echo  https://www.docker.com/products/docker-desktop
    echo.
    echo  After installation:
    echo  1. Start Docker Desktop
    echo  2. Wait for it to fully start
    echo  3. Run this installer again
    echo.
    pause
    exit /b 1
)
echo  ✓ Docker is installed and running

REM Stop and remove existing container if it exists
echo.
echo [2/5] Cleaning up any existing installation...
docker stop starbase1_system_monitor >nul 2>&1
docker rm starbase1_system_monitor >nul 2>&1
echo  ✓ Cleanup complete

REM Pull the latest image
echo.
echo [3/5] Downloading Starbase1 System Monitor...
docker pull vonholtencodes/starbase1-monitor:latest
if errorlevel 1 (
    echo.
    echo  ERROR: Failed to download the application image
    echo  Please check your internet connection and try again
    echo.
    pause
    exit /b 1
)
echo  ✓ Download complete

REM Start the container
echo.
echo [4/5] Starting Starbase1 System Monitor...
docker run -d ^
    --name starbase1_system_monitor ^
    --privileged ^
    -p 5000:5000 ^
    -v /proc:/host/proc:ro ^
    -v /sys:/host/sys:ro ^
    -e CONTAINER_MODE=true ^
    -e HOST_PROC=/host/proc ^
    -e HOST_SYS=/host/sys ^
    --restart unless-stopped ^
    vonholtencodes/starbase1-monitor:latest

if errorlevel 1 (
    echo.
    echo  ERROR: Failed to start the system monitor
    echo  Please check Docker Desktop is running and try again
    echo.
    pause
    exit /b 1
)
echo  ✓ Container started successfully

REM Wait for the application to be ready
echo.
echo [5/5] Waiting for application to start...
timeout /t 5 >nul
echo  ✓ Application is ready

REM Success message
echo.
echo  ===============================================
echo   SUCCESS! Starbase1 System Monitor is running
echo  ===============================================
echo.
echo   🖥️  Access your Windows 95 System Monitor at:
echo   📊  http://localhost:5000
echo.
echo   Management Commands:
echo   • To stop:    docker stop starbase1_system_monitor
echo   • To restart: docker restart starbase1_system_monitor
echo   • To remove:  docker rm starbase1_system_monitor
echo   • To update:  Run this installer again
echo.
echo   The monitor will automatically start when you boot Windows
echo   (unless you manually stop it)
echo.

REM Ask if user wants to open browser
set /p choice="Open in browser now? (y/n): "
if /i "%choice%"=="y" (
    start http://localhost:5000
)

echo.
echo  Installation complete! Press any key to exit...
pause >nul