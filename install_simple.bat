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
    echo  ERROR: Docker Desktop is not installed!
    echo.
    echo  Please install Docker Desktop first:
    echo  1. Go to: https://www.docker.com/products/docker-desktop
    echo  2. Download and install Docker Desktop
    echo  3. Start Docker Desktop and wait for it to fully load
    echo  4. Run this installer again
    echo.
    echo  OR use install.bat (requires admin) for automatic installation
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

REM Start the container using local build or docker-compose
echo.
echo [3/4] Starting Starbase1 System Monitor...

REM Try to use docker-compose if available
if exist "docker-compose.yml" (
    echo  Using Docker Compose...
    docker-compose up -d
    if errorlevel 1 (
        echo  Docker Compose failed, trying direct Docker run...
        goto directrun
    )
    echo  ✓ Container started with Docker Compose
    goto success
)

:directrun
echo  Using direct Docker run...
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
    starbase1-monitor:latest

if errorlevel 1 (
    echo.
    echo  Building image locally...
    docker build -t starbase1-monitor .
    if errorlevel 1 (
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
        starbase1-monitor:latest
        
    if errorlevel 1 (
        echo  ERROR: Failed to start the system monitor
        echo.
        pause
        exit /b 1
    )
)
echo  ✓ Container started successfully

:success
REM Wait for the application to be ready
echo.
echo [4/4] Waiting for application to start...
timeout /t 3 >nul
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
echo.

REM Ask if user wants to open browser
set /p choice="Open in browser now? (y/n): "
if /i "%choice%"=="y" (
    start http://localhost:8080
)

echo.
echo  Installation complete! Press any key to exit...
pause >nul