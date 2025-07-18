# Руководство по интеграции T2MI PPS Generator

## Быстрый старт

### 1. Требования
- FPGA: Lattice ECP5 LFE5U-25F-6BG256C
- Питание: 3.3V/1.2V, 2-3W
- Lattice Diamond 3.12+
- Python 3.7+

### 2. Сборка прошивки
```bash
git clone https://github.com/your-org/t2mi-pps-generator.git
cd t2mi-pps-generator
make all CONFIG=production
```

### 3. Программирование
```bash
# JTAG программирование
pgrcmd -infile impl1/T2MI_PPS_Generator_impl1.xcf
```

### 4. Подключения
- T2-MI вход: 8-битная шина данных, 27MHz
- PPS выход: BNC разъем, 50Ω
- UART консоль: 115200 8N1
- I2C (SiT5503): 400kHz
- SPI (STM32): до 10MHz

### 5. Первый запуск
```bash
# Подключение к консоли
screen /dev/ttyUSB0 115200

# Проверка статуса
> status
> test all
```

## Детальная документация
См. файлы:
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
