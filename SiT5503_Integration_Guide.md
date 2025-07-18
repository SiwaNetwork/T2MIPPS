# Руководство по интеграции SiT5503

## Быстрый старт

### 1. Подготовка оборудования

#### Требуемые компоненты:
- FPGA плата с Lattice LFE5U-25F-6BG256C
- SiT5503 генератор (Digital Control версия)
- Резисторы подтяжки I2C: 2x 4.7 кОм
- Конденсаторы развязки: 2x 100 нФ

#### Рекомендуемая конфигурация SiT5503:
- **Частота**: 10.000000 МГц
- **Диапазон подстройки**: ±25 ppm (код M)
- **Напряжение**: 3.3В
- **Корпус**: 7.0 x 5.0 мм

### 2. Подключение SiT5503

```
Схема подключения:

VCC (3.3V) ──┬── SiT5503 Pin 4 (VDD)
             ├── SiT5503 Pin 10 (VDD)
             ├── SiT5503 Pin 1 (OE) - через 1кОм
             └── 4.7кОм ──┬── H1 (SCL)
                          └── H2 (SDA)

GND ─────────┬── SiT5503 Pin 2 (GND)
             ├── SiT5503 Pin 9 (GND)
             ├── SiT5503 Pin 6 (A1)
             └── SiT5503 Pin 7 (A0)

F2 ────────── SiT5503 Pin 3 (CLK)
H1 ────────── SiT5503 Pin 8 (SCL)
H2 ────────── SiT5503 Pin 5 (SDA)
```

### 3. Программирование FPGA

1. Откройте `T2MI_PPS_Generator.ldf` в Diamond Lattice
2. Убедитесь, что используется `t2mi_pps_top_v2.v` как top-level
3. Запустите синтез: **Process → Run All**
4. Проверьте отсутствие ошибок в отчетах
5. Загрузите битстрим в FPGA

### 4. Проверка работоспособности

#### Индикаторы состояния:
- **led_power**: Должен гореть постоянно
- **led_sit5503**: Должен загореться через ~1 секунду
- **led_sync**: Загорится при подаче T2-MI сигнала
- **led_pps**: Мигает 1 раз в секунду

#### Последовательность запуска:
1. Подача питания → led_power горит
2. Инициализация SiT5503 → led_sit5503 мигает
3. Готовность SiT5503 → led_sit5503 горит постоянно
4. Подача T2-MI → led_sync горит
5. Генерация PPS → led_pps мигает

### 5. Диагностика проблем

#### SiT5503 не готов (led_sit5503 мигает):
- Проверьте питание 3.3В
- Проверьте I2C подключение
- Убедитесь в наличии подтяжек

#### Нет PPS (led_pps не мигает):
- Проверьте готовность SiT5503
- Подайте T2-MI сигнал или активируйте автономный режим
- Проверьте назначение пинов

#### Нет синхронизации (led_sync не горит):
- Проверьте T2-MI сигнал
- Убедитесь в наличии пакетов типа 0x20
- Проверьте целостность данных

## Расширенная настройка

### Изменение I2C адреса SiT5503

По умолчанию используется адрес 0x68. Для изменения:

1. Измените параметр в `sit5503_controller.v`:
```verilog
parameter SIT5503_I2C_ADDR = 7'h68;  // Новый адрес
```

2. Настройте пины A0/A1 на SiT5503 соответственно

### Настройка диапазона подстройки

Для изменения диапазона подстройки частоты:

1. Выберите соответствующий код при заказе SiT5503
2. Обновите параметр в контроллере:
```verilog
parameter MAX_OFFSET_PPM = 25;  // Новый диапазон
```

### Принудительный автономный режим

Для тестирования автономного режима:

```verilog
assign force_autonomous_mode = 1'b1;  // В t2mi_pps_top_v2.v
```

## Мониторинг и отладка

### Регистры состояния

#### debug_status[7:0]:
- **[0]**: Ошибка T2-MI парсера
- **[1]**: Ошибка временных штампов  
- **[2]**: SiT5503 готов
- **[3]**: Автономный режим
- **[4]**: Запрос калибровки
- **[5]**: Калибровка завершена
- **[6]**: Высокая ошибка времени
- **[7]**: Ошибка SiT5503

#### pps_status[7:0]:
- **[0]**: Инициализация
- **[1]**: Ожидание синхронизации
- **[2]**: Синхронизирован
- **[3]**: Автономный режим
- **[4]**: Калибровка активна
- **[5]**: Использование SiT5503
- **[6]**: Время валидно
- **[7]**: Ошибка системы

### Измерение точности

Для измерения точности PPS:

1. Подключите осциллограф к выводу E1 (pps_out)
2. Используйте внешний эталон времени
3. Измерьте джиттер и долговременную стабильность
4. Ожидаемые значения:
   - Джиттер: < 10 нс RMS
   - Долговременная стабильность: < 50 нс за 24 часа

## Техническая поддержка

### Часто задаваемые вопросы

**Q: Можно ли использовать другой генератор вместо SiT5503?**
A: Да, но потребуется модификация I2C контроллера под новый протокол.

**Q: Какая максимальная точность достижима?**
A: При использовании SiT5503 и качественного T2-MI сигнала - ±5 нс.

**Q: Сколько времени работает автономный режим?**
A: При температуре ±5°C точность сохраняется 24+ часов.

**Q: Можно ли использовать несколько SiT5503?**
A: Текущая версия поддерживает один генератор. Для нескольких нужна модификация.


*Данное руководство покрывает основные аспекты интеграции SiT5503. Для специфических применений может потребоваться дополнительная настройка.*

