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
  tinyalu 
    dut (
      .a_i(vif.a_i),
      .b_i(vif.b_i),
      .clk_i(vif.clk_i),
      .op_i(vif.op_i),
      .rst_n(vif.rst_n),
      .start_i(vif.start_i),
      .done_o(vif.done_o),
      .result_o(vif.result_o)
  );
  
  // SVA
  /*bind dut sva 
  dut_sva (
      .a_i(vif.a_i),
      .b_i(vif.b_i),
      .clk_i(vif.clk_i),
      .op_i(vif.op_i),
      .rst_n(vif.rst_n),
      .start_i(vif.start_i),
      .done_o(vif.done_o),
      .result_o(vif.result_o)
  );*/

  initial begin
    $timeformat(-9, 1, "ns", 10);
  end

endmodule : tb
