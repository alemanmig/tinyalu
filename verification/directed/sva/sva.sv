
module sva (
  input logic         clk_i,
  input logic [7:0]   A, B,
  input logic         rst_ni,
  input logic [2:0]   op_i,
  input logic         start,
  input logic         done,
  input logic [15:0]  result,
  input operation_t   op_set
);

  // done nunca durante reset
  property no_done_in_reset_p;
    @(posedge clk_i)
      !rst_ni |-> !done;
  endproperty
  no_done_in_reset_a: assert property(no_done_in_reset_p);

  // señales de control sin X
  property no_unknown_ctrl_p;
    @(posedge clk_i) disable iff (!rst_ni)
      !$isunknown({start, done, op_i});
  endproperty
  no_unknown_ctrl_a: assert property(no_unknown_ctrl_p);

  // done debe venir después de start (latencia 1 ciclo)
  property start_to_done_p;
    @(posedge clk_i) disable iff (!rst_ni)
      start |=> done;
  endproperty
  start_to_done_a: assert property(start_to_done_p);

  // done no debe durar más de un ciclo
  property done_one_cycle_p;
    @(posedge clk_i) disable iff (!rst_ni)
      done |=> !done;
  endproperty
  done_one_cycle_a: assert property(done_one_cycle_p);

  // done no debe aparecer sin start previo
  property done_requires_start_p;
    @(posedge clk_i) disable iff (!rst_ni)
      done |-> $past(start);
  endproperty
  done_requires_start_a: assert property(done_requires_start_p);

  // op_i estable mientras se completa la operación
  property op_stable_while_busy_p;
    @(posedge clk_i) disable iff (!rst_ni)
      start |=> $stable(op_i) until_with done;
  endproperty
  op_stable_while_busy_a: assert property(op_stable_while_busy_p);

endmodule
