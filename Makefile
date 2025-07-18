# =============================================================================
# Makefile for T2MI PPS Generator Project
# Target: Lattice LFE5U-25F-6BG256C
# =============================================================================

# Project settings
PROJECT_NAME = T2MI_PPS_Generator
TOP_MODULE = t2mi_pps_top
DEVICE = LFE5U-25F-6BG256C
PACKAGE = BG256C
SPEED_GRADE = -6

# Directories
SRC_DIR = src
CONSTRAINTS_DIR = constraints
SIM_DIR = sim
BUILD_DIR = build
IMPL_DIR = impl1

# Source files
VERILOG_SOURCES = $(SRC_DIR)/t2mi_pps_top.v \
                  $(SRC_DIR)/t2mi_packet_parser.v \
                  $(SRC_DIR)/timestamp_extractor.v \
                  $(SRC_DIR)/pps_generator.v \
                  $(SRC_DIR)/sync_modules.v

CONSTRAINT_FILES = $(CONSTRAINTS_DIR)/t2mi_pps.lpf

# Simulation files
TB_FILES = $(SIM_DIR)/t2mi_pps_tb.v

# Tools (adjust paths as needed)
DIAMOND_DIR = /usr/local/diamond
SYNPLIFY_DIR = $(DIAMOND_DIR)/synpbase
DIAMOND_BIN = $(DIAMOND_DIR)/bin/lin64/diamond_env

# Default target
all: bitstream

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Synthesis
synthesis: $(BUILD_DIR)
	@echo "Running synthesis..."
	cd $(BUILD_DIR) && \
	$(DIAMOND_BIN) -c "prj_project open ../$(PROJECT_NAME).ldf; \
	                   prj_run Synthesis -impl $(IMPL_DIR); \
	                   prj_project close"

# Place and Route
place_route: synthesis
	@echo "Running place and route..."
	cd $(BUILD_DIR) && \
	$(DIAMOND_BIN) -c "prj_project open ../$(PROJECT_NAME).ldf; \
	                   prj_run Translate -impl $(IMPL_DIR); \
	                   prj_run Map -impl $(IMPL_DIR); \
	                   prj_run PAR -impl $(IMPL_DIR); \
	                   prj_project close"

# Generate bitstream
bitstream: place_route
	@echo "Generating bitstream..."
	cd $(BUILD_DIR) && \
	$(DIAMOND_BIN) -c "prj_project open ../$(PROJECT_NAME).ldf; \
	                   prj_run Export -impl $(IMPL_DIR); \
	                   prj_project close"

# Simulation with ModelSim (if available)
simulate:
	@echo "Running simulation..."
	cd $(SIM_DIR) && \
	vlib work && \
	vlog +incdir+../$(SRC_DIR) ../$(SRC_DIR)/*.v t2mi_pps_tb.v && \
	vsim -c -do "run -all; quit" t2mi_pps_tb

# Simulation with Icarus Verilog (alternative)
sim_icarus:
	@echo "Running simulation with Icarus Verilog..."
	cd $(SIM_DIR) && \
	iverilog -I../$(SRC_DIR) -o t2mi_pps_sim ../$(SRC_DIR)/*.v t2mi_pps_tb.v && \
	vvp t2mi_pps_sim

# Run external PPS testbench
sim_ext_pps:
	@echo "Running external PPS processor simulation..."
	cd $(SIM_DIR) && \
	iverilog -I../$(SRC_DIR) -o tb_external_pps ../$(SRC_DIR)/external_pps_processor.v tb_external_pps.v && \
	vvp tb_external_pps

# Clean build files
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(IMPL_DIR)
	rm -f *.log *.rpt
	cd $(SIM_DIR) && rm -f *.vcd *.wlf work transcript t2mi_pps_sim

# Lint check (if verilator is available)
lint:
	@echo "Running lint check..."
	verilator --lint-only -Wall -I$(SRC_DIR) $(VERILOG_SOURCES)

# Generate documentation
docs:
	@echo "Generating documentation..."
	mkdir -p doc/html
	# Add documentation generation commands here

# Show project information
info:
	@echo "Project: $(PROJECT_NAME)"
	@echo "Top Module: $(TOP_MODULE)"
	@echo "Target Device: $(DEVICE)"
	@echo "Package: $(PACKAGE)"
	@echo "Speed Grade: $(SPEED_GRADE)"
	@echo ""
	@echo "Source Files:"
	@for file in $(VERILOG_SOURCES); do echo "  $$file"; done
	@echo ""
	@echo "Constraint Files:"
	@for file in $(CONSTRAINT_FILES); do echo "  $$file"; done

# Help
help:
	@echo "Available targets:"
	@echo "  all        - Build complete project (default)"
	@echo "  synthesis  - Run synthesis only"
	@echo "  place_route- Run place and route"
	@echo "  bitstream  - Generate final bitstream"
	@echo "  simulate   - Run simulation with ModelSim"
	@echo "  sim_icarus - Run simulation with Icarus Verilog"
	@echo "  sim_ext_pps- Run external PPS testbench"
	@echo "  lint       - Run lint check with Verilator"
	@echo "  clean      - Clean build files"
	@echo "  docs       - Generate documentation"
	@echo "  info       - Show project information"
	@echo "  help       - Show this help"

.PHONY: all synthesis place_route bitstream simulate sim_icarus sim_ext_pps clean lint docs info help

