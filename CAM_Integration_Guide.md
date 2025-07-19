# Руководство по интеграции CAM модуля в T2MI PPS Generator

## Обзор

Данное руководство описывает интеграцию модуля условного доступа (CAM) в систему T2MI PPS Generator через интерфейс PCMCIA согласно стандартам EN50221 и PC Card.

## Поддерживаемые стандарты

1. **PC Card Standard Volume 2** - Electrical Specification
   - 16-битная шина данных
   - 26-битная адресная шина (64MB адресации)
   - Поддержка Attribute и Common Memory

2. **EN50221** - Common Interface Specification
   - DVB Common Interface protocol
   - Transport Protocol Data Units (TPDU)
   - Session layer management

3. **PCMCIA 2.1** - Personal Computer Memory Card International Association
   - Card detection and power management
   - Hot-plug support

## Архитектура системы

### Модули

1. **cam_interface.v** - Основной интерфейс CAM модуля
   - Управление PCMCIA шиной
   - Детекция и инициализация карты
   - Буферизация данных T2MI

2. **en50221_protocol.v** - Реализация протокола EN50221
   - Link layer protocol
   - TPDU processing
   - Session management

3. **t2mi_pps_top_v3.v** - Главный модуль с интеграцией CAM
   - Интеграция всех компонентов
   - Маршрутизация данных T2MI через CAM

## Подключение CAM модуля

### Физическое подключение (PCMCIA разъем)

```
Сигнал          | Пин PCMCIA | FPGA пин | Описание
----------------|------------|----------|------------------
D[15:0]         | 3-18       | T3-J5    | Шина данных (16 бит)
A[25:0]         | 19-44      | H4-G7    | Адресная шина (26 бит)
CE1#            | 45         | F7       | Card Enable 1
CE2#            | 46         | E7       | Card Enable 2
OE#             | 47         | D7       | Output Enable
WE#             | 48         | C7       | Write Enable
REG#            | 49         | B11      | Register Select
WAIT#           | 50         | A11      | Wait signal
RESET           | 51         | H8       | Reset
CD1#            | 52         | E8       | Card Detect 1
CD2#            | 53         | D8       | Card Detect 2
VCC             | 54         | -        | Power 3.3V/5V
```

### Временные параметры PCMCIA

- Setup time: 100ns
- Hold time: 50ns
- Access time: 250ns
- Recovery time: 100ns

## Процесс активации CAM модуля

### 1. Детекция карты
```
- Проверка сигналов CD1# и CD2# (оба должны быть LOW)
- Включение питания VCC через pcmcia_vcc_en
```

### 2. Инициализация
```
STATE_POWER_UP:
  - Ожидание стабилизации питания (100 циклов)
  
STATE_RESET_CAM:
  - Активация сигнала RESET на 10 циклов
  - Ожидание готовности CAM
```

### 3. Чтение CIS (Card Information Structure)
```
STATE_READ_CIS:
  - Чтение структуры CIS из Attribute Memory
  - Проверка совместимости карты
```

### 4. Согласование буфера (EN50221)
```
STATE_NEGOTIATE:
  - Установка размера буфера (2048 байт по умолчанию)
  - Запись в регистры управления
```

### 5. Создание Transport Connection
```
STATE_CREATE_TC:
  - Отправка команды TAG_CREATE_TC (0x82)
  - Ожидание подтверждения TAG_CREATE_TC_REPLY (0x83)
```

### 6. Рабочий режим
```
STATE_ACTIVE:
  - Обработка T2MI данных через CAM
  - Управление TPDU пакетами
```

## Обработка данных T2MI

### Поток данных без CAM (cam_bypass = 1)
```
T2MI вход → Парсер пакетов → Извлечение timestamp → PPS генератор
```

### Поток данных через CAM (cam_bypass = 0)
```
T2MI вход → CAM интерфейс → CAM модуль → Парсер пакетов → PPS генератор
```

## Управление и мониторинг

### Статусные сигналы

- `cam_present` - CAM модуль обнаружен
- `cam_initialized` - CAM инициализирован
- `cam_error` - Ошибка CAM
- `cam_status[7:0]` - Детальный статус:
  - Бит 0: CIS прочитан
  - Бит 1: Инициализация завершена
  - Бит 2: Буфер согласован
  - Бит 6: Ошибка
  - Бит 7: Готов к работе

### LED индикация

- `led_cam` - Статус CAM:
  - Мигает медленно: CAM не обнаружен
  - Мигает быстро: Инициализация
  - Горит постоянно: CAM активен

## Конфигурация в проекте

### 1. Добавление файлов в проект

```tcl
# В файле T2MI_PPS_Generator.ldf добавить:
<Source name="src/cam_interface.v" type="Verilog" type_short="Verilog"/>
<Source name="src/en50221_protocol.v" type="Verilog" type_short="Verilog"/>
<Source name="src/t2mi_pps_top_v3.v" type="Verilog" type_short="Verilog">
    <Options top_module="t2mi_pps_top_v3"/>
</Source>
```

### 2. Обновление constraints файла

Использовать `constraints/t2mi_pps_v3_cam.lpf` вместо старого файла ограничений.

### 3. Установка top-level модуля

В Diamond Lattice установить `t2mi_pps_top_v3` как top-level модуль.

## Отладка

### Проверка инициализации

1. Мониторинг `cam_status` регистра
2. Проверка состояния state machine через debug_status
3. Анализ сигналов PCMCIA шины

### Типичные проблемы

1. **CAM не обнаруживается**
   - Проверить сигналы CD1# и CD2#
   - Проверить питание VCC

2. **Ошибка инициализации**
   - Проверить временные параметры
   - Убедиться в правильности CIS

3. **Данные не проходят**
   - Проверить cam_bypass сигнал
   - Проверить состояние FIFO буферов

## Совместимость

Система совместима с CAM модулями, поддерживающими:
- DVB Common Interface (EN50221)
- PCMCIA 2.1 / PC Card Standard
- 16-битную шину данных
- 3.3V питание

## Заключение

Интеграция CAM модуля позволяет обрабатывать зашифрованные T2MI потоки перед извлечением временных меток для генерации PPS. Система автоматически определяет наличие CAM модуля и выполняет необходимую инициализацию согласно стандартам EN50221 и PCMCIA.