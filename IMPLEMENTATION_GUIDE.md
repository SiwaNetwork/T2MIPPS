# Руководство по реализации SNMP агента и веб-интерфейса для T2MI PPS Generator

## Обзор

В проект T2MI PPS Generator добавлены два новых компонента:

1. **SNMP агент** - для удаленного мониторинга через протокол SNMP
2. **Веб-интерфейс** - для настройки и диагностики через браузер

## SNMP Агент

### Описание

SNMP агент предоставляет возможность удаленного мониторинга состояния T2MI PPS генератора через стандартный протокол SNMP v1/v2c.

### Возможности

- Мониторинг статуса системы в реальном времени
- Отслеживание количества сгенерированных PPS импульсов
- Контроль синхронизации и ошибок частоты/фазы
- Мониторинг температуры и статуса GNSS
- Поддержка стандартных SNMP-запросов GET и GETNEXT

### OID структура

База OID: `1.3.6.1.4.1.99999` (пример для частного предприятия)

| OID | Параметр | Описание |
|-----|----------|----------|
| .1.1.0 | systemStatus | Статус системы (0=offline, 1=online, 2=error) |
| .1.2.0 | ppsCount | Количество сгенерированных PPS импульсов |
| .1.3.0 | syncStatus | Статус синхронизации (0=no sync, 1=synced) |
| .1.4.0 | frequencyError | Ошибка частоты в ppb |
| .1.5.0 | phaseError | Ошибка фазы в наносекундах |
| .1.6.0 | temperature | Температура в °C × 100 |
| .1.7.0 | uptime | Время работы в секундах |
| .1.8.0 | lastSyncTime | Время последней синхронизации (Unix timestamp) |
| .1.9.0 | t2miPackets | Количество принятых T2MI пакетов |
| .1.10.0 | errorCount | Общее количество ошибок |
| .1.11.0 | allanDeviation | Allan deviation × 10¹² |
| .1.12.0 | mtie | MTIE в наносекундах |
| .1.13.0 | gnssStatus | Статус GNSS (0=no fix, 1=2D, 2=3D) |
| .1.14.0 | holdoverStatus | Статус holdover (0=normal, 1=holdover) |
| .1.15.0 | dpllLock | Статус блокировки DPLL (0=unlocked, 1=locked) |

### Установка SNMP агента

1. Перейдите в директорию SNMP агента:
```bash
cd snmp_agent
```

2. Установите зависимости:
```bash
pip install -r requirements.txt
```

3. Запустите агент:
```bash
# С правами root для порта 161
sudo python3 snmp_agent.py

# Или на альтернативном порту без root
python3 snmp_agent.py --snmp-port 1161
```

### Параметры запуска SNMP агента

- `--uart-port` - UART порт для связи с FPGA (по умолчанию: /dev/ttyUSB0)
- `--uart-baudrate` - Скорость UART (по умолчанию: 115200)
- `--snmp-port` - SNMP порт (по умолчанию: 161)
- `--community` - SNMP community string (по умолчанию: public)

### Тестирование SNMP агента

Используйте утилиты snmpwalk или snmpget:

```bash
# Получить все параметры
snmpwalk -v2c -c public localhost 1.3.6.1.4.1.99999

# Получить конкретный параметр (например, статус синхронизации)
snmpget -v2c -c public localhost 1.3.6.1.4.1.99999.1.3.0
```

## Веб-интерфейс

### Описание

Веб-интерфейс предоставляет удобную панель управления для настройки и диагностики T2MI PPS генератора через браузер.

### Возможности

- Мониторинг состояния в реальном времени через WebSocket
- Графики истории ошибок частоты и фазы
- Настройка параметров DPLL и компенсации
- Отправка команд управления
- Калибровка и перезагрузка системы
- Адаптивный дизайн для мобильных устройств

### Установка веб-интерфейса

1. Перейдите в директорию веб-интерфейса:
```bash
cd web_interface
```

2. Установите зависимости:
```bash
pip install -r requirements.txt
```

3. Запустите веб-сервер:
```bash
python3 app.py
```

4. Откройте браузер и перейдите по адресу:
```
http://localhost:5000
```

### API эндпоинты

| Метод | Путь | Описание |
|-------|------|----------|
| GET | `/api/status` | Получить текущий статус |
| GET | `/api/config` | Получить конфигурацию |
| POST | `/api/config` | Обновить конфигурацию |
| GET | `/api/history` | Получить историю данных |
| POST | `/api/command` | Отправить команду |
| POST | `/api/reset` | Перезагрузить систему |
| POST | `/api/calibrate` | Запустить калибровку |

### WebSocket события

- `connect` - Подключение клиента
- `disconnect` - Отключение клиента
- `status_update` - Обновление статуса
- `request_update` - Запрос обновления

## Интеграция с FPGA

### UART протокол

Оба компонента используют UART для связи с FPGA. Протокол обмена:

**Запрос статуса:**
```
GET_STATUS
```

**Ответ от FPGA:**
```
STATUS:sync,freq_err,phase_err,temp,pps_count,t2mi_packets,errors,allan_dev,mtie,gnss_status,dpll_lock
```

Пример:
```
STATUS:1,-2.5,0.8,25.3,12345,98765,0,5e-12,45,2,1
```

**Команды конфигурации:**
```
SET_DPLL_BW:0.1
SET_HOLDOVER_TH:100
SET_TEMP_COMP:1
SET_GNSS:1
CALIBRATE
RESET
```

