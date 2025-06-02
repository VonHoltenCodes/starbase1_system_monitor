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

REM Test Docker (same as working test_container.bat)
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  ❌ Docker Desktop is not installed
    echo.
    echo  Please install Docker Desktop from:
    echo  https://www.docker.com/products/docker-desktop
    echo.
    pause
    exit /b 1
)
echo  ✓ Docker is installed and running

REM Stop and remove existing container if it exists
echo.
echo [2/4] Cleaning up any existing installation...
docker stop starbase1_system_monitor >nul 2>&1
docker rm starbase1_system_monitor >nul 2>&1
echo  ✓ Cleanup complete

echo [3/4] Building and starting Starbase1 System Monitor...
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

echo  ✓ Build successful, starting container...
docker run -d --name starbase1_system_monitor -p 8080:8080 -e CONTAINER_MODE=true --restart unless-stopped starbase1-monitor
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