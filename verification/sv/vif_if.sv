`ifndef VIF_IF_SV
`define VIF_IF_SV

interface vif_if(
    input logic clk_i
); 

  timeunit      1ns;
  timeprecision 100ps;
  
  logic [7:0] a_i;
  logic [7:0] b_i;
  
  logic [2:0] op_i;
  logic rst_n;
  logic start_i;
  logic done_o;
  logic [15:0] result_o;



/*  clocking cb @(posedge clk_i);
    default input #1ns output #1ns;
    output rst_i;
    output up_i;
  endclocking*/

endinterface : vif_if

`endif // VIF_IF_SV