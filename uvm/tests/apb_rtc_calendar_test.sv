class apb_rtc_calendar_test extends apb_rtc_base_test;
  `uvm_component_utils(apb_rtc_calendar_test)

  function new(string name = "apb_rtc_calendar_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_rtc_calendar_seq seq;
    phase.raise_objection(this);
    seq = apb_rtc_calendar_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass
