module sva (
	input logic [7:0]  A,
	input logic [7:0]  B,
	input logic        clk,
	input logic [2:0]  op,        //Operation Code
	input logic        reset_n,  //Reset syncronus
	input logic        star,
	input logic        done,
	input logic [15:0] result
);
     
// (1) Behavior of the dout when rst asserted
// dout is zero for all clock ticks during rst
  RESULT_RST: assert property (
    @(negedge reset_n) 
     (!reset_n) |-> (result == '0)
  )else $error("[FAIL] RESULT_RST in t = %t", $time);


endmodule
