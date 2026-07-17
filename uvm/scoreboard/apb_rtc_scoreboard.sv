class apb_rtc_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_rtc_scoreboard)

  uvm_analysis_imp #(apb_rtc_apb_item, apb_rtc_scoreboard) analysis_export;
  bit [31:0] mirror [bit [7:0]];

  function new(string name = "apb_rtc_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction

  function void write(apb_rtc_apb_item tr);
    if (tr.write) begin
      mirror[tr.addr] = tr.data;
    end
  endfunction
endclass
