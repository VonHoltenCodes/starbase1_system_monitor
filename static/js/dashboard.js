// Starbase1_IO Dashboard JavaScript
// Windows 95 Style System Monitor

class Starbase1Dashboard {
    constructor() {
        this.refreshInterval = 2000; // 2 seconds
        this.isConnected = true;
        this.retryCount = 0;
        this.maxRetries = 5;
        
        this.init();
    }
    
    init() {
        this.updateClock();
        this.startAutoRefresh();
        this.bindEvents();
        
        // Initial data load
        this.loadAllData();
        
        console.log('Starbase1_IO Dashboard initialized');
    }
    
    bindEvents() {
        // Window controls
        document.querySelectorAll('.window-button').forEach(button => {
            button.addEventListener('click', this.handleWindowControl.bind(this));
        });
        
        // Menu items
        document.querySelectorAll('.menu-item').forEach(item => {
            item.addEventListener('click', this.handleMenuClick.bind(this));
        });
        
        // Start button
        const startButton = document.querySelector('.start-button');
        if (startButton) {
            startButton.addEventListener('click', this.handleStartClick.bind(this));
        }
    }
    
    handleWindowControl(event) {
        const control = event.target.textContent;
        switch(control) {
            case '_':
                console.log('Minimize clicked');
                break;
            case '□':
                console.log('Maximize clicked');
                break;
            case '×':
                console.log('Close clicked');
                break;
        }
    }
    
    handleMenuClick(event) {
        const menuItem = event.target.textContent;
        console.log(`Menu clicked: ${menuItem}`);
        
        // Add visual feedback
        event.target.style.background = '#0080ff';
        event.target.style.color = 'white';
        setTimeout(() => {
            event.target.style.background = '';
            event.target.style.color = '';
        }, 200);
    }
    
    handleStartClick(event) {
        console.log('Start button clicked');
        
        // Add visual feedback
        const button = event.target;
        button.style.border = '2px inset #c0c0c0';
        setTimeout(() => {
            button.style.border = '2px outset #c0c0c0';
        }, 150);
    }
    
    updateClock() {
        const now = new Date();
        const timeString = now.toLocaleTimeString('en-US', {
            hour12: false,
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
        
        const clockElement = document.getElementById('currentTime');
        if (clockElement) {
            clockElement.textContent = timeString;
        }
        
        const taskbarClock = document.getElementById('taskbar-time');
        if (taskbarClock) {
            taskbarClock.textContent = timeString;
        }
        
        // Update every second
        setTimeout(() => this.updateClock(), 1000);
    }
    
    startAutoRefresh() {
        setInterval(() => {
            this.loadAllData();
        }, this.refreshInterval);
    }
    
    async loadAllData() {
        try {
            await Promise.all([
                this.loadSystemData(),
                this.loadSecurityData(),
                this.loadServiceData()
            ]);
            
            this.updateConnectionStatus(true);
            this.retryCount = 0;
            
        } catch (error) {
            console.error('Error loading data:', error);
            this.updateConnectionStatus(false);
            this.handleRetry();
        }
    }
    
    async loadSystemData() {
        try {
            const response = await fetch('/api/system');
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            
            const data = await response.json();
            this.updateSystemDisplay(data);
            
        } catch (error) {
            console.error('System data error:', error);
            this.showError('system', 'Failed to load system data');
        }
    }
    
    async loadSecurityData() {
        try {
            const response = await fetch('/api/security');
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            
            const data = await response.json();
            this.updateSecurityDisplay(data);
            
        } catch (error) {
            console.error('Security data error:', error);
            this.showError('security', 'Failed to load security data');
        }
    }
    
    async loadServiceData() {
        try {
            const response = await fetch('/api/services');
            if (!response.ok) throw new Error(`HTTP ${response.status}`);
            
            const data = await response.json();
            this.updateServiceDisplay(data);
            
        } catch (error) {
            console.error('Service data error:', error);
            this.showError('services', 'Failed to load service data');
        }
    }
    
    updateSystemDisplay(data) {
        // CPU Information
        this.updateElement('cpuModel', data.cpu?.model || 'Unknown');
        this.updateElement('cpuUsage', data.cpu?.usage ? `${data.cpu.usage.toFixed(1)}%` : 'N/A');
        this.updateElement('cpuSpeed', data.cpu?.frequency ? `${(data.cpu.frequency / 1000).toFixed(2)} GHz` : 'N/A');
        
        // Memory Information
        if (data.memory) {
            const memUsed = this.formatBytes(data.memory.used);
            const memTotal = this.formatBytes(data.memory.total);
            const memPercent = ((data.memory.used / data.memory.total) * 100).toFixed(1);
            
            this.updateElement('memoryUsed', memUsed);
            this.updateElement('memoryTotal', memTotal);
            this.updateElement('memoryPercent', `${memPercent}%`);
        }
        
        // Temperature Information  
        if (data.temperatures && Array.isArray(data.temperatures) && data.temperatures.length > 0) {
            const cpuTemp = data.temperatures.find(t => 
                t.label && (t.label.toLowerCase().includes('cpu') || t.label.toLowerCase().includes('core'))
            );
            
            if (cpuTemp && cpuTemp.current) {
                this.updateElement('cpuTemp', `${cpuTemp.current.toFixed(1)}°C`);
            } else {
                this.updateElement('cpuTemp', 'N/A');
            }
            
            const systemTemp = data.temperatures.find(t => 
                t.label && t.label.toLowerCase().includes('system')
            );
            
            if (systemTemp && systemTemp.current) {
                this.updateElement('systemTemp', `${systemTemp.current.toFixed(1)}°C`);
            } else {
                this.updateElement('systemTemp', 'N/A');
            }
        } else {
            this.updateElement('cpuTemp', 'N/A');
            this.updateElement('systemTemp', 'N/A');
        }
        
        // BIOS Information
        if (data.bios) {
            this.updateElement('biosVendor', data.bios.vendor || 'Unknown');
            this.updateElement('biosVersion', data.bios.version || 'Unknown');
            this.updateElement('motherboard', data.bios.motherboard || 'Unknown');
        }
        
        // Disk Information
        if (data.disks && Array.isArray(data.disks)) {
            this.updateElement('driveCount', data.disks.length.toString());
            
            if (data.disks.length > 0) {
                const primaryDisk = data.disks[0];
                if (primaryDisk) {
                    this.updateElement('diskUsage', this.formatBytes(primaryDisk.used || 0));
                    this.updateElement('diskFree', this.formatBytes(primaryDisk.free || 0));
                }
            }
        }
        
        // Network Information
        if (data.network) {
            this.updateElement('networkIn', this.formatBytes(data.network.bytes_recv || 0));
            this.updateElement('networkOut', this.formatBytes(data.network.bytes_sent || 0));
        }
        
        // Boot Time and Uptime
        if (data.boot_time) {
            const bootDate = new Date(data.boot_time * 1000);
            this.updateElement('bootTime', bootDate.toLocaleString());
        }
        
        if (data.uptime) {
            this.updateElement('uptime', this.formatUptime(data.uptime));
        }
    }
    
    updateSecurityDisplay(data) {
        // Update user count
        const userCount = data.active_users ? data.active_users.length : 0;
        this.updateElement('userCount', `(${userCount})`);
        
        // Update user list
        const userList = document.getElementById('userList');
        if (userList && data.active_users) {
            if (data.active_users.length === 0) {
                userList.innerHTML = '<div class="loading">No active users</div>';
            } else {
                userList.innerHTML = data.active_users.map(user => 
                    `<div class="listview-item">
                        <span>${user.name}</span>
                        <span>${user.terminal || 'console'}</span>
                        <span>${user.started || 'Unknown'}</span>
                    </div>`
                ).join('');
            }
        }
        
        // Update security events
        if (data.failed_logins !== undefined) {
            this.updateElement('failedLogins', data.failed_logins.toString());
        }
        
        if (data.last_failure) {
            this.updateElement('lastFailure', data.last_failure);
        } else {
            this.updateElement('lastFailure', 'None');
        }
    }
    
    updateServiceDisplay(data) {
        const servicesList = document.getElementById('servicesList');
        if (!servicesList) return;
        
        if (data.services && Array.isArray(data.services)) {
            if (data.services.length === 0) {
                servicesList.innerHTML = '<div class="loading">No services monitored</div>';
            } else {
                servicesList.innerHTML = data.services.map(service => {
                    const statusClass = service.status === 'active' ? 'status-good' : 'status-error';
                    const statusIcon = service.status === 'active' ? '🟢' : '🔴';
                    
                    return `<div class="listview-item">
                        <span>${statusIcon} ${service.name}</span>
                        <span class="${statusClass}">${service.status}</span>
                    </div>`;
                }).join('');
            }
        } else {
            servicesList.innerHTML = '<div class="loading">Loading services...</div>';
        }
    }
    
    updateElement(id, value) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        }
    }
    
