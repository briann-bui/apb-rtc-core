class apb_rtc_base_seq extends uvm_sequence #(apb_rtc_apb_item);
  `uvm_object_utils(apb_rtc_base_seq)

  function new(string name = "apb_rtc_base_seq");
    super.new(name);
  endfunction

  function automatic bit [31:0] pack_time(
    input bit [4:0] hour,
    input bit [5:0] minute,
    input bit [5:0] second
  );
    pack_time = {11'd0, hour, 2'd0, minute, 2'd0, second};
  endfunction

  function automatic bit [31:0] pack_date(
    input bit [11:0] year,
    input bit [3:0] month,
    input bit [4:0] day
  );
    pack_date = {4'd0, year, month, 3'd0, day, 4'd0};
  endfunction

  task apb_write(bit [7:0] addr, bit [31:0] data);
    apb_rtc_apb_item tr;
    tr = apb_rtc_apb_item::type_id::create("wr");
    start_item(tr);
    tr.write = 1'b1;
    tr.addr  = addr;
    tr.data  = data;
    finish_item(tr);
  endtask

  task apb_read(bit [7:0] addr, output bit [31:0] data);
    apb_rtc_apb_item tr;
    tr = apb_rtc_apb_item::type_id::create("rd");
    start_item(tr);
    tr.write = 1'b0;
    tr.addr  = addr;
    tr.data  = 32'd0;
    finish_item(tr);
    data = tr.rdata;
  endtask
endclass
