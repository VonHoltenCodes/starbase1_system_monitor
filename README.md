<div align="center">

# 🖥️ Starbase1 System Monitor 🖥️

### *A Windows 95-Themed System Monitoring Dashboard*

[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![Windows 95](https://img.shields.io/badge/Windows%2095-008080?style=for-the-badge&logo=windows95&logoColor=white)](https://en.wikipedia.org/wiki/Windows_95)

🎮 **Nostalgia meets modern monitoring** 🎮

![Main Dashboard](screenshots/dashboard_main.png)

**Created by [VonHoltenCodes](https://github.com/VonHoltenCodes)**

</div>

---

## 📋 Table of Contents

- [✨ Features](#-features)
- [🖼️ Screenshots](#️-screenshots)
- [🐳 Installing Docker](#-installing-docker)
- [🚀 Quick Start](#-quick-start)
  - [🪟 Windows](#-windows)
  - [🍎 macOS](#-macos)
  - [🐧 Linux](#-linux)
- [🛠️ Manual Installation](#️-manual-installation)
- [📊 What Gets Monitored](#-what-gets-monitored)
- [🎨 Customization](#-customization)
- [🔧 Troubleshooting](#-troubleshooting)
- [📚 Documentation](#-documentation)
- [🤝 Contributing](#-contributing)
- [📜 License](#-license)
- [⚖️ Legal Notice](#️-legal-notice)

---

## ✨ Features

### 🎯 Core Features
- 📺 **Authentic Windows 95 UI** - Complete with gray window borders, inset/outset styling
- 📊 **Real-time System Monitoring** - Updates every 6 minutes
- 🐳 **Fully Containerized** - Runs anywhere Docker runs
- 🌐 **Cross-Platform** - Windows, macOS, and Linux support
- 🔒 **Secure** - Read-only system access, isolated container

### 💻 Monitoring Capabilities
- 🧮 **CPU** - Usage, model, cores, frequency
- 🧠 **Memory** - Used, total, percentage
- 💾 **Storage** - Disk usage and free space
- 🌡️ **Temperature** - CPU and system temps (Linux only)
- 🔌 **Network** - Bytes sent/received
- 👥 **Users** - Active sessions and failed logins
- ⚙️ **Services** - System service status
- 🖥️ **Hardware** - BIOS and motherboard info

---

## 🖼️ Screenshots

<div align="center">

### 📊 System Overview
![System Overview](screenshots/system_overview.png)

### 🔐 Security Monitoring
![Security Panel](screenshots/security_panel.png)

### ⚙️ Service Status
![Service Status](screenshots/service_status.png)

### 📈 Performance Metrics
![Performance](screenshots/performance_metrics.png)

</div>

---

## 🐳 Installing Docker

Docker is required to run Starbase1 System Monitor. Here's how to install it on each platform:

### 🪟 Windows Docker Installation

<details>
<summary><b>Click for detailed Windows Docker setup</b></summary>

#### System Requirements
- Windows 10 64-bit: Pro, Enterprise, or Education (Build 19041 or higher)
- Windows 11 64-bit: Home, Pro, Enterprise, or Education
- 4GB RAM minimum
- BIOS-level hardware virtualization support enabled

#### Installation Steps

1. **Enable WSL 2** (Windows Subsystem for Linux)
   ```powershell
   # Run as Administrator
   wsl --install
   ```

2. **Download Docker Desktop**
   - Go to [Docker Desktop for Windows](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe)
   - Run the installer
   - Choose "Use WSL 2 instead of Hyper-V" when prompted

3. **Complete Installation**
   - Restart your computer when prompted
   - Start Docker Desktop from the Start menu
   - Wait for "Docker Desktop is running" in the system tray

4. **Verify Installation**
   ```cmd
   docker --version
   docker run hello-world
   ```

#### Troubleshooting Windows Docker
- If virtualization is disabled, enable it in BIOS
- Ensure Windows is fully updated
- Run Docker Desktop as Administrator if issues persist

</details>

### 🍎 macOS Docker Installation

<details>
<summary><b>Click for detailed macOS Docker setup</b></summary>

#### System Requirements
- macOS 11 Big Sur or newer
- Mac with Apple silicon or Intel chip
- 4GB RAM minimum

#### Installation Steps

1. **Download Docker Desktop**
   - For Apple Silicon (M1/M2/M3): [Docker Desktop for Mac with Apple silicon](https://desktop.docker.com/mac/main/arm64/Docker.dmg)
   - For Intel: [Docker Desktop for Mac with Intel chip](https://desktop.docker.com/mac/main/amd64/Docker.dmg)

2. **Install Docker Desktop**
   - Double-click the downloaded `.dmg` file
   - Drag Docker to the Applications folder
   - Double-click Docker.app in Applications

3. **Complete Setup**
   - Accept the license agreement
   - Provide your password for privileged helper installation
   - Wait for "Docker Desktop is running" in the menu bar

4. **Verify Installation**
   ```bash
   docker --version
   docker run hello-world
   ```

#### Troubleshooting macOS Docker
- Grant necessary permissions in System Preferences > Security & Privacy
- Ensure at least 4GB RAM is allocated to Docker
- Reset Docker Desktop to factory defaults if issues persist

</details>

### 🐧 Linux Docker Installation

<details>
<summary><b>Click for detailed Linux Docker setup</b></summary>

#### Ubuntu/Debian Installation

```bash
# Update package index
sudo apt update

# Install prerequisites
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Start and enable Docker
sudo systemctl enable --now docker

# Verify installation
docker --version
docker run hello-world
```

#### Fedora/RHEL/CentOS Installation

```bash
# Install Docker
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Arch Linux Installation

```bash
# Install Docker
sudo pacman -S docker

# Start and enable Docker
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

</details>

---

## 🚀 Quick Start

### 🪟 Windows

<details>
<summary><b>Click to expand Windows instructions</b></summary>

#### Prerequisites
- ✅ Docker Desktop installed (see above)
- 💾 2GB free RAM

#### Installation

1. **Clone or download this repository**
   ```cmd
   git clone https://github.com/VonHoltenCodes/starbase1_system_monitor.git
   cd starbase1_system_monitor
   ```

2. **Test your setup** (optional):
   ```cmd
   test_windows_docker.bat
   ```

3. **Run the installer**:
   ```cmd
   install.bat
   ```

4. **Access the dashboard**:
   - 🌐 Open http://localhost:8080
   - 🎉 Enjoy your retro monitoring!

</details>

### 🍎 macOS

<details>
<summary><b>Click to expand macOS instructions</b></summary>

#### Prerequisites
- ✅ Docker Desktop installed (see above)
- 💾 2GB free RAM

#### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/VonHoltenCodes/starbase1_system_monitor.git
   cd starbase1_system_monitor
   ```

2. **Test your setup** (optional):
   ```bash
   ./test_macos.sh
   ```

3. **Run the installer**:
   ```bash
   ./install.command
   ```
   Or double-click `install.command` in Finder

4. **Access the dashboard**:
   - 🌐 Open http://localhost:8080
   - 🎉 Enjoy your retro monitoring!

</details>

### 🐧 Linux

<details>
<summary><b>Click to expand Linux instructions</b></summary>

#### Prerequisites
- ✅ Docker installed (see above)
- 💾 2GB free RAM

#### Installation

1. **Clone or download this repository**
   ```bash
   git clone https://github.com/VonHoltenCodes/starbase1_system_monitor.git
   cd starbase1_system_monitor
   ```

2. **Run the installer**:
   ```bash
   ./install.sh
   ```

3. **Access the dashboard**:
   - 🌐 Open http://localhost:8080
   - 🎉 Enjoy your retro monitoring!

</details>

---

## 🛠️ Manual Installation

<details>
<summary><b>Docker Compose (Recommended)</b></summary>

```bash
# Clone the repository
git clone https://github.com/VonHoltenCodes/starbase1_system_monitor.git
cd starbase1_system_monitor

# Build and run with Docker Compose
docker-compose up -d --build

# For Windows/macOS (without hardware monitoring)
docker-compose -f docker-compose.windows.yml up -d --build
```

</details>

<details>
<summary><b>Docker CLI</b></summary>

```bash
# Build the image
docker build -t starbase1-monitor .

# Run the container
docker run -d \
  --name starbase1_system_monitor \
  -p 8080:8080 \
  -e CONTAINER_MODE=true \
  --restart unless-stopped \
  starbase1-monitor
```

</details>

---

## 📊 What Gets Monitored

### 🖥️ System Information
```
┌─────────────────────────────┐
│ CPU Usage:       ████░░ 45% │
│ Memory:          ████░░ 8GB │
│ Disk Space:      ███░░░ 60% │
│ Network I/O:     ↓2.1GB ↑1.5GB │
│ Uptime:          2d 14h 30m │
└─────────────────────────────┘
```

### 🔐 Security Monitoring
- 👤 Active user sessions
- 🚫 Failed login attempts
- 🔒 Security event tracking

### ⚙️ Service Health
- ✅ Running services
- ❌ Stopped services
- 🔄 Service status changes

---

## 🎨 Customization

### 🎯 Monitored Services
Edit `config.py` to customize which services to monitor:

```python
MONITORED_SERVICES = [
    'docker',
    'nginx',
    'mysql',
    'postgresql',
    # Add your services here
]
```

### ⏱️ Refresh Interval
Change the update frequency in `config.py`:

```python
REFRESH_INTERVAL = 360000  # milliseconds (default: 6 minutes)
```

---

## 🔧 Troubleshooting

### 🚨 Common Issues

<details>
<summary><b>Dashboard shows "Loading..."</b></summary>

1. Check if container is running:
   ```bash
   docker ps
   ```

2. Check container logs:
   ```bash
   docker logs starbase1_system_monitor
   ```

3. Test API endpoints:
   ```bash
   curl http://localhost:8080/api/system
   ```

</details>

<details>
<summary><b>Port 8080 already in use</b></summary>

1. Find what's using the port:
   ```bash
   # Windows
   netstat -an | findstr :8080
   
   # macOS/Linux
   lsof -i:8080
   ```

2. Stop the conflicting service or change the port in docker-compose.yml

</details>

<details>
<summary><b>Docker not found</b></summary>

1. Ensure Docker Desktop is installed and running
2. For Linux, ensure your user is in the docker group:
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

</details>

---

## 📚 Documentation

### 📖 Setup Guides
- 📘 [Windows Setup Guide](WINDOWS_SETUP.md)
- 📗 [macOS Setup Guide](MACOS_SETUP.md)
- 📙 [Windows Testing Guide](WINDOWS_TESTING.md)

### 🏗️ Development
- 🔄 [Refactor Summary](REFACTOR_SUMMARY.md)
- 🤝 [Windows/macOS Parity](WINDOWS_MAC_PARITY.md)

---

## 🤝 Contributing

We love contributions! Whether it's:

- 🐛 Bug reports
- 💡 Feature requests
- 📝 Documentation improvements
- 💻 Code contributions

Please feel free to:
1. 🍴 Fork the repository
2. 🌿 Create a feature branch
3. 💾 Commit your changes
4. 🚀 Push to your fork
5. 🎯 Open a Pull Request

---

## 📜 License

MIT License

Copyright (c) 2024 Trenton Von Holten

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## ⚖️ Legal Notice

### Fan Art Disclaimer

This project is a fan art creation inspired by the Windows 95 operating system aesthetic. It is not affiliated with, endorsed by, or sponsored by Microsoft Corporation. Windows and Windows 95 are registered trademarks of Microsoft Corporation in the United States and other countries.

This project is created purely for educational and nostalgic purposes, demonstrating modern web technologies while paying homage to classic user interface design.

All trademarks, service marks, trade names, product names, and logos appearing in this project are the property of their respective owners.

---

<div align="center">

### 🌟 Star this repo if you enjoy the nostalgia! 🌟

Made with 💚 and lots of ☕ by [Trenton Von Holten](https://github.com/VonHoltenCodes)

🤖 *Partially generated with [Claude Code](https://claude.ai/)*

![Windows 95 Forever](https://img.shields.io/badge/Windows%2095-Forever-008080?style=for-the-badge)

</div>