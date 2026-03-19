module three_cycle (

input      [7:0]  A,
input       [7:0] B,
input             clk,
input             reset_n,
input             start,

output            done_mult,
output reg [15:0] result_mult
);

//Declarations

reg [7:0]  a_int, b_int;
reg [15:0] mult1, mult2;
reg  done3, done2, done1, done_mult_int;

always @(posedge clk, negedge reset_n)
  begin
    if(reset_n==0)
	   begin 
	     done3 <= 0;
		  done2 <= 0;
		  done1 <= 0;
		  a_int <= 8'b0;
	     b_int <= 8'b00000000;
		  mult1 <= 16'b0000000000000000;
		  mult1 <= 16'b0000000000000000;
		end
	 else //if (clk)
	   begin
	     a_int <= A;
	     b_int <= B;
	     mult1 <= a_int * b_int;
	     mult2 <= mult1;
	     result_mult <= mult2;
	     done3 <= start & (~done_mult_int);
	     done2 <= done3 & (~done_mult_int);
	     done1 <= done2 & (~done_mult_int);
	     done_mult_int <= done1 & (~done_mult_int);
      end
  end
	
assign done_mult = done_mult_int;

endmodule