    showError(section, message) {
        console.error(`${section}: ${message}`);
        
        // Show error in relevant sections
        const errorElements = document.querySelectorAll(`[id*="${section}"]`);
        errorElements.forEach(el => {
            if (el.tagName === 'DIV') {
                el.innerHTML = `<div class="error">${message}</div>`;
            } else {
                el.textContent = 'Error';
            }
        });
    }
    
    updateConnectionStatus(connected) {
        this.isConnected = connected;
        
        const statusElement = document.getElementById('connectionStatus');
        if (statusElement) {
            if (connected) {
                statusElement.textContent = 'Connected';
                statusElement.className = 'status-panel status-good';
            } else {
                statusElement.textContent = 'Disconnected';
                statusElement.className = 'status-panel status-error';
            }
        }
        
        const systemStatus = document.getElementById('systemStatus');
        if (systemStatus) {
            if (connected) {
                systemStatus.textContent = 'Online';
                systemStatus.className = 'status-good';
            } else {
                systemStatus.textContent = 'Offline';
                systemStatus.className = 'status-error';
            }
        }
    }
    
    updateElement(id, value) {
        const element = document.getElementById(id);
        if (element) {
            element.textContent = value;
        } else {
            console.warn(`Element with id '${id}' not found`);
        }
    }
    
    showError(section, message) {
        console.error(`Error in ${section}: ${message}`);
        // Optionally update UI to show error state
    }
    
    handleRetry() {
        if (this.retryCount < this.maxRetries) {
            this.retryCount++;
            console.log(`Retrying data load (${this.retryCount}/${this.maxRetries})`);
            
            setTimeout(() => {
                this.loadAllData();
            }, 5000); // Retry after 5 seconds
        } else {
            console.error('Max retries reached, stopping auto-refresh');
            this.updateConnectionStatus(false);
        }
    }
    
    formatBytes(bytes) {
        if (bytes === 0) return '0 B';
        
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }
    
    formatUptime(seconds) {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        
        if (days > 0) {
            return `${days}d ${hours}h ${minutes}m`;
        } else if (hours > 0) {
            return `${hours}h ${minutes}m`;
        } else {
            return `${minutes}m`;
        }
    }
}

// Initialize the dashboard when the page loads
document.addEventListener('DOMContentLoaded', () => {
    window.starbase1Dashboard = new Starbase1Dashboard();
});