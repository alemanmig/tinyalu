// Tiny ALU for UVM implementation
//Reference - The UVM Primer Book
//start: 07/03/2023
//Code in verilog 
////////////////////////////////////

module tinyalu (

//Data inputs
input [7:0] a_i,
input [7:0] b_i,

//Control inputs
input       clk_i,
input [2:0] op_i,        //Operation Code
input       rst_n,  //Reset syncronus
input       start_i, 

//Outputs (contol and Result)
output            done_o,
output reg [15:0] result_o
);

//Internal Declarations
 wire done_aax;
 wire done_mult;
 wire [15:0] result_aax;
 wire [15:0] result_mult;
 reg start_single;
 reg start_mult;
 
 //Implicit buffer signal declarations
 reg done_internal;
 
 //component declarations 
 single_cycle uut1 (
		.A(a_i), 
		.B(b_i), 
		.clk(clk_i),
		.op(op_i),
		.reset_n(reset_n),
		.start(start_i),
		.done_aax(done_aax),
		.result_aax(result_aax)
	);
	
three_cycle uut2 (
      .A(a_i),
		.B(b_i),
		.reset_n(reset_n),
		.start(start_i),
		.done_mult(done_mult),
		.result_mult(result_mult)
	);
 
always @(op_i[2], start_i)    //start demux
  begin 
    case (op_i[2])
      1'b0    : begin start_single <= start_i; start_mult = 1'b0;  end
      1'b1    : begin start_single <= 1'b0; start_mult <= start_i; end
      //default :
    endcase
  end	

always @(result_aax or result_mult or op_i)  // result mux
  begin
    case (op_i[2]) 
	  1'b0    : result_o <= result_aax;
	  1'b1    : result_o <= result_mult;
	  default : result_o <= 16'bx; 
	 endcase 
  end
  
always @(done_aax or done_mult or op_i)
  begin
    case (op_i[2])
	   1'b0  : done_internal <= done_aax;
	   1'b1  : done_internal <= done_mult;
	   default : done_internal <= 1'bx;
	 endcase
  end	  

assign done_o = done_internal; 

endmodule