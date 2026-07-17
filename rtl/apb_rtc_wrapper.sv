module apb_rtc_wrapper
#(
  parameter int C_APB_DATA_WIDTH = 32,
  parameter int C_APB_ADDR_WIDTH = 8,
  parameter int PCLK_FREQ_HZ     = 50_000_000
)
(
  input  logic                              i_apb_rtc_pclk,
  input  logic                              i_apb_rtc_presetn,
  input  logic [C_APB_ADDR_WIDTH-1:0]       i_apb_rtc_paddr,
  input  logic                              i_apb_rtc_psel,
  input  logic                              i_apb_rtc_penable,
  input  logic                              i_apb_rtc_pwrite,
  input  logic [C_APB_DATA_WIDTH-1:0]       i_apb_rtc_pwdata,
  input  logic [(C_APB_DATA_WIDTH/8)-1:0]   i_apb_rtc_pstrb,
  output logic [C_APB_DATA_WIDTH-1:0]       o_apb_rtc_prdata,
  output logic                              o_apb_rtc_pready,
  output logic                              o_apb_rtc_pslverr,
  output logic                              o_apb_rtc_irq
);

  apb_rtc_apb_interface #(
    .C_APB_DATA_WIDTH (C_APB_DATA_WIDTH),
    .C_APB_ADDR_WIDTH (C_APB_ADDR_WIDTH),
    .PCLK_FREQ_HZ     (PCLK_FREQ_HZ)
  ) u_apb_rtc_apb (
    .i_apb_rtc_pclk    (i_apb_rtc_pclk),
    .i_apb_rtc_presetn (i_apb_rtc_presetn),
    .i_apb_rtc_paddr   (i_apb_rtc_paddr),
    .i_apb_rtc_psel    (i_apb_rtc_psel),
    .i_apb_rtc_penable (i_apb_rtc_penable),
    .i_apb_rtc_pwrite  (i_apb_rtc_pwrite),
    .i_apb_rtc_pwdata  (i_apb_rtc_pwdata),
    .i_apb_rtc_pstrb   (i_apb_rtc_pstrb),
    .o_apb_rtc_prdata  (o_apb_rtc_prdata),
    .o_apb_rtc_pready  (o_apb_rtc_pready),
    .o_apb_rtc_pslverr (o_apb_rtc_pslverr),
    .o_apb_rtc_irq     (o_apb_rtc_irq)
  );

endmodule
