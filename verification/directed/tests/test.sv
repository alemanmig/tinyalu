import one_pkg::*;

module test (
  vif_if vif
);

  operation_t op_set;

  assign vif.op_i = op_set;

  covergroup op_conv;
  
    coverpoint vif.op_set {
      bins single_cycle[] = {[add_op : xor_op], rst_op, no_op};
      bins multi_cycle    = {mul_op};

      bins opn_rst[] = ([add_op:mul_op] => rst_op);
      bins rst_opn[] = (rst_op => [add_op:mul_op]);

      bins sngl_mul[] = ([add_op:xor_op], no_op => mul_op);
      bins mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

      bins twoops[] = ([add_op:mul_op] [* 2]);
      bins manymult[] = (mul_op [* 3:5]);
    }
  endgroup

  covergroup zeros_or_ones_on_ops;

    all_ops: coverpoint vif.op_set {
      ignore_bins null_ops = {rst_op, no_op};
    }

    a_leg: coverpoint vif.A {
      bins zeros  = {8'h00};
      bins others = {[8'h01:8'hFE]};
      bins ones   = {8'hFF};
    }

    b_leg: coverpoint vif.B {
      bins zeros = {'h00};
      bins others= {['h01:'hFE]};
      bins ones  = {'hFF};
      }

     op_00_FF:  cross a_leg, b_leg, all_ops {
         bins add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins xor_00 = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins xor_FF = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins mul_00 = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins mul_FF = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins mul_max = binsof (all_ops) intersect {mul_op} &&
                        (binsof (a_leg.ones) && binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

  endgroup

  op_conv              oc;
  zeros_or_ones_on_ops c_00_FF;
  
  shortint predicted_result;

  initial begin : coverage
    oc     = new();
    c_00_FF = new();

    forever begin @(negedge vif.clk_i);
      oc.sample();
      c_00_FF.sample();
    end
  end: coverage

  ///////////////////////////////////////////////////////////
  //    Main sequence

  initial begin
    $display("Begin Of Simulation.");
    vif.rst_ni = 1'b0;
    @(negedge vif.clk_i);
    @(negedge vif.clk_i);
    vif.rst_ni = 1'b1;
    vif.start = 1'b1;

    fork
        scoreboard(); 
    join_none

    #(200ns);
    $display("End Of Simulation.");
    $finish;
  end

task automatic scoreboard();
  byte        A_s, B_s;
  operation_t op_s;
  shortint    predicted_result;

  wait(vif.rst_ni == 1'b1);

  forever begin
    @(posedge vif.start);
    A_s  = vif.A;
    B_s  = vif.B;
    op_s = vif.op_set;

    @(posedge vif.done);

    case (op_s)
      add_op: predicted_result = A_s + B_s;
      and_op: predicted_result = A_s & B_s;
      xor_op: predicted_result = A_s ^ B_s;
      mul_op: predicted_result = A_s * B_s;
      default: predicted_result = '0;
    endcase

    if ((op_s != no_op) && (op_s != rst_op)) begin
      if (predicted_result != vif.result) begin
        $error("FAILED: A=%0h B=%0h op=%s result=%0h expected=%0h",
               A_s, B_s, op_s.name(), vif.result, predicted_result);
      end
    end
  end
endtask

endmodule