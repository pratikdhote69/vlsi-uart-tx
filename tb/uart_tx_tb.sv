`timescale 1ns/1ps
module uart_tx_tb;
reg clk;
reg reset;
reg [7:0] tx_data;
reg tx_valid;
wire tx_ready;
wire tx_out;

uart_tx uut(
    .clk(clk),
    .reset(reset),
    .tx_data(tx_data),
    .tx_valid(tx_valid),
    .tx_ready(tx_ready),
    .tx_out(tx_out)
);

initial begin
    $dumpfile("C:/Users/prati/Desktop/AI_VLSI_FACTORY/output/uart_tx/sim/waves.vcd");
    $dumpvars(0, uart_tx_tb);
end

always #5 clk = ~clk;

initial begin
    clk = 1'd0;
    reset = 1'd1;
    tx_data = 8'd0;
    tx_valid = 1'd0;
    #10 reset = 1'd0;
    // Test case 1: Send a byte
    #10 tx_data = 8'd5;
    tx_valid = 1'd1;
    #10 tx_valid = 1'd0;
    #10 $display("Test case 1: Sent 0x%h", tx_data);
    // Test case 2: Send another byte
    #50 tx_data = 8'd10;
    tx_valid = 1'd1;
    #10 tx_valid = 1'd0;
    #10 $display("Test case 2: Sent 0x%h", tx_data);
    // Test case 3: Send a byte with invalid data
    #50 tx_data = 8'd255;
    tx_valid = 1'd1;
    #10 tx_valid = 1'd0;
    #10 $display("Test case 3: Sent 0x%h", tx_data);
    // Test case 4: Send a byte with reset
    #50 reset = 1'd1;
    #10 reset = 1'd0;
    #10 tx_data = 8'd20;
    tx_valid = 1'd1;
    #10 tx_valid = 1'd0;
    #10 $display("Test case 4: Sent 0x%h after reset", tx_data);
    // Test case 5: Send multiple bytes
    #50 tx_data = 8'd30;
    tx_valid = 1'd1;
    #10 tx_valid = 1'd0;
    #50 tx_data = 8'd40;
    tx_valid = 1'd1;
    #10 tx_valid = 1'd0;
    #10 $display("Test case 5: Sent multiple bytes");
    #10 $finish;
end
endmodule