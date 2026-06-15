`timescale 1ns/1ps
module uart_tx_sva(uart_tx uut);
    // Reset property: no output activity during reset
    property reset_prop;
        @(posedge uut.clk) disable iff (uut.reset) $rose(uut.tx_out);
    endproperty
    a_reset: assert property (reset_prop) else $display("Reset property failed");

    // Protocol-specific assertions
    property start_bit;
        @(posedge uut.clk) uut.tx_valid && !uut.tx_busy |-> uut.tx_out == 1'd0;
    endproperty
    a_start_bit: assert property (start_bit) else $display("Start bit assertion failed");

    property data_bit;
        @(posedge uut.clk) uut.tx_valid && uut.tx_busy |-> uut.tx_out == uut.shift_reg[0];
    endproperty
    a_data_bit: assert property (data_bit) else $display("Data bit assertion failed");

    property stop_bit;
        @(posedge uut.clk) uut.tx_busy && uut.counter == 4'd1 |-> uut.tx_out == 1'd1;
    endproperty
    a_stop_bit: assert property (stop_bit) else $display("Stop bit assertion failed");

    property tx_ready;
        @(posedge uut.clk) !uut.tx_busy |-> uut.tx_ready == 1'd1;
    endproperty
    a_tx_ready: assert property (tx_ready) else $display("tx_ready assertion failed");

    property tx_valid;
        @(posedge uut.clk) uut.tx_valid && !uut.tx_busy |-> uut.tx_busy == 1'd1;
    endproperty
    a_tx_valid: assert property (tx_valid) else $display("tx_valid assertion failed");

    // Cover properties
    covergroup cg @(posedge uut.clk);
        coverpoint uut.tx_data;
        coverpoint uut.tx_valid;
    endgroup
    cg cg_inst;
endmodule