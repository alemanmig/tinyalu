///Single Cicle
//Opetations: ADD, AND and XOR
//TinyALU
//UVM Salemi, verilog code
//
///////////////////////////////////////

module single_cycle (

input      [7:0]  A,
input      [7:0]  B,
input             clk,
input      [2:0]  op,
input             rst_n,
input             start,
output            done_aax,
output reg [15:0] result_aax
);

wire [7:0]  a_int, b_int;
wire [15:0] mul_int1, mul_int2;
reg        done_aax_int;

//Single Cycle ops
always @(posedge clk)
  begin
   //Synchronous Reset
   if(rst_n == 0)    //Reset Actions
      result_aax <= 16'b0000000000000000;
   else if(start == 1)
        case (op) 	 
          3'b001 : result_aax = {8'b00000000,A} + {8'b00000000,B};
			 3'b010 : result_aax = {8'b00000000,A} & {8'b00000000,B};
			 3'b011 : result_aax = {8'b00000000,A} ^ {8'b00000000,B};
			 //default: null;  // Check 
		endcase
  end	

always @(posedge clk, negedge rst_n) 
  begin
    if (!rst_n)
      done_aax_int <= 1'b0;
	else if (clk)
	   begin
         if ((start == 1'b1) && (op !== 3'b000)) 
            done_aax_int <= 1'b1;
	     else 
		      done_aax_int <= 1'b0;
	   end 
   end			
	
assign done_aax = done_aax_int;


endmodule