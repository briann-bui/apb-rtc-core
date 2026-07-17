module apb_rtc_core
#(
  parameter int PCLK_FREQ_HZ = 50_000_000
)
(
  input  logic        i_apb_rtc_clk,
  input  logic        i_apb_rtc_rst_n,

  input  logic        i_apb_rtc_enable,
  input  logic [31:0] i_apb_rtc_prescaler,
  input  logic        i_apb_rtc_time_load,
  input  logic [5:0]  i_apb_rtc_load_second,
  input  logic [5:0]  i_apb_rtc_load_minute,
  input  logic [4:0]  i_apb_rtc_load_hour,
  input  logic        i_apb_rtc_date_load,
  input  logic [4:0]  i_apb_rtc_load_day,
  input  logic [3:0]  i_apb_rtc_load_month,
  input  logic [11:0] i_apb_rtc_load_year,

  input  logic        i_apb_rtc_alarm_enable,
  input  logic        i_apb_rtc_alarm_date_enable,
  input  logic [5:0]  i_apb_rtc_alarm_second,
  input  logic [5:0]  i_apb_rtc_alarm_minute,
  input  logic [4:0]  i_apb_rtc_alarm_hour,
  input  logic [4:0]  i_apb_rtc_alarm_day,
  input  logic [3:0]  i_apb_rtc_alarm_month,
  input  logic [11:0] i_apb_rtc_alarm_year,

  output logic [5:0]  o_apb_rtc_second,
  output logic [5:0]  o_apb_rtc_minute,
  output logic [4:0]  o_apb_rtc_hour,
  output logic [4:0]  o_apb_rtc_day,
  output logic [3:0]  o_apb_rtc_month,
  output logic [11:0] o_apb_rtc_year,
  output logic        o_apb_rtc_second_tick,
  output logic        o_apb_rtc_alarm_match
);

  logic [31:0] r_prescale_cnt;
  logic [5:0]  r_second;
  logic [5:0]  r_minute;
  logic [4:0]  r_hour;
  logic [4:0]  r_day;
  logic [3:0]  r_month;
  logic [11:0] r_year;
  logic        r_second_tick;
  logic        r_alarm_equal_d;
  logic        w_second_tick;
  logic        w_alarm_time_equal;
  logic        w_alarm_date_equal;
  logic        w_alarm_equal;

  function automatic logic is_leap_year(input logic [11:0] year);
    int unsigned year_value;
    begin
      year_value = {20'd0, year};
      is_leap_year = ((year_value % 4) == 0) &&
                     (((year_value % 100) != 0) || ((year_value % 400) == 0));
    end
  endfunction

  function automatic logic [4:0] days_in_month(
    input logic [3:0] month,
    input logic [11:0] year
  );
    begin
      unique case (month)
        4'd1, 4'd3, 4'd5, 4'd7, 4'd8, 4'd10, 4'd12: days_in_month = 5'd31;
        4'd4, 4'd6, 4'd9, 4'd11:                      days_in_month = 5'd30;
        4'd2: days_in_month = is_leap_year(year) ? 5'd29 : 5'd28;
        default: days_in_month = 5'd31;
      endcase
    end
  endfunction

  assign w_second_tick = i_apb_rtc_enable &&
                         !i_apb_rtc_time_load &&
                         !i_apb_rtc_date_load &&
                         (r_prescale_cnt >= i_apb_rtc_prescaler);

  assign w_alarm_time_equal = (r_second == i_apb_rtc_alarm_second) &&
                              (r_minute == i_apb_rtc_alarm_minute) &&
                              (r_hour   == i_apb_rtc_alarm_hour);
  assign w_alarm_date_equal = (r_day   == i_apb_rtc_alarm_day) &&
                              (r_month == i_apb_rtc_alarm_month) &&
                              (r_year  == i_apb_rtc_alarm_year);
  assign w_alarm_equal = i_apb_rtc_alarm_enable &&
                         w_alarm_time_equal &&
                         (!i_apb_rtc_alarm_date_enable || w_alarm_date_equal);

  always_ff @(posedge i_apb_rtc_clk or negedge i_apb_rtc_rst_n) begin
    if (!i_apb_rtc_rst_n) begin
      r_prescale_cnt <= 32'd0;
      r_second_tick  <= 1'b0;
    end else begin
      r_second_tick <= w_second_tick;

      if (!i_apb_rtc_enable || i_apb_rtc_time_load || i_apb_rtc_date_load) begin
        r_prescale_cnt <= 32'd0;
      end else if (w_second_tick) begin
        r_prescale_cnt <= 32'd0;
      end else begin
        r_prescale_cnt <= r_prescale_cnt + 32'd1;
      end
    end
  end

  always_ff @(posedge i_apb_rtc_clk or negedge i_apb_rtc_rst_n) begin
    if (!i_apb_rtc_rst_n) begin
      r_second <= 6'd0;
      r_minute <= 6'd0;
      r_hour   <= 5'd0;
      r_day    <= 5'd1;
      r_month  <= 4'd1;
      r_year   <= 12'd2000;
    end else begin
      if (i_apb_rtc_time_load) begin
        r_second <= (i_apb_rtc_load_second <= 6'd59) ? i_apb_rtc_load_second : 6'd0;
        r_minute <= (i_apb_rtc_load_minute <= 6'd59) ? i_apb_rtc_load_minute : 6'd0;
        r_hour   <= (i_apb_rtc_load_hour <= 5'd23) ? i_apb_rtc_load_hour : 5'd0;
      end else if (w_second_tick) begin
        if (r_second == 6'd59) begin
          r_second <= 6'd0;
          if (r_minute == 6'd59) begin
            r_minute <= 6'd0;
            if (r_hour == 5'd23) begin
              r_hour <= 5'd0;
            end else begin
              r_hour <= r_hour + 5'd1;
            end
          end else begin
            r_minute <= r_minute + 6'd1;
          end
        end else begin
          r_second <= r_second + 6'd1;
        end
      end

      if (i_apb_rtc_date_load) begin
        r_year  <= i_apb_rtc_load_year;
        r_month <= ((i_apb_rtc_load_month >= 4'd1) &&
                    (i_apb_rtc_load_month <= 4'd12)) ? i_apb_rtc_load_month : 4'd1;
        r_day   <= ((i_apb_rtc_load_day >= 5'd1) &&
                    (i_apb_rtc_load_day <= days_in_month(i_apb_rtc_load_month,
                                                         i_apb_rtc_load_year))) ?
                   i_apb_rtc_load_day : 5'd1;
      end else if (w_second_tick &&
                   (r_second == 6'd59) &&
                   (r_minute == 6'd59) &&
                   (r_hour == 5'd23)) begin
        if (r_day == days_in_month(r_month, r_year)) begin
          r_day <= 5'd1;
          if (r_month == 4'd12) begin
            r_month <= 4'd1;
            r_year  <= r_year + 12'd1;
          end else begin
            r_month <= r_month + 4'd1;
          end
        end else begin
          r_day <= r_day + 5'd1;
        end
      end
    end
  end

  always_ff @(posedge i_apb_rtc_clk or negedge i_apb_rtc_rst_n) begin
    if (!i_apb_rtc_rst_n) begin
      r_alarm_equal_d <= 1'b0;
    end else begin
      r_alarm_equal_d <= w_alarm_equal;
    end
  end

  assign o_apb_rtc_second      = r_second;
  assign o_apb_rtc_minute      = r_minute;
  assign o_apb_rtc_hour        = r_hour;
  assign o_apb_rtc_day         = r_day;
  assign o_apb_rtc_month       = r_month;
  assign o_apb_rtc_year        = r_year;
  assign o_apb_rtc_second_tick = r_second_tick;
  assign o_apb_rtc_alarm_match = w_alarm_equal && !r_alarm_equal_d;

endmodule
