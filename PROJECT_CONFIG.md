# T2MI PPS Generator Project Configuration
# Конфигурация проекта генератора PPS из T2MI

## Версии топ-модулей / Top Module Versions

### Version 2 (t2mi_pps_top_v2)
**Базовая версия с поддержкой SiT5503**

Функции:
- Парсинг пакетов T2MI
- Извлечение временных меток
- Базовая генерация PPS
- Поддержка высокостабильного осциллятора SiT5503
- Автономный режим работы
- LED индикация состояния

Использование:
- Для базовых применений
- Когда не требуется расширенная фильтрация и мониторинг
- Меньше ресурсов FPGA

### Version 3 (t2mi_pps_top_v3) 
**Полнофункциональная версия со всеми расширенными возможностями**

Дополнительные функции:
- Фильтр Калмана для оценки фазы и частоты
- Продвинутый DPLL с PID-контроллером
- Расчет Allan deviation и MTIE
- Система логирования событий
- UART интерфейс для мониторинга
- Компенсация спутниковой задержки
- Расширенная LED индикация

Использование:
- Для высокоточных применений
- Когда требуется мониторинг и анализ стабильности
- Для систем с компенсацией спутниковой задержки

## Выбор версии / Version Selection

Для изменения используемой версии в проекте Lattice Diamond:

1. Откройте файл `T2MI_PPS_Generator.ldf`
2. Измените параметр `def_top` и `top_module`:
   - Для версии 2: `top_module="t2mi_pps_top_v2"`
   - Для версии 3: `top_module="t2mi_pps_top_v3"`

Текущая активная версия: **t2mi_pps_top_v2**

## Ресурсы FPGA / FPGA Resources

### Version 2 (приблизительно):
- LUTs: ~3,500
- Registers: ~2,800
- Block RAM: 2
- DSP blocks: 0

### Version 3 (приблизительно):
- LUTs: ~8,500
- Registers: ~6,200  
- Block RAM: 8
- DSP blocks: 4

## Дополнительные пины для Version 3 / Additional Pins for Version 3

При использовании версии 3 необходимо назначить дополнительные пины в файле `constraints/t2mi_pps.lpf`:

```
# UART Monitor Interface
LOCATE COMP "uart_rx" SITE "P3";
LOCATE COMP "uart_tx" SITE "P4";
IOBUF PORT "uart_rx" IO_TYPE=LVCMOS33 PULLUP;
IOBUF PORT "uart_tx" IO_TYPE=LVCMOS33;

# Satellite compensation PPS output
LOCATE COMP "pps_compensated" SITE "R1";
IOBUF PORT "pps_compensated" IO_TYPE=LVCMOS33 DRIVE=24 SLEW=FAST;

# Additional LEDs
LOCATE COMP "led_dpll_lock" SITE "E16";
LOCATE COMP "led_uart_activity" SITE "D17";
IOBUF PORT "led_dpll_lock" IO_TYPE=LVCMOS33 DRIVE=8;
IOBUF PORT "led_uart_activity" IO_TYPE=LVCMOS33 DRIVE=8;

# Satellite parameters (can be connected to DIP switches or configured via UART)
LOCATE COMP "satellite_distance_km[31:0]" SITE "A2,B2,C2,D2,E2,F2,G2,H2,A3,B3,C3,D3,E3,F3,G3,H3,A4,B4,C4,D4,E4,F4,G4,H4,A5,B5,C5,D5,E5,F5,G5,H5";
LOCATE COMP "satellite_elevation[15:0]" SITE "J2,K2,L2,M2,N2,P2,R2,T2,J3,K3,L3,M3,N3,P3,R3,T3";
LOCATE COMP "satellite_params_valid" SITE "U2";
```

## Компиляция / Compilation

Для компиляции проекта:

```bash
# Для версии 2 (по умолчанию)
make all

# Для версии 3 - сначала измените top module в .ldf файле, затем:
make all
```

## Симуляция / Simulation

Обе версии поддерживают симуляцию:

```bash
# Основная симуляция
make sim_icarus

# Симуляция парсера пакетов
make sim_parser  

# Симуляция генератора PPS
make sim_pps
```