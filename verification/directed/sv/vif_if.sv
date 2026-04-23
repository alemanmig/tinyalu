`ifndef VIF_IF_SV
`define VIF_IF_SV
import one_pkg::*;

interface vif_if(
    input logic clk_i
); 

  timeunit      1ns;
  timeprecision 100ps;
  
  // tiny alu 
  logic [7:0]   A, B;
  logic         rst_ni;
  logic [2:0]   op_i;
  logic         start;
  logic         done;
  logic [15:0]  result;
  operation_t   op_set;

endinterface : vif_if

`endif // VIF_IF_SV
