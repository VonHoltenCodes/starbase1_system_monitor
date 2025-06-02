@echo off
echo ============================================
echo  Testing Container Build and Run
echo  Minimal test to isolate container issues
echo ============================================
echo.

echo [Test 1] Testing Docker build...
echo Command: docker build -t starbase1-test .
docker build -t starbase1-test .
echo Build exit code: %errorlevel%
echo.
if errorlevel 1 (
    echo  ❌ BUILD FAILED - This is where the installer crashes!
    echo  Check the error messages above for details.
    pause
    exit /b 1
)

echo  ✓ Build successful, testing container run...
echo.

echo [Test 2] Testing Docker run...
echo Command: docker run -d --name starbase1-test -p 8081:8080 starbase1-test
docker run -d --name starbase1-test -p 8081:8080 -e CONTAINER_MODE=true starbase1-test
echo Run exit code: %errorlevel%
echo.
if errorlevel 1 (
    echo  ❌ CONTAINER RUN FAILED - This is where the installer crashes!
    echo  Check the error messages above for details.
    pause
    exit /b 1
)

echo  ✓ Container started successfully!
echo  Test container ID:
docker ps --filter "name=starbase1-test"
echo.

echo [Cleanup] Removing test container...
docker stop starbase1-test >nul 2>&1
docker rm starbase1-test >nul 2>&1
docker rmi starbase1-test >nul 2>&1
echo  ✓ Cleanup complete

echo.
echo ============================================
echo  Container test completed successfully!
echo  The installer should work now.
echo ============================================
pause