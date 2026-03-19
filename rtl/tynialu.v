// Tiny ALU for UVM implementation
//Reference - The UVM Primer Book
//start: 07/03/2023
//Code in verilog 
////////////////////////////////////

module tynialu (

//Data inputs
input [7:0] A,
input [7:0] B,

//Control inputs
input       clk,
input [2:0] op,        //Operation Code
input       reset_n,  //Reset syncronus
input       star, 

//Outputs (contol and Result)
output            done,
output reg [15:0] result
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
		.A(A), 
		.B(B), 
		.clk(clk),
		.op(op),
		.reset_n(reset_n),
		.start(start),
		.done_aax(done_aax),
		.result_aax(result_aax)
	);
	
three_cycle uut2 (
      .A(A),
		.B(B),
		.reset_n(reset_n),
		.start(start),
		.done_mult(done_mult),
		.result_mult(result_mult)
	);
 
always @(op[2], start)    //start demux
  begin 
    case (op[2])
	   1'b0    : begin start_single <= start; start_mult = 1'b0;  end
      1'b1    : begin start_single <= 1'b0; start_mult <= start; end
      //default :
    endcase
  end	

always @(result_aax or result_mult or op)  // result mux
  begin
    case (op[2]) 
	  1'b0    : result <= result_aax;
	  1'b1    : result <= result_mult;
	  default : result <= 16'bx; 
	 endcase 
  end
  
always @(done_aax or done_mult or op)
  begin
    case (op[2])
	   1'b0  : done_internal <= done_aax;
	   1'b1  : done_internal <= done_mult;
	   default : done_internal <= 1'bx;
	 endcase
  end	  

assign done = done_internal; 

endmodule