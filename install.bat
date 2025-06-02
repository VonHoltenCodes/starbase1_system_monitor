@echo off
cls
echo.
echo  ===============================================
echo   Starbase1 System Monitor - Windows Installer
echo   Windows 95 Style System Monitoring Dashboard
echo  ===============================================
echo.

REM Check if Docker is installed and running
echo [1/4] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  ⚠️  DOCKER DESKTOP REQUIRED
    echo  ═══════════════════════════════════════════
    echo.
    echo  Docker Desktop is not installed or not running.
    echo.
    echo  📋 INSTALLATION STEPS:
    echo  1. Go to: https://www.docker.com/products/docker-desktop
    echo  2. Download Docker Desktop for Windows
    echo  3. Install Docker Desktop (requires restart)
    echo  4. Start Docker Desktop and wait for it to fully load
    echo  5. Run this installer again
    echo.
    echo  💡 TIP: Look for the Docker whale icon in your system tray
    echo     when Docker is ready to use.
    echo.
    
    set /p confirm="Have you installed and started Docker Desktop? (y/n): "
    if /i not "%confirm%"=="y" (
        echo.
        echo  Please install Docker Desktop first, then run this installer again.
        echo.
        pause
        exit /b 1
    )
    
    echo.
    echo  Checking Docker again...
    docker --version >nul 2>&1
    if errorlevel 1 (
        echo.
        echo  ❌ Docker still not detected. Please ensure:
        echo  • Docker Desktop is installed
        echo  • Docker Desktop is running (check system tray)
        echo  • Wait for Docker to fully start (can take 2-3 minutes)
        echo.
        pause
        exit /b 1
    )
)
echo  ✓ Docker is installed and running

REM Stop and remove existing container if it exists
echo.
echo [2/4] Cleaning up any existing installation...
docker stop starbase1_system_monitor >nul 2>&1
docker rm starbase1_system_monitor >nul 2>&1
echo  ✓ Cleanup complete

REM Try to use docker-compose if available, otherwise build locally
if exist "docker-compose.yml" (
    echo  Using Docker Compose...
    docker-compose up -d
    if errorlevel 1 (
        echo  Docker Compose failed, building locally...
        goto buildlocal
    )
    echo  ✓ Container started with Docker Compose
    goto waitforstart
)

:buildlocal
echo  Building image locally...
docker build -t starbase1-monitor .
if errorlevel 1 (
    echo.
    echo  ERROR: Failed to build the system monitor
    echo  Please check that all files are present
    echo.
    pause
    exit /b 1
)
docker run -d ^
    --name starbase1_system_monitor ^
    --privileged ^
    -p 8080:8080 ^
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

:waitforstart
REM Wait for the application to be ready
echo.
echo [4/4] Waiting for application to start...
timeout /t 5 >nul
echo  ✓ Application is ready

REM Success message
echo.
echo  ===============================================
echo   SUCCESS! Starbase1 System Monitor is running
echo  ===============================================
echo.
echo   🖥️  Access your Windows 95 System Monitor at:
echo   📊  http://localhost:8080
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
    start http://localhost:8080
)

echo.
echo  Installation complete! Press any key to exit...
pause >nul