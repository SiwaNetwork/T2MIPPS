# Руководство пользователя T2MI PPS Generator

## Содержание

1. [Быстрый старт](#быстрый-старт)
2. [Установка и настройка](#установка-и-настройка)
3. [Веб-интерфейс](#веб-интерфейс)
4. [SNMP управление](#snmp-управление)
5. [Компенсация задержек](#компенсация-задержек)
6. [Внешние источники PPS](#внешние-источники-pps)
7. [Интеграция SiT5503](#интеграция-sit5503)
8. [Диагностика и устранение неполадок](#диагностика-и-устранение-неполадок)

## Быстрый старт

### Минимальная конфигурация

1. **Подключите обязательные сигналы:**
   - Питание: 3.3V и 1.2V
   - Тактовая 100 МГц → пин P3
   - Сброс (с подтяжкой) → пин T1
   - T2MI данные и тактовая

2. **Запрограммируйте FPGA:**
   ```bash
   pgrcmd -infile impl1/T2MI_PPS_Generator_impl1.xcf
   ```

3. **Проверьте работу:**
   - LED статуса должен мигать
   - PPS выход должен генерировать импульсы 1 Гц

## Установка и настройка

### Требования к системе

- **Аппаратные:**
  - FPGA Lattice LFE5U-25F-6BG256C
  - Источник T2MI потока (спутниковый ресивер)
  - Блок питания 3.3V/1.2V, минимум 3W
  - (Опционально) SiT5503 осциллятор
  - (Опционально) GNSS приемник с PPS выходом

- **Программные:**
  - Lattice Diamond 3.14 или новее
  - Python 3.7+ (для веб-интерфейса)
  - SNMP утилиты (для SNMP управления)

### Пошаговая установка

#### 1. Сборка проекта

```bash
# Через командную строку
cd /path/to/project
make clean
make all

# Или через GUI Lattice Diamond:
# 1. File → Open → Project
# 2. Выберите T2MI_PPS_Generator.ldf
# 3. Process → Run All
```

#### 2. Подключение оборудования

**Основные соединения:**

| Сигнал | FPGA пин | Описание |
|--------|----------|----------|
| CLK_100MHZ | P3 | Системная тактовая 100 МГц |
| RST_N | T1 | Сброс (активный низкий) |
| T2MI_CLK | P4 | Тактовая T2MI 27 МГц |
| T2MI_DATA[7:0] | R1-R4, T2-T4, P1-P2 | Данные T2MI |
| T2MI_VALID | N1 | Строб данных |
| T2MI_SYNC | N2 | Синхронизация |
| PPS_OUT | M1 | Выход PPS |
| UART_TX/RX | K1/K2 | Консоль 115200 |

**Дополнительные интерфейсы:**

| Сигнал | FPGA пин | Описание |
|--------|----------|----------|
| I2C_SCL/SDA | H1/H2 | I2C для SiT5503 |
| SPI_MISO/MOSI/SCK/CS | G1/G2/F1/F2 | SPI для STM32 |
| EXT_PPS_IN | E1 | Внешний PPS вход |
| GNSS_PPS_IN | E2 | GNSS PPS вход |

#### 3. Первоначальная настройка

```bash
# Подключитесь к UART консоли
screen /dev/ttyUSB0 115200

# Проверьте статус системы
> status
System Status: OPERATIONAL
T2MI Lock: YES
PPS Output: ACTIVE
Phase Error: -2.3 ns
Frequency Error: 0.012 ppb

# Выполните самотестирование
> test all
Running self-test...
[PASS] Clock detection
[PASS] T2MI interface
[PASS] Timestamp extraction
[PASS] PPS generation
[PASS] I2C interface
All tests passed!
```

## Веб-интерфейс

### Запуск веб-сервера

```bash
cd web_interface
pip install -r requirements.txt
python app.py
```

Откройте браузер: `http://localhost:5000`

### Функции веб-интерфейса

#### 1. Dashboard (Главная панель)
- Реальное время статистики
- График фазовой ошибки
- Состояние синхронизации
- Счетчики PPS импульсов

#### 2. Configuration (Конфигурация)
- **PPS Settings:**
  - Pulse Width: 10µs - 500ms
  - Polarity: Positive/Negative
  - Output Enable: On/Off

- **DPLL Settings:**
  - Bandwidth: 0.1Hz - 10Hz
  - Damping Factor: 0.5 - 2.0
  - Lock Threshold: 10ns - 1000ns

- **Source Selection:**
  - Auto/Manual mode
  - Priority: T2MI → GNSS → External

#### 3. Satellite Delay (Компенсация задержки)
- Enable/Disable compensation
- Delay value: 0 - 500ms
- Fine adjustment: ±10µs

#### 4. Diagnostics (Диагностика)
- Детальные логи системы
- Экспорт статистики
- Allan deviation график
- MTIE анализ

### API веб-интерфейса

```python
# Получение статуса
GET /api/status

# Обновление конфигурации
POST /api/config
{
    "pps_width": 100000,  # наносекунды
    "dpll_bandwidth": 1.0,  # Гц
    "satellite_delay": 119500000  # наносекунды
}

# Получение статистики
GET /api/statistics?period=hour
```

## SNMP управление

### Запуск SNMP агента

```bash
cd snmp_agent
pip install -r requirements.txt
sudo python snmp_agent.py
```

### OID структура

База: `1.3.6.1.4.1.99999`

| OID | Параметр | Тип | Доступ |
|-----|----------|-----|--------|
| .1.1.0 | systemStatus | Integer | RO |
| .1.2.0 | ppsCount | Counter32 | RO |
| .1.3.0 | phaseError | Integer | RO |
| .1.4.0 | frequencyError | Integer | RO |
| .1.5.0 | temperature | Integer | RO |
| .1.6.0 | satelliteDelay | Integer | RW |
| .1.7.0 | dpllState | Integer | RO |
| .1.8.0 | ppsSource | Integer | RW |

### Примеры SNMP команд

```bash
# Получить статус системы
snmpget -v2c -c public localhost 1.3.6.1.4.1.99999.1.1.0

# Получить все параметры
snmpwalk -v2c -c public localhost 1.3.6.1.4.1.99999

# Установить задержку спутника (в микросекундах)
snmpset -v2c -c private localhost 1.3.6.1.4.1.99999.1.6.0 i 119500

# Мониторинг в реальном времени
watch -n 1 'snmpget -v2c -c public localhost \
    1.3.6.1.4.1.99999.1.3.0 \
    1.3.6.1.4.1.99999.1.4.0'
```

## Компенсация задержек

### Типы задержек

1. **Спутниковая задержка**
   - Геостационарный: ~119-120 мс
   - MEO: ~50-70 мс
   - LEO: ~5-20 мс

2. **Оборудование**
   - Модулятор: ~1-5 мс
   - Декодер: ~0.5-2 мс
   - Кабели: ~5 нс/м

### Настройка компенсации

#### Через веб-интерфейс:
1. Перейдите в раздел "Satellite Delay"
2. Включите "Enable Compensation"
3. Введите значение задержки в мс
4. Нажмите "Apply"

#### Через UART консоль:
```bash
# Установить задержку 119.5 мс
> set_sat_delay 119500

# Включить компенсацию
> sat_comp_enable 1

# Проверить текущие настройки
> get_sat_delay
Satellite delay: 119500 us
Compensation: ENABLED
```

#### Через SNMP:
```bash
# Установить задержку (в микросекундах)
snmpset -v2c -c private localhost 1.3.6.1.4.1.99999.1.6.0 i 119500
```

### Калибровка задержки

1. **Автоматическая калибровка** (требуется внешний PPS):
   ```bash
   > calibrate_delay_auto
   Measuring delay...
   Detected delay: 119.523 ms
   Apply this value? (y/n): y
   Delay compensation updated.
   ```

2. **Ручная калибровка**:
   - Измерьте разницу между эталонным и выходным PPS
   - Введите измеренное значение
   - Проверьте результат

## Внешние источники PPS

### Поддерживаемые источники

1. **T2MI** (по умолчанию)
   - Извлекается из потока
   - Точность зависит от источника

2. **GNSS**
   - GPS/GLONASS/Galileo/BeiDou
   - Точность: ±30 нс
   - Требования: TTL 3.3V, положительный импульс

3. **External Reference**
   - Любой внешний PPS источник
   - Требования: TTL 3.3V, 10µs-500ms импульс

### Настройка источников

#### Автоматический выбор:
```bash
# Включить автовыбор
> pps_source_mode auto

# Установить приоритеты
> pps_source_priority t2mi gnss external
```

#### Ручной выбор:
```bash
# Выбрать конкретный источник
> pps_source_select gnss

# Проверить текущий источник
> pps_source_status
Active source: GNSS
T2MI: Available (Good)
GNSS: Active (Excellent)
External: Not connected
```

### Мониторинг качества источников

```bash
> pps_quality
Source    Status    Phase_Error  Frequency_Error  Quality
T2MI      Lock      -15.2 ns     0.023 ppb       Good
GNSS      Lock      -2.1 ns      0.002 ppb       Excellent
External  No signal  -            -               -
```

## Интеграция SiT5503

### Подключение

```
FPGA              SiT5503         Компоненты
H1 (SCL) ────────── SCL
H2 (SDA) ────────── SDA
                    │
VCC ──┬─────────────┴── VDD       C1: 100nF
      │                            C2: 10µF
      ├── R1 (4.7kΩ) ── SCL       R1,R2: 4.7kΩ
      └── R2 (4.7kΩ) ── SDA       R3: 1kΩ

J1 (CLK_IN) ──────── CLK_OUT

GND ───────────────── GND
```

### Конфигурация

1. **Включение в проекте:**
   ```verilog
   // В t2mi_pps_top.v
   parameter USE_SIT5503 = 1;
   ```

2. **Настройка через консоль:**
   ```bash
   # Проверить обнаружение
   > sit5503_detect
   SiT5503 detected at address 0x68
   
   # Прочитать статус
   > sit5503_status
   Frequency: 10.000000 MHz
   Adjustment: +0.023 ppm
   Temperature: 25.3°C
   Lock: YES
   ```

3. **Калибровка частоты:**
   ```bash
   # Автокалибровка (требуется эталон)
   > sit5503_calibrate_auto
   
   # Ручная подстройка (ppm)
   > sit5503_adjust -0.015
   ```

### Температурная компенсация

SiT5503 имеет встроенную температурную компенсацию, но можно добавить дополнительную:

```bash
# Включить расширенную компенсацию
> temp_comp_enable 1

# Установить коэффициенты
> temp_comp_coef -0.032 0.0001
```

## Диагностика и устранение неполадок

### Общие проблемы

#### 1. Нет выходного PPS

**Симптомы:** Отсутствие импульсов на выходе PPS

**Проверки:**
```bash
> status
> test pps_output
```

**Решения:**
- Проверьте входной T2MI поток
- Убедитесь в наличии пакетов 0x20
- Проверьте подключение тактовой частоты
- Включите debug режим: `debug_enable 1`

#### 2. Большая фазовая ошибка

**Симптомы:** Phase error > 100 ns

**Решения:**
```bash
# Проверить компенсацию задержки
> get_sat_delay

# Запустить автокалибровку
> calibrate_auto

# Увеличить полосу DPLL
> dpll_bandwidth 2.0

# Сбросить DPLL
> dpll_reset
```

#### 3. Нестабильная синхронизация

**Симптомы:** Частые потери lock

**Решения:**
```bash
# Проверить качество сигнала
> signal_quality

# Включить фильтр Калмана
> kalman_enable 1

# Настроить параметры фильтра
> kalman_config 0.1 0.01

# Проверить стабильность тактовой
> clock_monitor
```

#### 4. Проблемы с I2C/SiT5503

**Симптомы:** I2C timeout, нет связи с SiT5503

**Решения:**
```bash
# Сканировать I2C шину
> i2c_scan
Found devices at: 0x68

# Проверить подтяжки
> i2c_test

# Сбросить I2C
> i2c_reset
```

### Расширенная диагностика

#### Логирование

```bash
# Включить детальное логирование
> log_level debug

# Просмотр логов
> log_show 100

# Фильтрация логов
> log_filter dpll

# Экспорт логов
> log_export
```

#### Статистика производительности

```bash
# Allan deviation
> allan_dev
Tau(s)  Allan_Dev
1       5.2e-11
10      1.8e-11
100     8.3e-12
1000    4.1e-12

# MTIE анализ
> mtie_analysis
Window   MTIE
1s       12 ns
10s      18 ns
100s     25 ns
1000s    31 ns

# Гистограмма фазовых ошибок
> phase_histogram
Range(ns)  Count    Percentage
-10..-5    1234     12.3%
-5..0      3456     34.5%
0..5       4321     43.2%
5..10      989      9.9%
```

#### Тестовые режимы

```bash
# Генерация тестового PPS
> test_mode pps_1hz

# Проверка timestamp extraction
> test_mode timestamp_check

# Стресс-тест DPLL
> test_mode dpll_stress

# Выход из тестового режима
> test_mode off
```

### Сброс и восстановление

#### Мягкий сброс
```bash
> soft_reset
System will restart in 3 seconds...
```

#### Сброс к заводским настройкам
```bash
> factory_reset
WARNING: This will erase all settings!
Continue? (y/n): y
```

#### Резервное копирование настроек
```bash
# Сохранить конфигурацию
> config_save

# Восстановить конфигурацию
> config_restore

# Экспорт конфигурации
> config_export
```

## Приложения

### A. Команды UART консоли

| Команда | Описание |
|---------|----------|
| `status` | Общий статус системы |
| `pps_stats` | Статистика PPS |
| `dpll_status` | Состояние DPLL |
| `test <module>` | Тестирование модуля |
| `set_sat_delay <us>` | Установка задержки |
| `pps_source_select <src>` | Выбор источника PPS |
| `debug_enable <0/1>` | Режим отладки |
| `help` | Список всех команд |

### B. Коды состояния

| Код | Состояние | Описание |
|-----|-----------|----------|
| 0 | INIT | Инициализация |
| 1 | UNLOCKED | Нет синхронизации |
| 2 | LOCKING | Захват синхронизации |
| 3 | LOCKED | Синхронизирован |
| 4 | HOLDOVER | Автономный режим |
| 5 | ERROR | Ошибка |

### C. LED индикация

| LED | Состояние | Значение |
|-----|-----------|----------|
| PWR | Постоянно | Питание включено |
| LOCK | Постоянно | DPLL синхронизирован |
| LOCK | Мигает | Захват синхронизации |
| PPS | Вспышка 1Гц | PPS активен |
| ERR | Постоянно | Критическая ошибка |
| ERR | Мигает | Предупреждение |