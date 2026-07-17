class apb_rtc_base_test extends uvm_test;
  `uvm_component_utils(apb_rtc_base_test)

  apb_rtc_env m_env;

  function new(string name = "apb_rtc_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = apb_rtc_env::type_id::create("m_env", this);
  endfunction
endclass
