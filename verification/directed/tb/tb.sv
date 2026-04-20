module tb;

  timeunit      1ns;
  timeprecision 100ps;


  // Clock signal
  logic clk_i = 0;
  int unsigned MainClkPeriod = 10;  // 100 MHz -> 10 ns period
  always #(MainClkPeriod / 2) clk_i = ~clk_i;

  // Interface
  vif_if vif (clk_i);

  // Test
  test top_test (vif);

  // Instantiation
  tynialu dut	(
  .A		(vif.A			),
  .B		(vif.B			),
  .clk		(vif.clk		),
  .op		(vif.op			),        //Operation Code
  .reset_n	(vif.reset_n	),  //Reset syncronus
  .start		(vif.start		), 
  .done		(vif.done		),
  .result	(vif.result		)
  );
  
  // SVA
  bind dut sva 
  dut_sva (
	.A			(vif.A			),
	.B			(vif.B			),
	.clk		(vif.clk		),
	.op			(vif.op			),        //Operation Code
	.reset_n	(vif.reset_n	),  //Reset syncronus
	.star		(vif.start		),
	.done		(vif.done		),
	.result		(vif.result		)
  );

  initial begin
    $timeformat(-9, 1, "ns", 10);
  end

endmodule : tb
