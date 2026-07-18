VCS ?= vcs
SPYGLASS ?= spyglass

FILELIST ?= filelist.f
TOP_MODULE ?= apb_rtc_wrapper
UVM_TOP ?= apb_rtc_tb_top
UVM_TEST ?= apb_rtc_all_test

REPORT_DIR ?= reports
VCS_DIR := $(REPORT_DIR)/vcs
SPYGLASS_DIR := $(REPORT_DIR)/spyglass

LINT_PRJ ?= lint/lint.prj
CDC_PRJ ?= cdc/cdc.prj
RDC_PRJ ?= rdc/rdc.prj

VCS_FLAGS ?= -full64 -sverilog -nc -timescale=1ns/1ps
VCS_UVM_FLAGS ?= -ntb_opts uvm-1.2

.PHONY: all compile compile-rtl lint cdc rdc check run clean

all: check

check: compile lint cdc rdc

compile:
	@mkdir -p $(VCS_DIR)/compile/csrc
	$(VCS) $(VCS_FLAGS) $(VCS_UVM_FLAGS) -f $(FILELIST) \
		-top $(UVM_TOP) \
		-Mdir=$(VCS_DIR)/compile/csrc \
		-o $(VCS_DIR)/compile/simv \
		-l $(VCS_DIR)/compile.log
	@{ \
		echo "APB RTC VCS compile summary"; \
		echo "Status: PASS"; \
		echo "Top: $(UVM_TOP)"; \
		echo "File list: $(FILELIST)"; \
		echo "Full log: $(VCS_DIR)/compile.log"; \
	} > $(REPORT_DIR)/compile_summary.rpt

compile-rtl:
	@mkdir -p $(VCS_DIR)/rtl/csrc
	$(VCS) $(VCS_FLAGS) +lint=all,noVCDE +incdir+inc \
		rtl/apb_rtc_pkg.sv \
		rtl/apb_rtc_core.sv \
		rtl/apb_rtc_apb_interface.sv \
		rtl/apb_rtc_wrapper.sv \
		-top $(TOP_MODULE) \
		-Mdir=$(VCS_DIR)/rtl/csrc \
		-o $(VCS_DIR)/rtl/simv \
		-l $(VCS_DIR)/rtl_compile.log
	@{ \
		echo "APB RTC VCS RTL compile summary"; \
		echo "Status: PASS"; \
		echo "Top: $(TOP_MODULE)"; \
		echo "Full log: $(VCS_DIR)/rtl_compile.log"; \
	} > $(REPORT_DIR)/rtl_compile_summary.rpt

lint:
	@mkdir -p $(SPYGLASS_DIR)/lint
	@cp $(LINT_PRJ) $(SPYGLASS_DIR)/lint/lint.prj
	$(SPYGLASS) -batch -project $(SPYGLASS_DIR)/lint/lint.prj \
		-goals "lint/lint_rtl" \
		> $(REPORT_DIR)/lint.log 2>&1
	@report=$$(find $(SPYGLASS_DIR)/lint -path '*/lint/lint_rtl/spyglass_reports/moresimple.rpt' -print -quit); \
		test -n "$$report"; \
		cp "$$report" $(REPORT_DIR)/lint_summary.rpt
	@echo "Lint summary: $(REPORT_DIR)/lint_summary.rpt"

cdc:
	@mkdir -p $(SPYGLASS_DIR)/cdc
	@cp $(CDC_PRJ) $(SPYGLASS_DIR)/cdc/cdc.prj
	$(SPYGLASS) -batch -project $(SPYGLASS_DIR)/cdc/cdc.prj \
		-goals "cdc/cdc_setup_check,cdc/cdc_verify" \
		> $(REPORT_DIR)/cdc.log 2>&1
	@report=$$(find $(SPYGLASS_DIR)/cdc -path '*/cdc/cdc_verify/spyglass_reports/moresimple.rpt' -print -quit); \
		test -n "$$report"; \
		cp "$$report" $(REPORT_DIR)/cdc_summary.rpt
	@echo "CDC summary: $(REPORT_DIR)/cdc_summary.rpt"

rdc:
	@mkdir -p $(SPYGLASS_DIR)/rdc
	@cp $(RDC_PRJ) $(SPYGLASS_DIR)/rdc/rdc.prj
	$(SPYGLASS) -batch -project $(SPYGLASS_DIR)/rdc/rdc.prj \
		-goals "rdc/rdc_verify_struct" \
		> $(REPORT_DIR)/rdc.log 2>&1
	@report=$$(find $(SPYGLASS_DIR)/rdc -path '*/rdc/rdc_verify_struct/spyglass_reports/moresimple.rpt' -print -quit); \
		test -n "$$report"; \
		cp "$$report" $(REPORT_DIR)/rdc_summary.rpt
	@echo "RDC summary: $(REPORT_DIR)/rdc_summary.rpt"

run: compile
	$(VCS_DIR)/compile/simv +UVM_TESTNAME=$(UVM_TEST) \
		-l $(REPORT_DIR)/run.log
	@grep -q 'UVM_ERROR :    0' $(REPORT_DIR)/run.log
	@grep -q 'UVM_FATAL :    0' $(REPORT_DIR)/run.log

clean:
	# Keep top-level logs and *_summary.rpt files as the permanent check reports.
	rm -rf $(VCS_DIR) $(SPYGLASS_DIR)
	rm -rf csrc simv simv.daidir DVEfiles AN.DB novas.conf novas.rc verdiLog
	rm -rf lint/lint cdc/cdc rdc/rdc
	rm -f ucli.key vc_hdrs.h tr_db.log spyglass.log transcript
	rm -f *.vpd *.vcd *.fsdb *.wlf *.vstf *.ucdb *.log
	@echo "Removed tool work files; kept reports/*.log and reports/*_summary.rpt."
