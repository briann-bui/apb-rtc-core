class apb_rtc_calendar_seq extends apb_rtc_base_seq;
  `uvm_object_utils(apb_rtc_calendar_seq)

  function new(string name = "apb_rtc_calendar_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] data;

    apb_write(8'h00, 32'd0);
    apb_write(8'h08, 32'd0);
    apb_write(8'h10, pack_date(12'd2024, 4'd2, 5'd28));
    apb_write(8'h0C, pack_time(5'd23, 6'd59, 6'd59));
    apb_write(8'h00, 32'd1);
    apb_read(8'h10, data);
    if ((data[27:16] !== 12'd2024) || (data[15:12] !== 4'd2) ||
        (data[8:4] !== 5'd29))
      `uvm_error(get_type_name(), "Leap-day rollover mismatch")

    apb_write(8'h00, 32'd0);
    apb_write(8'h10, pack_date(12'd2023, 4'd2, 5'd28));
    apb_write(8'h0C, pack_time(5'd23, 6'd59, 6'd59));
    apb_write(8'h00, 32'd1);
    apb_read(8'h10, data);
    if ((data[27:16] !== 12'd2023) || (data[15:12] !== 4'd3) ||
        (data[8:4] !== 5'd1))
      `uvm_error(get_type_name(), "Non-leap February rollover mismatch")

    apb_write(8'h00, 32'd0);
  endtask
endclass
