#!/bin/bash

# Starbase1 System Monitor - Linux/Mac Installer
# Windows 95 Style System Monitoring Dashboard

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "  ==============================================="
echo "   Starbase1 System Monitor - Unix Installer"
echo "   Windows 95 Style System Monitoring Dashboard"
echo "  ==============================================="
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}ERROR: Please do not run this installer as root${NC}"
   echo "Run as a regular user - Docker commands will use sudo when needed"
   exit 1
fi

# Function to check if Docker is installed
check_docker() {
    echo -e "${YELLOW}[1/5] Checking Docker installation...${NC}"
    
    if command -v docker &> /dev/null; then
        if docker --version &> /dev/null; then
            echo -e "${GREEN}✓ Docker is installed${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}ERROR: Docker is not installed or not accessible${NC}"
    echo ""
    echo "Please install Docker first:"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "• Download Docker Desktop for Mac: https://docs.docker.com/desktop/mac/install/"
    else
        echo "• Ubuntu/Debian: sudo apt update && sudo apt install docker.io"
        echo "• CentOS/RHEL: sudo yum install docker"
        echo "• Arch: sudo pacman -S docker"
        echo "• Or visit: https://docs.docker.com/engine/install/"
    fi
    
    echo ""
    echo "After installation, make sure your user is in the docker group:"
    echo "sudo usermod -aG docker \$USER"
    echo "Then log out and log back in."
    exit 1
}

# Function to check if Docker daemon is running
check_docker_running() {
    echo -e "${YELLOW}[2/5] Checking if Docker daemon is running...${NC}"
    
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓ Docker daemon is running${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Docker daemon is not running. Attempting to start...${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Please start Docker Desktop and try again."
        exit 1
    else
        if sudo systemctl start docker 2>/dev/null; then
            sleep 3
            if docker info &> /dev/null; then
                echo -e "${GREEN}✓ Docker daemon started successfully${NC}"
                return 0
            fi
        fi
        
        echo -e "${RED}ERROR: Could not start Docker daemon${NC}"
        echo "Please start Docker manually and try again:"
        echo "sudo systemctl start docker"
        exit 1
    fi
}

# Function to clean up existing installation
cleanup_existing() {
    echo -e "${YELLOW}[3/5] Cleaning up any existing installation...${NC}"
    
    if docker ps -a --format "table {{.Names}}" | grep -q "starbase1_system_monitor"; then
        echo "Stopping and removing existing container..."
        docker stop starbase1_system_monitor 2>/dev/null || true
        docker rm starbase1_system_monitor 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function to pull the Docker image
pull_image() {
    echo -e "${YELLOW}[4/5] Downloading Starbase1 System Monitor...${NC}"
    
    if docker pull vonholtencodes/starbase1-monitor:latest; then
        echo -e "${GREEN}✓ Download complete${NC}"
    else
        echo -e "${RED}ERROR: Failed to download the application image${NC}"
        echo "Please check your internet connection and try again"
        exit 1
    fi
}

# Function to start the container
start_container() {
    echo -e "${YELLOW}[5/5] Starting Starbase1 System Monitor...${NC}"
    
    # Determine the correct Docker socket path
    DOCKER_SOCK=""
    if [[ -S "/var/run/docker.sock" ]]; then
        DOCKER_SOCK="-v /var/run/docker.sock:/var/run/docker.sock:ro"
    fi
    
    # Start the container
    if docker run -d \
        --name starbase1_system_monitor \
        --privileged \
        -p 5000:5000 \
        -v /proc:/host/proc:ro \
        -v /sys:/host/sys:ro \
        -v /etc/os-release:/host/os-release:ro \
        $DOCKER_SOCK \
        -e CONTAINER_MODE=true \
        -e HOST_PROC=/host/proc \
        -e HOST_SYS=/host/sys \
        --restart unless-stopped \
        vonholtencodes/starbase1-monitor:latest; then
        
        echo -e "${GREEN}✓ Container started successfully${NC}"
        
        # Wait for application to be ready
        echo "Waiting for application to start..."
        sleep 5
        
    else
        echo -e "${RED}ERROR: Failed to start the system monitor${NC}"
        echo "Please check Docker is running properly and try again"
        exit 1
    fi
}

# Function to display success message
show_success() {
    echo ""
    echo -e "${GREEN}"
    echo "  ==============================================="
    echo "   SUCCESS! Starbase1 System Monitor is running"
    echo "  ==============================================="
    echo -e "${NC}"
    echo ""
    echo -e "${BLUE}🖥️  Access your Windows 95 System Monitor at:${NC}"
    echo -e "${BLUE}📊  http://localhost:5000${NC}"
    echo ""
    echo "Management Commands:"
    echo "• To stop:    docker stop starbase1_system_monitor"
    echo "• To restart: docker restart starbase1_system_monitor"
    echo "• To remove:  docker rm starbase1_system_monitor"
    echo "• To update:  curl -sSL https://install.starbase1.dev | bash"
    echo ""
    echo "The monitor will automatically start when you boot your system"
    echo "(unless you manually stop it)"
    echo ""
    
    # Ask if user wants to open browser (if in GUI environment)
    if [[ -n "$DISPLAY" ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        read -p "Open in browser now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                open http://localhost:5000
            elif command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:5000
            fi
        fi
    fi
    
    echo ""
    echo -e "${GREEN}Installation complete!${NC}"
}

# Main installation flow
main() {
    check_docker
    check_docker_running
    cleanup_existing
    pull_image
    start_container
    show_success
}

# Run the installer
main "$@"