import one_pkg::*;

module test (
  vif_if vif
);

  covergroup op_conv;
  
    coverpoint vif.op_set {
      bins single_cycle[] = {[add_op : xor_op], rst_op, no_op};
      bins multi_cycle    = {mul_op};
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
  endgroup

function automatic logic [7:0] get_data();
  get_data = $urandom_range(8'h00, 8'hFF);
endfunction : get_data

function automatic operation_t get_op();
  int unsigned sel;

  sel = $urandom_range(0, 5);

  case (sel)
    0: get_op = no_op;
    1: get_op = add_op;
    2: get_op = and_op;
    3: get_op = xor_op;
    4: get_op = mul_op;
    5: get_op = rst_op;
    default: get_op = no_op;
  endcase
endfunction : get_op


  op_conv              oc;
  zeros_or_ones_on_ops c_00_FF;
  shortint predicted_result;

  initial begin : coverage
    oc     = new();
    c_00_FF = new();

    forever begin
      @(negedge vif.clk_i);
      oc.sample();
      c_00_FF.sample();
    end
  end

  initial begin
    $display("Begin Of Simulation.");

    vif.A      = '0;
    vif.B      = '0;
    vif.op_i   = '0;
    vif.start  = 1'b0;
    vif.rst_ni = 1'b1;

  fork
    tester();
    scoreboard(); 
  join

    #(200ns);
    $display("End Of Simulation.");
    $finish;
  end

  task automatic tester();
    vif.rst_ni = 1'b0;
    vif.start  = 1'b0;
    @(negedge vif.clk_i);
    @(negedge vif.clk_i);
    vif.rst_ni = 1'b1;

    repeat (1000) begin
      @(negedge vif.clk_i);
      vif.op_set = get_op();
      vif.op_i   = vif.op_set;
      vif.A      = get_data();
      vif.B      = get_data();

      vif.start = 1'b1;
      @(negedge vif.clk_i);
      vif.start = 1'b0;
    end
  endtask

task automatic scoreboard();
  byte        A_s, B_s;
  operation_t op_s;
  shortint    predicted_result;

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