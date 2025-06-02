@echo off
cls
echo.
echo =====================================
echo  Docker Windows Compatibility Test
echo =====================================
echo.

echo [TEST 1] Checking Docker Installation
docker --version >nul 2>&1
if errorlevel 1 (
    echo FAIL: Docker is not installed
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop
    goto :end
) else (
    echo PASS: Docker is installed
    docker --version
)

echo.
echo [TEST 2] Checking Docker Daemon
docker ps >nul 2>&1
if errorlevel 1 (
    echo FAIL: Docker daemon is not running
    echo Please start Docker Desktop and wait for it to fully initialize
    goto :end
) else (
    echo PASS: Docker daemon is running
)

echo.
echo [TEST 3] Testing Container Creation
docker run --rm hello-world >nul 2>&1
if errorlevel 1 (
    echo FAIL: Cannot create containers
    echo Check Docker Desktop settings and ensure WSL 2 is configured
    goto :end
) else (
    echo PASS: Container creation works
)

echo.
echo [TEST 4] Checking Port Availability
netstat -an | findstr :8080 | findstr LISTENING >nul 2>&1
if not errorlevel 1 (
    echo WARNING: Port 8080 is already in use
    echo The application may fail to start
) else (
    echo PASS: Port 8080 is available
)

echo.
echo [TEST 5] Docker Compose Check
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo INFO: Docker Compose not found (optional)
    echo The installer will use docker run instead
) else (
    echo PASS: Docker Compose is available
    docker-compose --version
)

echo.
echo [TEST 6] Testing Build Context
if exist Dockerfile (
    echo PASS: Dockerfile found
) else (
    echo FAIL: Dockerfile not found
    echo Please run this test from the starbase1_system_monitor directory
    goto :end
)

echo.
echo =====================================
echo  All critical tests passed!
echo  You can now run install.bat
echo =====================================

:end
echo.
pause