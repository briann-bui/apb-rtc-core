class apb_rtc_reg_smoke_seq extends apb_rtc_base_seq;
  `uvm_object_utils(apb_rtc_reg_smoke_seq)

  function new(string name = "apb_rtc_reg_smoke_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] data;

    apb_read(8'h00, data);
    if (data !== 32'd0) `uvm_error(get_type_name(), "CTRL reset value mismatch")

    apb_read(8'h0C, data);
    if (data !== pack_time(5'd0, 6'd0, 6'd0))
      `uvm_error(get_type_name(), "TIME reset value mismatch")

    apb_read(8'h10, data);
    if ((data[27:16] !== 12'd2000) || (data[15:12] !== 4'd1) ||
        (data[8:4] !== 5'd1))
      `uvm_error(get_type_name(), "DATE reset value mismatch")

    apb_write(8'h08, 32'd9);
    apb_read(8'h08, data);
    if (data !== 32'd9) `uvm_error(get_type_name(), "PRESCALER readback mismatch")

    apb_write(8'h14, pack_time(5'd6, 6'd30, 6'd15));
    apb_read(8'h14, data);
    if (data !== pack_time(5'd6, 6'd30, 6'd15))
      `uvm_error(get_type_name(), "ALARM_TIME readback mismatch")

    apb_read(8'h24, data);
    if (data !== `APB_RTC_VERSION) `uvm_error(get_type_name(), "VERSION mismatch")
  endtask
endclass
