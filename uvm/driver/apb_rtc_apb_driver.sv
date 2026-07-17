class apb_rtc_apb_driver extends uvm_driver #(apb_rtc_apb_item);
  `uvm_component_utils(apb_rtc_apb_driver)

  virtual apb_rtc_apb_if vif;

  function new(string name = "apb_rtc_apb_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_rtc_apb_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "virtual interface not set")
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_rtc_apb_item tr;
    drive_idle();
    @(posedge vif.presetn);
    forever begin
      seq_item_port.get_next_item(tr);
      drive_transfer(tr);
      seq_item_port.item_done();
    end
  endtask

  task drive_idle();
    vif.paddr   <= '0;
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b0;
    vif.pwdata  <= '0;
    vif.pstrb   <= '1;
  endtask

  task drive_transfer(apb_rtc_apb_item tr);
    @(posedge vif.pclk);
    vif.paddr   <= tr.addr;
    vif.pwrite  <= tr.write;
    vif.pwdata  <= tr.data;
    vif.pstrb   <= '1;
    vif.psel    <= 1'b1;
    vif.penable <= 1'b0;

    @(posedge vif.pclk);
    vif.penable <= 1'b1;
    do begin
      @(posedge vif.pclk);
    end while (!vif.pready);

    tr.rdata  = vif.prdata;
    tr.slverr = vif.pslverr;
    drive_idle();
  endtask
endclass
