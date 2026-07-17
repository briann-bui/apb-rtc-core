class apb_rtc_tick_irq_seq extends apb_rtc_base_seq;
  `uvm_object_utils(apb_rtc_tick_irq_seq)

  function new(string name = "apb_rtc_tick_irq_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] data;

    apb_write(8'h08, 32'd0);
    apb_write(8'h1C, 32'h0000_0001);
    apb_write(8'h00, 32'h0000_0001);
    apb_read(8'h20, data);
    if (data[0] !== 1'b1) `uvm_error(get_type_name(), "Second-tick IRQ status was not set")

    apb_write(8'h00, 32'd0);
    apb_write(8'h20, 32'h0000_0001);
    apb_read(8'h20, data);
    if (data[0] !== 1'b0) `uvm_error(get_type_name(), "Second-tick IRQ W1C mismatch")
  endtask
endclass
