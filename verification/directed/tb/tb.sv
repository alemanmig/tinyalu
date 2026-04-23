module tb;

  timeunit      1ns;
  timeprecision 100ps;

  // Clock signal
  logic clk_i = 0;
  int unsigned MainClkPeriod = 10;
  always #(MainClkPeriod / 2) clk_i = ~clk_i;

  // Interface
  vif_if vif (clk_i);

  // Test
  test top_test (vif);

  // DUT
  tinyalu dut (
    .A       (vif.A),
    .B       (vif.B),
    .clk_i   (vif.clk_i),
    .op      (vif.op_i),
    .reset_ni(vif.rst_ni),
    .start   (vif.start),
    .done    (vif.done),
    .result  (vif.result)
  );

  // SVA
  bind tinyalu sva dut_sva (
    .clk_i  (vif.clk_i),
    .A      (vif.A),
    .B      (vif.B),
    .rst_ni (vif.rst_ni),
    .op_i   (vif.op_i),
    .start  (vif.start),
    .done   (vif.done),
    .result (vif.result),
    .op_set (vif.op_set)
  );

  initial begin
    $timeformat(-9, 1, "ns", 10);
  end

endmodule : tb
