@echo off
echo ============================================
echo  Docker Detection Debug Tool
echo  Testing all Docker commands individually
echo ============================================
echo.

echo [Test 1] Testing: where docker
echo Command: where docker
where docker
echo Exit code: %errorlevel%
echo.
echo Press any key to continue...
pause >nul
echo.

echo [Test 2] Testing: docker --version
echo Command: docker --version
docker --version
echo Exit code: %errorlevel%
echo.
echo Press any key to continue...
pause >nul
echo.

echo [Test 3] Testing: docker version
echo Command: docker version
docker version
echo Exit code: %errorlevel%
echo.
echo Press any key to continue...
pause >nul
echo.

echo [Test 4] Testing: docker info
echo Command: docker info
docker info
echo Exit code: %errorlevel%
echo.
echo Press any key to continue...
pause >nul
echo.

echo [Test 5] Testing: docker ps
echo Command: docker ps
docker ps
echo Exit code: %errorlevel%
echo.
echo Press any key to continue...
pause >nul
echo.

echo [Test 6] Testing: docker ps with error handling
echo Command: docker ps 2^>nul
docker ps 2>nul
echo Exit code: %errorlevel%
echo.
echo Press any key to continue...
pause >nul
echo.

echo [Test 7] Testing: docker ps with find command
echo Command: docker ps 2^>nul ^| find /c "CONTAINER"
for /f %%i in ('docker ps 2^>nul ^| find /c "CONTAINER"') do set result=%%i
echo Result: "%result%"
echo Exit code: %errorlevel%
echo.

echo ============================================
echo  Debug complete! 
echo  Please share the results of all tests.
echo ============================================
pause