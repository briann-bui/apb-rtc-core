class apb_rtc_all_test extends apb_rtc_base_test;
  `uvm_component_utils(apb_rtc_all_test)

  function new(string name = "apb_rtc_all_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_rtc_reg_smoke_seq reg_seq;
    apb_rtc_calendar_seq  calendar_seq;
    apb_rtc_alarm_seq     alarm_seq;
    apb_rtc_tick_irq_seq  tick_seq;

    phase.raise_objection(this);
    reg_seq      = apb_rtc_reg_smoke_seq::type_id::create("reg_seq");
    calendar_seq = apb_rtc_calendar_seq::type_id::create("calendar_seq");
    alarm_seq    = apb_rtc_alarm_seq::type_id::create("alarm_seq");
    tick_seq     = apb_rtc_tick_irq_seq::type_id::create("tick_seq");
    reg_seq.start(m_env.m_agent.m_sequencer);
    calendar_seq.start(m_env.m_agent.m_sequencer);
    alarm_seq.start(m_env.m_agent.m_sequencer);
    tick_seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass
