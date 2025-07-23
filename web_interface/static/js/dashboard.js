// Dashboard JavaScript для T2MI PPS Generator
let socket;
let charts = {};
let statusData = {};

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', function() {
    initializeSocket();
    initializeCharts();
    initializeControls();
    loadInitialData();
});

// Инициализация WebSocket подключения
function initializeSocket() {
    socket = io();
    
    socket.on('connect', function() {
        console.log('WebSocket подключен');
        updateSystemStatus('online', 'Подключено');
        socket.emit('request_status');
    });
    
    socket.on('disconnect', function() {
        console.log('WebSocket отключен');
        updateSystemStatus('offline', 'Отключено');
    });
    
    socket.on('status_update', function(data) {
        statusData = data;
        console.log('Получено обновление статуса:', data);
        updateDashboard(data);
    });
    
    socket.on('config_updated', function(config) {
        console.log('Конфигурация обновлена:', config);
    });
    
    socket.on('command_sent', function(data) {
        console.log('Команда отправлена:', data.command);
    });
}

// Инициализация графиков
function initializeCharts() {
    const chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        animation: {
            duration: 750,
            easing: 'easeInOutQuart'
        },
        scales: {
            x: {
                type: 'time',
                time: {
                    displayFormats: {
                        second: 'HH:mm:ss'
                    }
                },
                title: {
                    display: true,
                    text: 'Время'
                }
            },
            y: {
                title: {
                    display: true,
                    text: 'Значение'
                }
            }
        },
        plugins: {
            legend: {
                display: true
            }
        }
    };
    
    // График частотной ошибки
    const freqCtx = document.getElementById('frequencyChart').getContext('2d');
    charts.frequency = new Chart(freqCtx, {
        type: 'line',
        data: {
            datasets: [{
                label: 'Частотная ошибка (ppb)',
                data: [],
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            ...chartOptions,
            scales: {
                ...chartOptions.scales,
                y: {
                    ...chartOptions.scales.y,
                    title: {
                        display: true,
                        text: 'Частотная ошибка (ppb)'
                    }
                }
            }
        }
    });
    
    // График фазовой ошибки
    const phaseCtx = document.getElementById('phaseChart').getContext('2d');
    charts.phase = new Chart(phaseCtx, {
        type: 'line',
        data: {
            datasets: [{
                label: 'Фазовая ошибка (нс)',
                data: [],
                borderColor: 'rgb(255, 99, 132)',
                backgroundColor: 'rgba(255, 99, 132, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            ...chartOptions,
            scales: {
                ...chartOptions.scales,
                y: {
                    ...chartOptions.scales.y,
                    title: {
                        display: true,
                        text: 'Фазовая ошибка (нс)'
                    }
                }
            }
        }
    });
    
    // График Allan Deviation
    const allanCtx = document.getElementById('allanChart').getContext('2d');
    charts.allan = new Chart(allanCtx, {
        type: 'line',
        data: {
            datasets: [{
                label: 'Allan Deviation',
                data: [],
                borderColor: 'rgb(54, 162, 235)',
                backgroundColor: 'rgba(54, 162, 235, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            ...chartOptions,
            scales: {
                ...chartOptions.scales,
                y: {
                    ...chartOptions.scales.y,
                    title: {
                        display: true,
                        text: 'Allan Deviation'
                    }
                }
            }
        }
    });
    
    // График MTIE
    const mtieCtx = document.getElementById('mtieChart').getContext('2d');
    charts.mtie = new Chart(mtieCtx, {
        type: 'line',
        data: {
            datasets: [{
                label: 'MTIE (нс)',
                data: [],
                borderColor: 'rgb(255, 159, 64)',
                backgroundColor: 'rgba(255, 159, 64, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            ...chartOptions,
            scales: {
                ...chartOptions.scales,
                y: {
                    ...chartOptions.scales.y,
                    title: {
                        display: true,
                        text: 'MTIE (нс)'
                    }
                }
            }
        }
    });
}

// Инициализация элементов управления
function initializeControls() {
    // Кнопки подключения
    document.getElementById('connectBtn').addEventListener('click', function() {
        fetch('/api/connect', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                showNotification('Подключение установлено', 'success');
            } else {
                showNotification('Ошибка подключения', 'error');
            }
        });
    });
    
    document.getElementById('disconnectBtn').addEventListener('click', function() {
        fetch('/api/disconnect', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                showNotification('Отключено', 'info');
            }
        });
    });
    
    // Слайдер полосы пропускания
    const bandwidthSlider = document.getElementById('bandwidthSlider');
    const bandwidthValue = document.getElementById('bandwidthValue');
    
    bandwidthSlider.addEventListener('input', function() {
        bandwidthValue.textContent = this.value;
    });
    
    bandwidthSlider.addEventListener('change', function() {
        updateConfig({ dpll_bandwidth: parseFloat(this.value) });
    });
    
    // Компенсация задержки спутника
    const satDelayEnabled = document.getElementById('satDelayEnabled');
    const satDelayValue = document.getElementById('satDelayValue');
    
    satDelayEnabled.addEventListener('change', function() {
        updateSatelliteDelay();
    });
    
    satDelayValue.addEventListener('change', function() {
        updateSatelliteDelay();
    });
    
    // Кнопка применения задержки спутника
    document.getElementById('applySatDelayBtn').addEventListener('click', function() {
        const enabled = document.getElementById('satDelayEnabled').checked;
        const delay = parseFloat(document.getElementById('satDelayValue').value) || 0;
        
        if (delay <= 0) {
            showNotification('Введите значение задержки больше 0', 'error');
            return;
        }
        
        // Показ загрузки
        document.getElementById('applyResult').innerHTML = `
            <div class="text-center">
                <div class="spinner-border spinner-border-sm text-success" role="status">
                    <span class="visually-hidden">Применение...</span>
                </div>
                <p class="mt-2">Применение задержки спутника...</p>
            </div>
        `;
        
        fetch('/api/satellite_delay/apply', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                delay: delay,
                enable: enabled
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.status === 'success') {
                document.getElementById('applyResult').innerHTML = `
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle"></i> 
                        Задержка спутника применена успешно!
                        <br><small>Задержка: ${data.delay} мс</small>
                        <br><small>Статус: ${data.enabled ? 'Включена' : 'Отключена'}</small>
                    </div>
                `;
                showNotification('Задержка спутника применена', 'success');
            } else {
                document.getElementById('applyResult').innerHTML = `
                    <div class="alert alert-danger">
                        <i class="fas fa-times-circle"></i> 
                        Ошибка применения задержки: ${data.error}
                    </div>
                `;
                showNotification('Ошибка применения задержки', 'error');
            }
        })
        .catch(error => {
            document.getElementById('applyResult').innerHTML = `
                <div class="alert alert-danger">
                    <i class="fas fa-times-circle"></i> 
                    Ошибка применения задержки: ${error}
                </div>
            `;
            showNotification('Ошибка применения задержки', 'error');
        });
    });
}

// Загрузка начальных данных
function loadInitialData() {
    // Загрузка истории
    fetch('/api/history')
        .then(response => response.json())
        .then(data => {
            updateCharts(data);
        })
        .catch(error => {
            console.error('Ошибка загрузки истории:', error);
        });
    
    // Загрузка конфигурации
    fetch('/api/config')
        .then(response => response.json())
        .then(config => {
            updateConfigDisplay(config);
        })
        .catch(error => {
            console.error('Ошибка загрузки конфигурации:', error);
        });
}

// Обновление панели управления
function updateDashboard(data) {
    console.log('Обновление dashboard, PPS count:', data.pps_count);
    // Обновление метрик
    document.getElementById('ppsCount').textContent = data.pps_count || 0;
    document.getElementById('freqError').textContent = (data.frequency_error || 0).toFixed(2);
    document.getElementById('temperature').textContent = (data.temperature || 25).toFixed(1);
    document.getElementById('t2miPackets').textContent = data.t2mi_packets || 0;
    document.getElementById('errorCount').textContent = data.error_count || 0;
    document.getElementById('uptime').textContent = data.uptime || 0;
    
    // Обновление статуса системы
    document.getElementById('syncStatus').textContent = data.sync_status ? 'Да' : 'Нет';
    document.getElementById('dpllLock').textContent = data.dpll_lock ? 'Да' : 'Нет';
    document.getElementById('gnssStatus').textContent = data.gnss_status || 'Нет фикса';
    document.getElementById('holdoverStatus').textContent = data.holdover_status ? 'Да' : 'Нет';
    document.getElementById('satDelayStatus').textContent = data.satellite_delay_active ? 
        `Активна (${data.satellite_delay_value} мс)` : 'Отключена';
    
    // Обновление статуса подключения
    updateSystemStatus(data.system_status, getStatusText(data.system_status));
}

// Обновление графиков
function updateCharts(historyData) {
    const now = new Date();
    
    // Обновление графика частотной ошибки
    if (charts.frequency && historyData.frequency_error) {
        const freqData = historyData.frequency_error.map((value, index) => ({
            x: new Date(now.getTime() - (historyData.frequency_error.length - index) * 1000),
            y: value
        }));
        charts.frequency.data.datasets[0].data = freqData;
        charts.frequency.update('none');
    }
    
    // Обновление графика фазовой ошибки
    if (charts.phase && historyData.phase_error) {
        const phaseData = historyData.phase_error.map((value, index) => ({
            x: new Date(now.getTime() - (historyData.phase_error.length - index) * 1000),
            y: value
        }));
        charts.phase.data.datasets[0].data = phaseData;
        charts.phase.update('none');
    }
    
    // Обновление графика Allan Deviation
    if (charts.allan && historyData.allan_deviation) {
        const allanData = historyData.allan_deviation.map((value, index) => ({
            x: new Date(now.getTime() - (historyData.allan_deviation.length - index) * 1000),
            y: value
        }));
        charts.allan.data.datasets[0].data = allanData;
        charts.allan.update('none');
    }
    
    // Обновление графика MTIE
    if (charts.mtie && historyData.mtie) {
        const mtieData = historyData.mtie.map((value, index) => ({
            x: new Date(now.getTime() - (historyData.mtie.length - index) * 1000),
            y: value
        }));
        charts.mtie.data.datasets[0].data = mtieData;
        charts.mtie.update('none');
    }
}

// Обновление статуса системы
function updateSystemStatus(status, text) {
    const statusIndicator = document.getElementById('systemStatus');
    const statusText = document.getElementById('statusText');
    
    statusIndicator.className = 'status-indicator';
    
    switch(status) {
        case 'online':
            statusIndicator.classList.add('status-online');
            break;
        case 'offline':
            statusIndicator.classList.add('status-offline');
            break;
        case 'error':
            statusIndicator.classList.add('status-error');
            break;
        default:
            statusIndicator.classList.add('status-offline');
    }
    
    statusText.textContent = text;
}

// Получение текста статуса
function getStatusText(status) {
    switch(status) {
        case 'online': return 'Онлайн';
        case 'offline': return 'Офлайн';
        case 'error': return 'Ошибка';
        default: return 'Неизвестно';
    }
}

// Обновление конфигурации
function updateConfig(config) {
    fetch('/api/config', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(config)
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            console.log('Конфигурация обновлена');
        }
    })
    .catch(error => {
        console.error('Ошибка обновления конфигурации:', error);
    });
}

// Обновление отображения конфигурации
function updateConfigDisplay(config) {
    if (config.dpll_bandwidth) {
        document.getElementById('bandwidthSlider').value = config.dpll_bandwidth;
        document.getElementById('bandwidthValue').textContent = config.dpll_bandwidth;
    }
    
    if (config.satellite_delay_enabled !== undefined) {
        document.getElementById('satDelayEnabled').checked = config.satellite_delay_enabled;
    }
    
    if (config.satellite_delay_compensation) {
        document.getElementById('satDelayValue').value = config.satellite_delay_compensation;
    }
}

// Обновление компенсации задержки спутника
function updateSatelliteDelay() {
    const enabled = document.getElementById('satDelayEnabled').checked;
    const delay = parseFloat(document.getElementById('satDelayValue').value) || 0;
    
    fetch('/api/satellite_delay/apply', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            delay: delay,
            enable: enabled
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            showNotification('Компенсация задержки обновлена', 'success');
        } else {
            showNotification('Ошибка обновления компенсации', 'error');
        }
    })
    .catch(error => {
        console.error('Ошибка обновления компенсации:', error);
        showNotification('Ошибка обновления компенсации', 'error');
    });
}

// Показ уведомлений
function showNotification(message, type = 'info') {
    // Создание элемента уведомления
    const notification = document.createElement('div');
    notification.className = `alert alert-${type === 'error' ? 'danger' : type} alert-dismissible fade show position-fixed`;
    notification.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(notification);
    
    // Автоматическое удаление через 5 секунд
    setTimeout(() => {
        if (notification.parentNode) {
            notification.remove();
        }
    }, 5000);
}

// Периодическое обновление истории
setInterval(() => {
    fetch('/api/history')
        .then(response => response.json())
        .then(data => {
            updateCharts(data);
        })
        .catch(error => {
            console.error('Ошибка обновления истории:', error);
        });
}, 5000); // Обновление каждые 5 секунд