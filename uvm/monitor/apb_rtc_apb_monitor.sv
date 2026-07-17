class apb_rtc_apb_monitor extends uvm_monitor;
  `uvm_component_utils(apb_rtc_apb_monitor)

  virtual apb_rtc_apb_if vif;
  uvm_analysis_port #(apb_rtc_apb_item) ap;

  function new(string name = "apb_rtc_apb_monitor", uvm_component parent = null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_rtc_apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "virtual interface not set")
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_rtc_apb_item tr;
    forever begin
      @(posedge vif.pclk);
      if (vif.psel && vif.penable && vif.pready) begin
        tr        = apb_rtc_apb_item::type_id::create("tr", this);
        tr.write  = vif.pwrite;
        tr.addr   = vif.paddr;
        tr.data   = vif.pwdata;
        tr.rdata  = vif.prdata;
        tr.slverr = vif.pslverr;
        ap.write(tr);
      end
    end
  endtask
endclass
