@echo off
cls
echo.
echo  ===============================================
echo   Starbase1 System Monitor - Windows Installer
echo   Windows 95 Style System Monitoring Dashboard
echo  ===============================================
echo.

REM Check if Docker is installed and running
echo [1/6] Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo  Docker Desktop not found. Installing automatically...
    echo.
    echo [1.1/6] Downloading Docker Desktop installer...
    
    REM Create temp directory
    if not exist "%TEMP%\starbase1" mkdir "%TEMP%\starbase1"
    
    REM Download Docker Desktop installer
    powershell -Command "& {Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe' -OutFile '%TEMP%\starbase1\DockerDesktopInstaller.exe'}"
    
    if not exist "%TEMP%\starbase1\DockerDesktopInstaller.exe" (
        echo.
        echo  ERROR: Failed to download Docker Desktop installer
        echo  Please check your internet connection and try again
        echo.
        pause
        exit /b 1
    )
    
    echo  ✓ Download complete
    echo.
    echo [1.2/6] Installing Docker Desktop...
    echo  This may take a few minutes and require admin privileges...
    echo.
    
    REM Install Docker Desktop silently
    "%TEMP%\starbase1\DockerDesktopInstaller.exe" install --quiet
    
    echo  ✓ Docker Desktop installation complete
    echo.
    echo [1.3/6] Starting Docker Desktop...
    echo  Please wait while Docker starts up (this can take 2-3 minutes)...
    
    REM Start Docker Desktop
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    REM Wait for Docker to be ready (check every 10 seconds for up to 3 minutes)
    set /a counter=0
    :waitloop
    timeout /t 10 >nul
    docker --version >nul 2>&1
    if not errorlevel 1 goto dockerready
    set /a counter+=1
    if %counter% lss 18 (
        echo  Still waiting for Docker to start... (%counter%/18)
        goto waitloop
    )
    
    echo.
    echo  WARNING: Docker Desktop is taking longer than expected to start
    echo  Please ensure Docker Desktop is running and try again
    echo.
    pause
    exit /b 1
    
    :dockerready
    echo  ✓ Docker Desktop is now running
    
    REM Clean up installer
    del "%TEMP%\starbase1\DockerDesktopInstaller.exe" >nul 2>&1
)
echo  ✓ Docker is installed and running

REM Stop and remove existing container if it exists
echo.
echo [2/6] Cleaning up any existing installation...
docker stop starbase1_system_monitor >nul 2>&1
docker rm starbase1_system_monitor >nul 2>&1
echo  ✓ Cleanup complete

REM Pull the latest image
echo.
echo [3/6] Downloading Starbase1 System Monitor...
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
echo [4/6] Starting Starbase1 System Monitor...
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

REM Wait for the application to be ready
echo.
echo [5/6] Waiting for application to start...
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