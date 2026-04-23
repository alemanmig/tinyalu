module test (
   vif_if vif

);
    typedef enum bit[2:0] {no_op  = 3'b000,
                          add_op = 3'b001,
                          and_op = 3'b010,
                          xor_op = 3'b011,
                          mul_op = 3'b100,
                          rst_op = 3'b111} operation_t;

   operation_t  op_set;

   assign vif.op_i = op_set;

  // ================ FUNCTIONAL COVERAGE ================= //

     covergroup op_cov;

      coverpoint op_set {
         bins single_cycle[] = {[add_op : xor_op], rst_op,no_op};
         bins multi_cycle = {mul_op};

         bins opn_rst[] = ([add_op:mul_op] => rst_op);
         bins rst_opn[] = (rst_op => [add_op:mul_op]);

         bins sngl_mul[] = ([add_op:xor_op],no_op => mul_op);
         bins mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

         bins twoops[] = ([add_op:mul_op] [* 2]);
         bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op, no_op};}

      a_leg: coverpoint vif.a_i {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }

      b_leg: coverpoint vif.b_i {
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

   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage

      oc = new();
      c_00_FF = new();

      forever begin @(negedge vif.clk_i);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage

  // =================== MAIN SEQUENCE ==================== //

  initial begin : tester
      vif.rst_n = 1'b0;
      @(negedge vif.clk_i);
      @(negedge vif.clk_i);
      vif.rst_n = 1'b1;
      vif.start_i = 1'b0;
      repeat (1000) begin
         @(negedge vif.clk_i);
         op_set = get_op();
         vif.a_i = get_data();
         vif.b_i = get_data();
         vif.start_i = 1'b1;
         case (op_set) // handle the start signal
           no_op: begin
              @(posedge vif.clk_i);
              vif.start_i = 1'b0;
           end
           rst_op: begin
              vif.rst_n = 1'b0;
              vif.start_i = 1'b0;
              @(negedge vif.clk_i);
              vif.rst_n = 1'b1;
           end
           default: begin
              wait(vif.done_o);
              vif.start_i = 1'b0;
           end
         endcase // case (op_set)
      end
    // Drain time
    #(200ns);
    $display("End Of Simulation.");
    $finish;
  end :tester

  // ==================== SCOREBOARD ========================= //

   always @(posedge vif.done_o) begin : scoreboard
      shortint predicted_result;
      #1;
      case (op_set)
        add_op: predicted_result = vif.a_i + vif.b_i;
        and_op: predicted_result = vif.a_i & vif.b_i;
        xor_op: predicted_result = vif.a_i ^ vif.b_i;
        mul_op: predicted_result = vif.a_i * vif.b_i;
      endcase // case (op_set)

      if ((op_set != no_op) && (op_set != rst_op))
        if (predicted_result != vif.result_o)
          $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  vif.a_i, vif.b_i, op_set.name(), vif.result_o);

   end : scoreboard

  // ====================== FUNCTIONS ======================== //

     function operation_t get_op();
      bit [2:0] op_choice;
      
      op_choice = $random;
      case (op_choice)
        3'b000 : return no_op;
        3'b001 : return add_op;
        3'b010 : return and_op;
        3'b011 : return xor_op;
        3'b100 : return mul_op;
        3'b101 : return no_op;
        3'b110 : return rst_op;
        3'b111 : return rst_op;
      endcase // case (op_choice)
   endfunction : get_op

   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 8'h00;
      else if (zero_ones == 2'b11)
        return 8'hFF;
      else
        return $random;
   endfunction : get_data


endmodule : test