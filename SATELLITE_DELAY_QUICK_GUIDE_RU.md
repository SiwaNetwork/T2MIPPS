# Краткое руководство по компенсации задержки спутникового сигнала

## Описание функции

Функция компенсации задержки сигнала позволяет учитывать время распространения сигнала от геостационарного спутника до наземной станции. Это критически важно для точной синхронизации в системах DVB-T2 SFN.

## Типичные значения задержки

- **Геостационарный спутник**: ~119-120 мс (в одну сторону)
- **Двусторонняя задержка**: ~238-240 мс
- **Вариация**: ±1-2 мс в зависимости от местоположения

## Настройка через веб-интерфейс

### 1. Запуск веб-интерфейса

```bash
cd web_interface
python app.py
```

Откройте браузер: `http://localhost:5000`

### 2. Настройка компенсации

1. Перейдите в раздел **Configuration** (Конфигурация)
2. Найдите секцию **Satellite Delay Compensation**
3. Введите значение задержки в миллисекундах:
   - Поле: **Delay Compensation (ms)**
   - Типичное значение: 119.5 или 120.0
   - Точность: до 0.001 мс (1 мкс)
4. Включите компенсацию переключателем **Enable Satellite Delay Compensation**
5. Нажмите **Save Configuration**

### 3. Проверка статуса

На главной панели (Dashboard) отображается:
- **Satellite Delay**: статус компенсации
  - `Active` (синий) - компенсация включена
  - `Disabled` (серый) - компенсация выключена
- Рядом отображается текущее значение задержки

## UART команды

Для управления через UART используйте команды:

```
SET_SAT_DELAY:119.5      # Установить задержку 119.5 мс
SET_SAT_DELAY_EN:1       # Включить компенсацию
SET_SAT_DELAY_EN:0       # Выключить компенсацию
GET_SAT_DELAY            # Получить текущее значение задержки
GET_SAT_DELAY_EN         # Получить статус включения
```

## Интеграция в FPGA

### Подключение модуля компенсации

```verilog
satellite_delay_compensation delay_comp (
    .clk(clk_100mhz),
    .rst_n(rst_n),
    
    // Конфигурация
    .delay_ms(sat_delay_value),        // 32-бит, формат 16.16
    .compensation_enable(sat_delay_en),
    
    // Временные метки
    .time_in(timestamp_in),
    .time_valid_in(timestamp_valid),
    .time_out(timestamp_compensated),
    .time_valid_out(timestamp_valid_out),
    
    // Статус
    .compensation_active(comp_active),
    .current_delay(current_delay_ms)
);
```

### Формат данных

- Задержка хранится в формате fixed-point 16.16
- Пример: 120.5 мс = 0x00785000
- Преобразование: `delay_fixed = delay_ms * 65536`

## Рекомендации по использованию

### 1. Измерение фактической задержки

Перед настройкой измерьте реальную задержку в вашей системе:
- Используйте GPS как эталон времени
- Сравните временные метки входного и выходного сигналов
- Учтите все задержки в цепи обработки

### 2. Постепенная настройка

При первом включении:
1. Начните с типичного значения (119-120 мс)
2. Включите компенсацию
3. Наблюдайте за фазовой ошибкой
4. При необходимости корректируйте значение малыми шагами (0.1-0.5 мс)

### 3. Мониторинг стабильности

После включения компенсации проверьте:
- DPLL сохраняет захват (DPLL Lock = Locked)
- Фазовая ошибка стабильна
- Частотная ошибка в допустимых пределах

## Решение проблем

### Проблема: DPLL теряет захват после включения компенсации

**Решение**: 
- Уменьшите значение задержки на 50%
- Включите компенсацию
- Постепенно увеличивайте задержку до нужного значения

### Проблема: Постоянное смещение по времени

**Решение**:
- Проверьте правильность измерения задержки
- Учтите дополнительные задержки в приемном оборудовании
- Используйте внешний эталон времени для калибровки

### Проблема: Статус не обновляется

**Решение**:
- Проверьте UART соединение
- Убедитесь, что прошивка FPGA поддерживает команды компенсации
- Проверьте версию веб-интерфейса

## Пример использования

### Сценарий: Настройка для спутника на 13°E

1. Расчетная задержка: 119.8 мс
2. В веб-интерфейсе:
   - Delay Compensation: 119.8
   - Enable: ✓
3. Сохранить конфигурацию
4. Проверить статус: "Active (119.800 ms)"
5. Мониторить стабильность в течение 5 минут
6. При необходимости скорректировать

## Дополнительная информация

Подробная документация: см. файл `SATELLITE_DELAY_COMPENSATION.md`