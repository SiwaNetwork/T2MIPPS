# =============================================================================
# Makefile for T2MI PPS Generator Project
# Makefile для проекта генератора PPS из T2MI
# Target: Lattice LFE5U-25F-6BG256C
# Целевая платформа: Lattice LFE5U-25F-6BG256C
# =============================================================================

# Project settings / Настройки проекта
PROJECT_NAME = T2MI_PPS_Generator
TOP_MODULE = t2mi_pps_top_v2
DEVICE = LFE5U-25F-6BG256C
PACKAGE = BG256C
SPEED_GRADE = -6

# Directories / Директории
SRC_DIR = src
CONSTRAINTS_DIR = constraints
SIM_DIR = sim
BUILD_DIR = build
IMPL_DIR = impl1

# Source files / Исходные файлы
# Обновленный список файлов - используются только актуальные модули
VERILOG_SOURCES = $(SRC_DIR)/t2mi_pps_top_v2.v \
                  $(SRC_DIR)/t2mi_packet_parser.v \
                  $(SRC_DIR)/timestamp_extractor.v \
                  $(SRC_DIR)/pps_generator.v \
                  $(SRC_DIR)/sync_modules.v \
                  $(SRC_DIR)/i2c_master.v \
                  $(SRC_DIR)/sit5503_controller.v \
                  $(SRC_DIR)/enhanced_pps_generator.v

# Constraint files / Файлы ограничений
CONSTRAINT_FILES = $(CONSTRAINTS_DIR)/t2mi_pps.lpf

# Simulation files / Файлы симуляции
TB_FILES = $(SIM_DIR)/t2mi_pps_tb.v \
           $(SIM_DIR)/pps_generator_tb.v \
           $(SIM_DIR)/t2mi_packet_parser_tb.v

# Tools (adjust paths as needed) / Инструменты (настройте пути при необходимости)
DIAMOND_DIR = /usr/local/diamond
SYNPLIFY_DIR = $(DIAMOND_DIR)/synpbase
DIAMOND_BIN = $(DIAMOND_DIR)/bin/lin64/diamond_env

# Default target / Цель по умолчанию
all: bitstream

# Create build directory / Создание директории сборки
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Synthesis / Синтез
synthesis: $(BUILD_DIR)
	@echo "Running synthesis... / Запуск синтеза..."
	cd $(BUILD_DIR) && \
	$(DIAMOND_BIN) -c "prj_project open ../$(PROJECT_NAME).ldf; \
	                   prj_run Synthesis -impl $(IMPL_DIR); \
	                   prj_project close"

# Place and Route / Размещение и трассировка
place_route: synthesis
	@echo "Running place and route... / Запуск размещения и трассировки..."
	cd $(BUILD_DIR) && \
	$(DIAMOND_BIN) -c "prj_project open ../$(PROJECT_NAME).ldf; \
	                   prj_run Translate -impl $(IMPL_DIR); \
	                   prj_run Map -impl $(IMPL_DIR); \
	                   prj_run PAR -impl $(IMPL_DIR); \
	                   prj_project close"

# Generate bitstream / Генерация битового потока
bitstream: place_route
	@echo "Generating bitstream... / Генерация битового потока..."
	cd $(BUILD_DIR) && \
	$(DIAMOND_BIN) -c "prj_project open ../$(PROJECT_NAME).ldf; \
	                   prj_run Export -impl $(IMPL_DIR); \
	                   prj_project close"

# Simulation with ModelSim (if available) / Симуляция с ModelSim (если доступен)
simulate:
	@echo "Running simulation... / Запуск симуляции..."
	cd $(SIM_DIR) && \
	vlib work && \
	vlog +incdir+../$(SRC_DIR) $(VERILOG_SOURCES) $(TB_FILES) && \
	vsim -c -do "run -all; quit" t2mi_pps_tb

# Simulation with Icarus Verilog (alternative) / Симуляция с Icarus Verilog (альтернатива)
sim_icarus:
	@echo "Running simulation with Icarus Verilog... / Запуск симуляции с Icarus Verilog..."
	cd $(SIM_DIR) && \
	iverilog -I../$(SRC_DIR) -o t2mi_pps_sim $(VERILOG_SOURCES) t2mi_pps_tb.v && \
	vvp t2mi_pps_sim

# Run PPS generator testbench / Запуск тестбенча генератора PPS
sim_pps:
	@echo "Running PPS generator simulation... / Запуск симуляции генератора PPS..."
	cd $(SIM_DIR) && \
	iverilog -I../$(SRC_DIR) -o pps_generator_sim ../$(SRC_DIR)/pps_generator.v pps_generator_tb.v && \
	vvp pps_generator_sim

# Run packet parser testbench / Запуск тестбенча парсера пакетов
sim_parser:
	@echo "Running packet parser simulation... / Запуск симуляции парсера пакетов..."
	cd $(SIM_DIR) && \
	iverilog -I../$(SRC_DIR) -o t2mi_packet_parser_sim ../$(SRC_DIR)/t2mi_packet_parser.v t2mi_packet_parser_tb.v && \
	vvp t2mi_packet_parser_sim

# Clean build files / Очистка файлов сборки
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(IMPL_DIR)
	rm -f *.log *.rpt
	cd $(SIM_DIR) && rm -f *.vcd *.wlf work transcript *_sim

# Lint check (if verilator is available) / Проверка линтером (если доступен verilator)
lint:
	@echo "Running lint check... / Запуск проверки линтером..."
	verilator --lint-only -Wall -I$(SRC_DIR) $(VERILOG_SOURCES)

# Generate documentation / Генерация документации
docs:
	@echo "Generating documentation... / Генерация документации..."
	mkdir -p doc/html
	# Add documentation generation commands here / Добавьте команды генерации документации здесь

# Show project information / Показать информацию о проекте
info:
	@echo "Project / Проект: $(PROJECT_NAME)"
	@echo "Top Module / Верхний модуль: $(TOP_MODULE)"
	@echo "Target Device / Целевое устройство: $(DEVICE)"
	@echo "Package / Корпус: $(PACKAGE)"
	@echo "Speed Grade / Класс скорости: $(SPEED_GRADE)"
	@echo ""
	@echo "Source Files / Исходные файлы:"
	@for file in $(VERILOG_SOURCES); do echo "  $$file"; done
	@echo ""
	@echo "Constraint Files / Файлы ограничений:"
	@for file in $(CONSTRAINT_FILES); do echo "  $$file"; done

# Help / Помощь
help:
	@echo "Available targets / Доступные цели:"
	@echo "  all        - Build complete project (default) / Полная сборка проекта (по умолчанию)"
	@echo "  synthesis  - Run synthesis only / Только синтез"
	@echo "  place_route- Run place and route / Размещение и трассировка"
	@echo "  bitstream  - Generate final bitstream / Генерация битового потока"
	@echo "  simulate   - Run simulation with ModelSim / Симуляция с ModelSim"
	@echo "  sim_icarus - Run simulation with Icarus Verilog / Симуляция с Icarus Verilog"
	@echo "  sim_pps    - Run PPS generator testbench / Тестбенч генератора PPS"
	@echo "  sim_parser - Run packet parser testbench / Тестбенч парсера пакетов"
	@echo "  lint       - Run lint check with Verilator / Проверка линтером Verilator"
	@echo "  clean      - Clean build files / Очистка файлов сборки"
	@echo "  docs       - Generate documentation / Генерация документации"
	@echo "  info       - Show project information / Информация о проекте"
	@echo "  help       - Show this help / Показать эту справку"

.PHONY: all synthesis place_route bitstream simulate sim_icarus sim_pps sim_parser clean lint docs info help

