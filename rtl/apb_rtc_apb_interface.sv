`include "apb_rtc_defines.svh"

module apb_rtc_apb_interface
  import apb_rtc_pkg::*;
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

  localparam logic [31:0] RESET_PRESCALER = PCLK_FREQ_HZ - 1;

  logic [31:0] r_ctrl;
  logic [31:0] r_prescaler;
  logic [31:0] r_alarm_time;
  logic [31:0] r_alarm_date;
  logic [31:0] r_irq_en;
  logic [31:0] r_irq_stat;
  logic [31:0] r_prdata;
  logic        w_apb_wr_en;
  logic        w_apb_rd_en;
  logic        w_time_load;
  logic        w_date_load;
  logic [5:0]  w_second;
  logic [5:0]  w_minute;
  logic [4:0]  w_hour;
  logic [4:0]  w_day;
  logic [3:0]  w_month;
  logic [11:0] w_year;
  logic        w_second_tick;
  logic        w_alarm_match;

  assign o_apb_rtc_pready  = 1'b1;
  assign o_apb_rtc_pslverr = 1'b0;
  assign w_apb_wr_en = i_apb_rtc_psel && i_apb_rtc_penable && i_apb_rtc_pwrite;
  assign w_apb_rd_en = i_apb_rtc_psel && !i_apb_rtc_pwrite;
  assign w_time_load = w_apb_wr_en && (i_apb_rtc_paddr == APB_RTC_ADDR_TIME);
  assign w_date_load = w_apb_wr_en && (i_apb_rtc_paddr == APB_RTC_ADDR_DATE);

  always_ff @(posedge i_apb_rtc_pclk or negedge i_apb_rtc_presetn) begin
    if (!i_apb_rtc_presetn) begin
      r_ctrl       <= 32'd0;
      r_prescaler  <= RESET_PRESCALER;
      r_alarm_time <= 32'd0;
      r_alarm_date <= {4'd0, 12'd2000, 4'd1, 3'd0, 5'd1, 4'd0};
      r_irq_en     <= 32'd0;
      r_irq_stat   <= 32'd0;
    end else begin
      if (w_apb_wr_en) begin
        unique case (i_apb_rtc_paddr)
          APB_RTC_ADDR_CTRL       : r_ctrl       <= i_apb_rtc_pwdata;
          APB_RTC_ADDR_PRESCALER  : r_prescaler  <= i_apb_rtc_pwdata;
          APB_RTC_ADDR_ALARM_TIME : r_alarm_time <= i_apb_rtc_pwdata;
          APB_RTC_ADDR_ALARM_DATE : r_alarm_date <= i_apb_rtc_pwdata;
          APB_RTC_ADDR_IRQ_EN     : r_irq_en     <= i_apb_rtc_pwdata;
          APB_RTC_ADDR_IRQ_STAT   : r_irq_stat   <= r_irq_stat & ~i_apb_rtc_pwdata;
          default                 : ;
        endcase
      end

      if (w_second_tick) begin
        r_irq_stat[APB_RTC_IRQ_SECOND_BIT] <= 1'b1;
      end

      if (w_alarm_match) begin
        r_irq_stat[APB_RTC_IRQ_ALARM_BIT] <= 1'b1;
      end
    end
  end

  always_comb begin
    r_prdata = 32'd0;
    unique case (i_apb_rtc_paddr)
      APB_RTC_ADDR_CTRL       : r_prdata = r_ctrl;
      APB_RTC_ADDR_STATUS     : r_prdata = {29'd0, r_irq_stat[1], r_irq_stat[0], r_ctrl[0]};
      APB_RTC_ADDR_PRESCALER  : r_prdata = r_prescaler;
      APB_RTC_ADDR_TIME       : r_prdata = {11'd0, w_hour, 2'd0, w_minute, 2'd0, w_second};
      APB_RTC_ADDR_DATE       : r_prdata = {4'd0, w_year, w_month, 3'd0, w_day, 4'd0};
      APB_RTC_ADDR_ALARM_TIME : r_prdata = r_alarm_time;
      APB_RTC_ADDR_ALARM_DATE : r_prdata = r_alarm_date;
      APB_RTC_ADDR_IRQ_EN     : r_prdata = r_irq_en;
      APB_RTC_ADDR_IRQ_STAT   : r_prdata = r_irq_stat;
      APB_RTC_ADDR_VERSION    : r_prdata = `APB_RTC_VERSION;
      default                 : r_prdata = 32'd0;
    endcase
  end

  assign o_apb_rtc_prdata = w_apb_rd_en ? r_prdata : 32'd0;
  assign o_apb_rtc_irq    = |(r_irq_stat & r_irq_en);

  apb_rtc_core #(
    .PCLK_FREQ_HZ (PCLK_FREQ_HZ)
  ) u_apb_rtc_core (
    .i_apb_rtc_clk               (i_apb_rtc_pclk),
    .i_apb_rtc_rst_n             (i_apb_rtc_presetn),
    .i_apb_rtc_enable            (r_ctrl[APB_RTC_CTRL_ENABLE_BIT]),
    .i_apb_rtc_prescaler         (r_prescaler),
    .i_apb_rtc_time_load         (w_time_load),
    .i_apb_rtc_load_second       (i_apb_rtc_pwdata[5:0]),
    .i_apb_rtc_load_minute       (i_apb_rtc_pwdata[13:8]),
    .i_apb_rtc_load_hour         (i_apb_rtc_pwdata[20:16]),
    .i_apb_rtc_date_load         (w_date_load),
    .i_apb_rtc_load_day          (i_apb_rtc_pwdata[8:4]),
    .i_apb_rtc_load_month        (i_apb_rtc_pwdata[15:12]),
    .i_apb_rtc_load_year         (i_apb_rtc_pwdata[27:16]),
    .i_apb_rtc_alarm_enable      (r_ctrl[APB_RTC_CTRL_ALARM_ENABLE_BIT]),
    .i_apb_rtc_alarm_date_enable (r_ctrl[APB_RTC_CTRL_ALARM_DATE_BIT]),
    .i_apb_rtc_alarm_second      (r_alarm_time[5:0]),
    .i_apb_rtc_alarm_minute      (r_alarm_time[13:8]),
    .i_apb_rtc_alarm_hour        (r_alarm_time[20:16]),
    .i_apb_rtc_alarm_day         (r_alarm_date[8:4]),
    .i_apb_rtc_alarm_month       (r_alarm_date[15:12]),
    .i_apb_rtc_alarm_year        (r_alarm_date[27:16]),
    .o_apb_rtc_second            (w_second),
    .o_apb_rtc_minute            (w_minute),
    .o_apb_rtc_hour              (w_hour),
    .o_apb_rtc_day               (w_day),
    .o_apb_rtc_month             (w_month),
    .o_apb_rtc_year              (w_year),
    .o_apb_rtc_second_tick       (w_second_tick),
    .o_apb_rtc_alarm_match       (w_alarm_match)
  );

endmodule
