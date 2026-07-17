package apb_rtc_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "apb_rtc_defines.svh"

  `include "apb_rtc_apb_item.sv"
  `include "apb_rtc_apb_sequencer.sv"
  `include "apb_rtc_apb_driver.sv"
  `include "apb_rtc_apb_monitor.sv"
  `include "apb_rtc_scoreboard.sv"
  `include "apb_rtc_agent.sv"
  `include "apb_rtc_env.sv"

  `include "apb_rtc_base_seq.sv"
  `include "apb_rtc_reg_smoke_seq.sv"
  `include "apb_rtc_calendar_seq.sv"
  `include "apb_rtc_alarm_seq.sv"
  `include "apb_rtc_tick_irq_seq.sv"

  `include "apb_rtc_base_test.sv"
  `include "apb_rtc_reg_test.sv"
  `include "apb_rtc_calendar_test.sv"
  `include "apb_rtc_alarm_test.sv"
  `include "apb_rtc_tick_irq_test.sv"
  `include "apb_rtc_all_test.sv"
endpackage
