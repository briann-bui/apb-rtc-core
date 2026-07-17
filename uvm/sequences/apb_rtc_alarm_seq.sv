class apb_rtc_alarm_seq extends apb_rtc_base_seq;
  `uvm_object_utils(apb_rtc_alarm_seq)

  function new(string name = "apb_rtc_alarm_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] data;

    apb_write(8'h00, 32'd0);
    apb_write(8'h08, 32'd1);
    apb_write(8'h10, pack_date(12'd2026, 4'd7, 5'd17));
    apb_write(8'h0C, pack_time(5'd0, 6'd0, 6'd0));
    apb_write(8'h18, pack_date(12'd2026, 4'd7, 5'd17));
    apb_write(8'h14, pack_time(5'd0, 6'd0, 6'd3));
    apb_write(8'h1C, 32'h0000_0002);
    apb_write(8'h00, 32'h0000_0007);
    apb_read(8'h04, data);
    apb_read(8'h20, data);
    if (data[1] !== 1'b1) begin
      apb_read(8'h20, data);
    end
    if (data[1] !== 1'b1) `uvm_error(get_type_name(), "Alarm IRQ status was not set")

    apb_write(8'h00, 32'd0);
    apb_write(8'h20, 32'h0000_0003);
    apb_read(8'h20, data);
    if (data[1:0] !== 2'b00) `uvm_error(get_type_name(), "IRQ W1C mismatch")
  endtask
endclass
