// Dashboard JavaScript for T2MI PPS Generator

// Socket.IO connection
const socket = io();

// Chart configurations
let freqChart = null;
let phaseChart = null;
const maxDataPoints = 100;

// Initialize charts
function initCharts() {
    // Frequency Error Chart
    const freqCtx = document.getElementById('freq-chart').getContext('2d');
    freqChart = new Chart(freqCtx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Frequency Error (ppb)',
                data: [],
                borderColor: '#3498db',
                backgroundColor: 'rgba(52, 152, 219, 0.1)',
                borderWidth: 2,
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: false,
                    title: {
                        display: true,
                        text: 'Error (ppb)'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Time'
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });

    // Phase Error Chart
    const phaseCtx = document.getElementById('phase-chart').getContext('2d');
    phaseChart = new Chart(phaseCtx, {
        type: 'line',
        data: {
            labels: [],
            datasets: [{
                label: 'Phase Error (ns)',
                data: [],
                borderColor: '#e74c3c',
                backgroundColor: 'rgba(231, 76, 60, 0.1)',
                borderWidth: 2,
                tension: 0.1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: false,
                    title: {
                        display: true,
                        text: 'Error (ns)'
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: 'Time'
                    }
                }
            },
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
}

// Update status display
function updateStatus(data) {
    // System status
    const statusIndicator = document.getElementById('system-status-indicator');
    const statusText = document.getElementById('system-status-text');
    statusIndicator.className = 'status-indicator status-' + data.system_status;
    statusText.textContent = data.system_status.charAt(0).toUpperCase() + data.system_status.slice(1);

    // Connection status
    const connStatus = document.getElementById('connection-status');
    connStatus.innerHTML = '<i class="fas fa-circle status-indicator status-online"></i> Connected';

    // Metrics
    document.getElementById('pps-count').textContent = data.pps_count.toLocaleString();
    document.getElementById('freq-error').textContent = data.frequency_error.toFixed(1);
    document.getElementById('temperature').textContent = data.temperature.toFixed(1);
    document.getElementById('phase-error').textContent = data.phase_error.toFixed(1);
    document.getElementById('allan-dev').textContent = (data.allan_deviation * 1e12).toFixed(1);
    document.getElementById('mtie').textContent = data.mtie.toFixed(1);
    document.getElementById('t2mi-packets').textContent = data.t2mi_packets.toLocaleString();
    document.getElementById('error-count').textContent = data.error_count.toLocaleString();

    // Sync status
    const syncBadge = document.getElementById('sync-status');
    if (data.sync_status) {
        syncBadge.className = 'badge bg-success';
        syncBadge.textContent = 'Synced';
    } else {
        syncBadge.className = 'badge bg-danger';
        syncBadge.textContent = 'No Sync';
    }

    // DPLL Lock
    const dpllBadge = document.getElementById('dpll-lock');
    if (data.dpll_lock) {
        dpllBadge.className = 'badge bg-success';
        dpllBadge.textContent = 'Locked';
    } else {
        dpllBadge.className = 'badge bg-danger';
        dpllBadge.textContent = 'Unlocked';
    }

    // GNSS Status
    const gnssBadge = document.getElementById('gnss-status');
    const gnssStatusMap = {
        'no_fix': { class: 'bg-danger', text: 'No Fix' },
        '2d_fix': { class: 'bg-warning', text: '2D Fix' },
        '3d_fix': { class: 'bg-success', text: '3D Fix' }
    };
    const gnssInfo = gnssStatusMap[data.gnss_status] || gnssStatusMap['no_fix'];
    gnssBadge.className = 'badge ' + gnssInfo.class;
    gnssBadge.textContent = gnssInfo.text;

    // Holdover status
    const holdoverBadge = document.getElementById('holdover-status');
    if (data.holdover_status) {
        holdoverBadge.className = 'badge bg-warning';
        holdoverBadge.textContent = 'Holdover';
    } else {
        holdoverBadge.className = 'badge bg-success';
        holdoverBadge.textContent = 'Normal';
    }

    // Satellite delay compensation status
    const satDelayBadge = document.getElementById('satellite-delay-status');
    const satDelayValue = document.getElementById('satellite-delay-value');
    if (data.satellite_delay_active) {
        satDelayBadge.className = 'badge bg-info';
        satDelayBadge.textContent = 'Active';
        satDelayValue.textContent = `(${data.satellite_delay_value.toFixed(3)} ms)`;
    } else {
        satDelayBadge.className = 'badge bg-secondary';
        satDelayBadge.textContent = 'Disabled';
        satDelayValue.textContent = '';
    }

    // Uptime
    const uptimeSeconds = data.uptime;
    const hours = Math.floor(uptimeSeconds / 3600);
    const minutes = Math.floor((uptimeSeconds % 3600) / 60);
    const seconds = uptimeSeconds % 60;
    document.getElementById('uptime').textContent = 
        `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

    // Last update
    const lastUpdate = new Date(data.timestamp);
    document.getElementById('last-update').textContent = lastUpdate.toLocaleTimeString();

    // Update charts
    updateCharts(data);
}

// Update charts with new data
function updateCharts(data) {
    const timeLabel = new Date().toLocaleTimeString();

    // Update frequency chart
    if (freqChart.data.labels.length >= maxDataPoints) {
        freqChart.data.labels.shift();
        freqChart.data.datasets[0].data.shift();
    }
    freqChart.data.labels.push(timeLabel);
    freqChart.data.datasets[0].data.push(data.frequency_error);
    freqChart.update('none');

    // Update phase chart
    if (phaseChart.data.labels.length >= maxDataPoints) {
        phaseChart.data.labels.shift();
        phaseChart.data.datasets[0].data.shift();
    }
    phaseChart.data.labels.push(timeLabel);
    phaseChart.data.datasets[0].data.push(data.phase_error);
    phaseChart.update('none');
}

// Load configuration
async function loadConfig() {
    try {
        const response = await fetch('/api/config');
        const config = await response.json();
        
        document.getElementById('dpll-bandwidth').value = config.dpll_bandwidth;
        document.getElementById('holdover-threshold').value = config.holdover_threshold;
        document.getElementById('temp-compensation').checked = config.temperature_compensation;
        document.getElementById('gnss-enabled').checked = config.gnss_enabled;
        document.getElementById('satellite-delay').value = config.satellite_delay_compensation || 0;
        document.getElementById('satellite-delay-enabled').checked = config.satellite_delay_enabled || false;
    } catch (error) {
        console.error('Failed to load configuration:', error);
    }
}

// Save configuration
async function saveConfig() {
    const config = {
        dpll_bandwidth: parseFloat(document.getElementById('dpll-bandwidth').value),
        holdover_threshold: parseInt(document.getElementById('holdover-threshold').value),
        temperature_compensation: document.getElementById('temp-compensation').checked,
        gnss_enabled: document.getElementById('gnss-enabled').checked,
        satellite_delay_compensation: parseFloat(document.getElementById('satellite-delay').value),
        satellite_delay_enabled: document.getElementById('satellite-delay-enabled').checked
    };

    try {
        const response = await fetch('/api/config', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(config)
        });
        
        if (response.ok) {
            showAlert('Configuration saved successfully', 'success');
        } else {
            showAlert('Failed to save configuration', 'danger');
        }
    } catch (error) {
        console.error('Failed to save configuration:', error);
        showAlert('Error saving configuration', 'danger');
    }
}

// Calibrate system
async function calibrate() {
    if (!confirm('Are you sure you want to start calibration? This may take several minutes.')) {
        return;
    }

    try {
        const response = await fetch('/api/calibrate', { method: 'POST' });
        if (response.ok) {
            showAlert('Calibration started', 'info');
        } else {
            showAlert('Failed to start calibration', 'danger');
        }
    } catch (error) {
        console.error('Calibration error:', error);
        showAlert('Error starting calibration', 'danger');
    }
}

// Reset system
async function resetSystem() {
    if (!confirm('Are you sure you want to reset the system? This will restart the PPS generator.')) {
        return;
    }

    try {
        const response = await fetch('/api/reset', { method: 'POST' });
        if (response.ok) {
            showAlert('System reset initiated', 'warning');
        } else {
            showAlert('Failed to reset system', 'danger');
        }
    } catch (error) {
        console.error('Reset error:', error);
        showAlert('Error resetting system', 'danger');
    }
}

// Send custom command
async function sendCommand() {
    const commandInput = document.getElementById('command-input');
    const command = commandInput.value.trim();
    
    if (!command) {
        return;
    }

    try {
        const response = await fetch('/api/command', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ command: command })
        });
        
        const result = await response.json();
        const responseDiv = document.getElementById('command-response');
        
        if (result.status === 'success') {
            responseDiv.innerHTML = `<div class="alert alert-success">Command sent: ${command}</div>`;
        } else {
            responseDiv.innerHTML = `<div class="alert alert-danger">Error: ${result.message || 'Command failed'}</div>`;
        }
        
        commandInput.value = '';
    } catch (error) {
        console.error('Command error:', error);
        document.getElementById('command-response').innerHTML = 
            '<div class="alert alert-danger">Error sending command</div>';
    }
}

// Show alert message
function showAlert(message, type) {
    const alertHtml = `
        <div class="alert alert-${type} alert-dismissible fade show position-fixed top-0 start-50 translate-middle-x mt-3" 
             style="z-index: 1050;">
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', alertHtml);
    
    // Auto-dismiss after 5 seconds
    setTimeout(() => {
        const alert = document.querySelector('.alert');
        if (alert) {
            alert.remove();
        }
    }, 5000);
}

// Load historical data
async function loadHistory() {
    try {
        const response = await fetch('/api/history');
        const history = await response.json();
        
        // Update charts with historical data
        if (history.timestamps.length > 0) {
            const labels = history.timestamps.map(ts => 
                new Date(ts * 1000).toLocaleTimeString()
            );
            
            // Take last maxDataPoints entries
            const startIdx = Math.max(0, labels.length - maxDataPoints);
            
            freqChart.data.labels = labels.slice(startIdx);
            freqChart.data.datasets[0].data = history.frequency_error.slice(startIdx);
            freqChart.update('none');
            
            phaseChart.data.labels = labels.slice(startIdx);
            phaseChart.data.datasets[0].data = history.phase_error.slice(startIdx);
            phaseChart.update('none');
        }
    } catch (error) {
        console.error('Failed to load history:', error);
    }
}

// Socket.IO event handlers
socket.on('connect', () => {
    console.log('Connected to server');
    socket.emit('request_update');
});

socket.on('disconnect', () => {
    console.log('Disconnected from server');
    const connStatus = document.getElementById('connection-status');
    connStatus.innerHTML = '<i class="fas fa-circle status-indicator status-error"></i> Disconnected';
});

socket.on('status_update', (data) => {
    updateStatus(data);
});

// Keyboard shortcuts
document.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' && event.target.id === 'command-input') {
        sendCommand();
    }
});

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    initCharts();
    loadConfig();
    loadHistory();
    
    // Request initial status
    fetch('/api/status')
        .then(response => response.json())
        .then(data => updateStatus(data))
        .catch(error => console.error('Failed to load initial status:', error));
});