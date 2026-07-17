module apb_rtc_tb_top;
  import uvm_pkg::*;
  import apb_rtc_uvm_pkg::*;

  logic pclk;
  logic presetn;

  apb_rtc_apb_if apb_vif(.pclk(pclk), .presetn(presetn));

  initial begin
    pclk = 1'b0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 1'b0;
    repeat (5) @(posedge pclk);
    presetn = 1'b1;
  end

  initial begin
    uvm_config_db#(virtual apb_rtc_apb_if)::set(null, "*", "vif", apb_vif);
    run_test();
  end

  apb_rtc_wrapper #(
    .PCLK_FREQ_HZ (100)
  ) u_dut (
    .i_apb_rtc_pclk    (pclk),
    .i_apb_rtc_presetn (presetn),
    .i_apb_rtc_paddr   (apb_vif.paddr),
    .i_apb_rtc_psel    (apb_vif.psel),
    .i_apb_rtc_penable (apb_vif.penable),
    .i_apb_rtc_pwrite  (apb_vif.pwrite),
    .i_apb_rtc_pwdata  (apb_vif.pwdata),
    .i_apb_rtc_pstrb   (apb_vif.pstrb),
    .o_apb_rtc_prdata  (apb_vif.prdata),
    .o_apb_rtc_pready  (apb_vif.pready),
    .o_apb_rtc_pslverr (apb_vif.pslverr),
    .o_apb_rtc_irq     (apb_vif.irq)
  );
endmodule