### Модификация Verilog кода

Для поддержки UART интерфейса добавьте в ваш top-level модуль:

```verilog
// UART interface for monitoring
uart_monitor #(
    .BAUD_RATE(115200),
    .CLK_FREQ(100_000_000)
) uart_mon (
    .clk(clk),
    .rst(rst),
    .rx(uart_rx),
    .tx(uart_tx),
    
    // Status inputs
    .sync_status(sync_status),
    .frequency_error(frequency_error),
    .phase_error(phase_error),
    .temperature(temperature),
    .pps_count(pps_count),
    .t2mi_packets(t2mi_packets),
    .error_count(error_count),
    .allan_deviation(allan_deviation),
    .mtie(mtie),
    .gnss_status(gnss_status),
    .dpll_lock(dpll_lock),
    
    // Configuration outputs
    .dpll_bandwidth(dpll_bandwidth),
    .holdover_threshold(holdover_threshold),
    .temp_compensation_en(temp_compensation_en),
    .gnss_enabled(gnss_enabled),
    .calibrate_req(calibrate_req),
    .reset_req(reset_req)
);
```

## Режим демонстрации

Оба компонента поддерживают режим демонстрации без подключения к реальному оборудованию:

- SNMP агент автоматически переключается в демо-режим при отсутствии UART
- Веб-интерфейс также работает с симулированными данными

## Развертывание в production

### Systemd сервисы

Создайте файлы сервисов для автозапуска:

**SNMP агент** (`/etc/systemd/system/t2mi-snmp.service`):
```ini
[Unit]
Description=T2MI PPS SNMP Agent
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/t2mi-pps/snmp_agent
ExecStart=/usr/bin/python3 /opt/t2mi-pps/snmp_agent/snmp_agent.py
Restart=always

[Install]
WantedBy=multi-user.target
```

**Веб-интерфейс** (`/etc/systemd/system/t2mi-web.service`):
```ini
[Unit]
Description=T2MI PPS Web Interface
After=network.target

[Service]
Type=simple
User=t2mi
WorkingDirectory=/opt/t2mi-pps/web_interface
ExecStart=/usr/bin/python3 /opt/t2mi-pps/web_interface/app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Активация сервисов:
```bash
sudo systemctl enable t2mi-snmp t2mi-web
sudo systemctl start t2mi-snmp t2mi-web
```

### Nginx reverse proxy

Для production рекомендуется использовать Nginx:

```nginx
server {
    listen 80;
    server_name t2mi-pps.local;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Мониторинг и алерты

### Интеграция с Zabbix

Пример шаблона для Zabbix:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<zabbix_export>
    <version>5.0</version>
    <templates>
        <template>
            <template>T2MI PPS Generator</template>
            <name>T2MI PPS Generator</name>
            <groups>
                <group>
                    <name>Templates</name>
                </group>
            </groups>
            <items>
                <item>
                    <name>Sync Status</name>
                    <type>SNMPV2</type>
                    <snmp_community>public</snmp_community>
                    <snmp_oid>1.3.6.1.4.1.99999.1.3.0</snmp_oid>
                    <key>t2mi.sync.status</key>
                    <value_type>FLOAT</value_type>
                </item>
                <!-- Добавьте остальные элементы -->
            </items>
            <triggers>
                <trigger>
                    <expression>{T2MI PPS Generator:t2mi.sync.status.last()}=0</expression>
                    <name>T2MI PPS: No synchronization</name>
                    <priority>HIGH</priority>
                </trigger>
            </triggers>
        </template>
    </templates>
</zabbix_export>
```

### Интеграция с Prometheus

Добавьте SNMP exporter для Prometheus:

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 't2mi_pps'
    static_configs:
      - targets:
        - 192.168.1.100  # IP адрес устройства
    metrics_path: /snmp
    params:
      module: [t2mi_pps]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9116  # SNMP exporter
```

## Безопасность

### Рекомендации

1. **SNMP**:
   - Используйте SNMPv3 с аутентификацией в production
   - Ограничьте доступ через firewall
   - Измените community string с "public"

2. **Веб-интерфейс**:
   - Добавьте аутентификацию (например, Flask-Login)
   - Используйте HTTPS в production
   - Ограничьте CORS политику

3. **Общие**:
   - Регулярно обновляйте зависимости
   - Логируйте все критические операции
   - Используйте отдельного пользователя для сервисов

## Устранение неполадок

### SNMP агент не запускается

1. Проверьте права доступа к порту 161
2. Убедитесь, что порт не занят: `sudo netstat -tulpn | grep 161`
3. Проверьте логи: `journalctl -u t2mi-snmp -f`

### Веб-интерфейс не отображает данные

1. Проверьте подключение к UART
2. Проверьте WebSocket соединение в консоли браузера
3. Убедитесь, что FPGA отправляет данные

### Проблемы с производительностью

1. Увеличьте интервал опроса UART
2. Уменьшите количество точек на графиках
3. Используйте кэширование для исторических данных

## Дальнейшее развитие

Возможные улучшения:

1. Добавление поддержки SNMPv3
2. Реализация SNMP traps для критических событий
3. Добавление REST API для интеграции с другими системами
4. Поддержка множественных устройств
5. Экспорт данных в различные форматы
6. Мобильное приложение для мониторинга