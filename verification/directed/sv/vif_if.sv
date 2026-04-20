`ifndef VIF_IF_SV
`define VIF_IF_SV

interface vif_if(
    input logic clk
); 

  timeunit      1ns;
  timeprecision 100ps;
  
  
  logic [2:0]  op;        //Operation Code
  logic        reset_n;  //Reset syncronus
  logic        start;
  logic [7:0]  A;
  logic [7:0]  B;
  logic        done;
  logic [15:0] result;

//  clocking cb @(posedge clk);
//    default input #1ns output #1ns;
//    output rst_i;
//    output up_i;
//  endclocking

endinterface : vif_if

`endif // VIF_IF_SV
