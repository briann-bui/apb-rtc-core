package apb_rtc_pkg;
  localparam logic [7:0] APB_RTC_ADDR_CTRL       = 8'h00;
  localparam logic [7:0] APB_RTC_ADDR_STATUS     = 8'h04;
  localparam logic [7:0] APB_RTC_ADDR_PRESCALER  = 8'h08;
  localparam logic [7:0] APB_RTC_ADDR_TIME       = 8'h0C;
  localparam logic [7:0] APB_RTC_ADDR_DATE       = 8'h10;
  localparam logic [7:0] APB_RTC_ADDR_ALARM_TIME = 8'h14;
  localparam logic [7:0] APB_RTC_ADDR_ALARM_DATE = 8'h18;
  localparam logic [7:0] APB_RTC_ADDR_IRQ_EN     = 8'h1C;
  localparam logic [7:0] APB_RTC_ADDR_IRQ_STAT   = 8'h20;
  localparam logic [7:0] APB_RTC_ADDR_VERSION    = 8'h24;

  localparam int APB_RTC_CTRL_ENABLE_BIT          = 0;
  localparam int APB_RTC_CTRL_ALARM_ENABLE_BIT    = 1;
  localparam int APB_RTC_CTRL_ALARM_DATE_BIT      = 2;
  localparam int APB_RTC_IRQ_SECOND_BIT            = 0;
  localparam int APB_RTC_IRQ_ALARM_BIT             = 1;
endpackage
