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
    echo -e "${YELLOW}[1/4] Checking Docker installation...${NC}"
    
    if command -v docker &> /dev/null; then
        if docker --version &> /dev/null; then
            echo -e "${GREEN}✓ Docker is installed${NC}"
            return 0
        fi
    fi
    
    echo -e "${RED}⚠️  DOCKER REQUIRED${NC}"
    echo "═══════════════════════════════════════════"
    echo ""
    echo "Docker is not installed or not accessible."
    echo ""
    echo -e "${BLUE}📋 INSTALLATION STEPS:${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "1. Go to: https://www.docker.com/products/docker-desktop"
        echo "2. Download Docker Desktop for Mac"
        echo "3. Install and start Docker Desktop"
    else
        echo "1. Install Docker for your distribution:"
        echo "   • Ubuntu/Debian: sudo apt update && sudo apt install docker.io"
        echo "   • CentOS/RHEL: sudo yum install docker"
        echo "   • Arch: sudo pacman -S docker"
        echo "   • Other: https://docs.docker.com/engine/install/"
        echo ""
        echo "2. Add your user to docker group:"
        echo "   sudo usermod -aG docker \$USER"
        echo "   newgrp docker"
        echo ""
        echo "3. Start Docker service:"
        echo "   sudo systemctl enable --now docker"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 TIP: After installation, log out and back in for group changes${NC}"
    echo ""
    
    read -p "Have you installed and started Docker? (y/n): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Please install Docker first, then run this installer again."
        exit 1
    fi
    
    echo ""
    echo "Checking Docker again..."
    if command -v docker &> /dev/null && docker --version &> /dev/null; then
        echo -e "${GREEN}✓ Docker is now installed${NC}"
    else
        echo -e "${RED}❌ Docker still not detected. Please ensure:${NC}"
        echo "• Docker is installed"
        echo "• Your user is in the docker group"
        echo "• You've logged out and back in"
        echo "• Docker service is running"
        exit 1
    fi
}

# Function to check if Docker daemon is running
check_docker_running() {
    echo -e "${YELLOW}[2/4] Checking if Docker daemon is running...${NC}"
    
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
    echo -e "${YELLOW}[3/4] Cleaning up any existing installation...${NC}"
    
    if docker ps -a --format "table {{.Names}}" | grep -q "starbase1_system_monitor"; then
        echo "Stopping and removing existing container..."
        docker stop starbase1_system_monitor 2>/dev/null || true
        docker rm starbase1_system_monitor 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Cleanup complete${NC}"
}

# Function to start the container
start_container() {
    echo -e "${YELLOW}[4/4] Starting Starbase1 System Monitor...${NC}"
    
    # Try docker-compose first if available
    if [[ -f "docker-compose.yml" ]] && command -v docker-compose &> /dev/null; then
        echo "Using Docker Compose..."
        
        # Use platform-specific compose file if on macOS
        if [[ "$OSTYPE" == "darwin"* ]] && [[ -f "docker-compose.macos.yml" ]]; then
            echo "Using macOS-specific configuration..."
            if docker-compose -f docker-compose.macos.yml up -d --build; then
                echo -e "${GREEN}✓ Container started with Docker Compose (macOS)${NC}"
                return 0
            fi
        else
            if docker-compose up -d --build; then
                echo -e "${GREEN}✓ Container started with Docker Compose${NC}"
                return 0
            fi
        fi
        echo "Docker Compose failed, building locally..."
    fi
    
    # Build locally
    echo "Building image locally..."
    if ! docker build -t starbase1-monitor .; then
        echo -e "${RED}ERROR: Failed to build the system monitor${NC}"
        echo "Please check that all files are present"
        exit 1
    fi
    
    # Determine the correct Docker socket path
    DOCKER_SOCK=""
    if [[ -S "/var/run/docker.sock" ]]; then
        DOCKER_SOCK="-v /var/run/docker.sock:/var/run/docker.sock:ro"
    fi
    
    # Determine platform-specific options
    VOLUME_MOUNTS=""
    EXTRA_ENV=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS doesn't have /proc or /sys
        echo "Configuring for macOS..."
        EXTRA_ENV="-e DISABLE_HARDWARE_MONITORING=true -e DISABLE_TEMPERATURE_MONITORING=true"
    else
        # Linux has these system directories
        VOLUME_MOUNTS="-v /proc:/host/proc:ro -v /sys:/host/sys:ro -v /etc/os-release:/host/os-release:ro"
        EXTRA_ENV="-e HOST_PROC=/host/proc -e HOST_SYS=/host/sys"
    fi
    
    # Start the container
    if docker run -d \
        --name starbase1_system_monitor \
        -p 8080:8080 \
        $VOLUME_MOUNTS \
        $DOCKER_SOCK \
        -e CONTAINER_MODE=true \
        $EXTRA_ENV \
        --restart unless-stopped \
        starbase1-monitor:latest; then
        
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
    echo -e "${BLUE}📊  http://localhost:8080${NC}"
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
                open http://localhost:8080
            elif command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:8080
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
    start_container
    show_success
}

# Run the installer
main "$@"