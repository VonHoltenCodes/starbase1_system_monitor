#!/bin/bash

# macOS Docker Test Script

echo ""
echo "===================================="
echo " macOS Docker Compatibility Test"
echo "===================================="
echo ""

echo "[TEST 1] Checking Docker Installation"
if command -v docker &> /dev/null; then
    echo "PASS: Docker is installed"
    docker --version
else
    echo "FAIL: Docker is not installed"
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo ""
echo "[TEST 2] Checking Docker Daemon"
if docker ps &> /dev/null; then
    echo "PASS: Docker daemon is running"
else
    echo "FAIL: Docker daemon is not running"
    echo "Please start Docker Desktop and wait for it to fully initialize"
    exit 1
fi

echo ""
echo "[TEST 3] Testing Container Creation"
if docker run --rm hello-world &> /dev/null; then
    echo "PASS: Container creation works"
else
    echo "FAIL: Cannot create containers"
    echo "Check Docker Desktop settings"
    exit 1
fi

echo ""
echo "[TEST 4] Checking Port Availability"
if lsof -i:8080 &> /dev/null; then
    echo "WARNING: Port 8080 is already in use"
    echo "The application may fail to start"
else
    echo "PASS: Port 8080 is available"
fi

echo ""
echo "[TEST 5] Docker Compose Check"
if command -v docker-compose &> /dev/null; then
    echo "PASS: Docker Compose is available"
    docker-compose --version
else
    echo "INFO: Docker Compose not found (optional)"
    echo "The installer will use docker run instead"
fi

echo ""
echo "[TEST 6] Testing Build Context"
if [[ -f "Dockerfile" ]]; then
    echo "PASS: Dockerfile found"
else
    echo "FAIL: Dockerfile not found"
    echo "Please run this test from the starbase1_system_monitor directory"
    exit 1
fi

echo ""
echo "===================================="
echo " All critical tests passed!"
echo " You can now run ./install.command"
echo "===================================="
echo ""