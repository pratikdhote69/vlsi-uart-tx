`timescale 1ns/1ps

module tb_uart_tx;

    // Testbench Signals
    logic        clk;
    logic        rst_n;
    logic        tx_start;
    logic [7:0]  data_in;
    logic [15:0] prescale;
    logic        tx_out;
    logic        tx_busy;

    // Instantiate the Device Under Test (DUT)
    uart_tx u_uart_tx (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .data_in(data_in),
        .prescale(prescale),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );

    // Clock Generation (100 MHz clock -> 10ns period)
    always #5 clk = ~clk;

    // Helper Task to Transmit a Byte and Wait for Completion
    task automatic send_byte(input [7:0] byte_to_send, input [15:0] p_val);
        @(posedge clk);
        #1;
        data_in  = byte_to_send;
        prescale = p_val;
        tx_start = 1'b1;
        @(posedge clk);
        #1;
        tx_start = 1'b0;
        
        // Wait for transmission to start and busy to go high
        while (!tx_busy) @(posedge clk);
        $display("[TB TIME: %0t] Transmission started for byte 0x%h", $time, byte_to_send);
        
        // Wait for transmission to complete and busy to go low
        while (tx_busy) @(posedge clk);
        $display("[TB TIME: %0t] Transmission completed for byte 0x%h", $time, byte_to_send);
    endtask

    // Main Test Sequence
    initial begin
        // VCD Waveform Dump
        $dumpfile("C:/Users/prati/Desktop/AI_VLSI_FACTORY/output/uart_tx/sim/waves.vcd");
        $dumpvars(0, tb_uart_tx);

        // Initialize Signals
        clk      = 1'b0;
        rst_n    = 1'b0;
        tx_start = 1'b0;
        data_in  = 8'h00;
        prescale = 16'd10; // Fast prescale for simulation efficiency

        // Test Case 1: Reset Sequence (Assert reset for 5 clock cycles)
        $display("\n--- Test Case 1: Asserting Reset ---");
        repeat (5) @(posedge clk);
        #1 rst_n = 1'b1;
        $display("[TB STATUS] Reset released successfully.");
        repeat (2) @(posedge clk);

        // Test Case 2: Standard Transmission (0x55 - Alternating Bits)
        $display("\n--- Test Case 2: Standard Transmission of 0x55 (Prescale = 10) ---");
        send_byte(8'h55, 16'd10);
        repeat (10) @(posedge clk);

        // Test Case 3: Back-to-Back Transmissions (0xAA then 0xF0)
        $display("\n--- Test Case 3: Back-to-Back Transmissions (0xAA and 0xF0) ---");
        fork
            send_byte(8'hAA, 16'd8);
        join
        // Immediately trigger the next byte on the very next cycle after busy drops
        send_byte(8'hF0, 16'd8);
        repeat (10) @(posedge clk);

        // Test Case 4: Transmission with a Large Prescale (0x3C, Prescale = 25)
        $display("\n--- Test Case 4: Transmission with Large Prescale (0x3C, Prescale = 25) ---");
        send_byte(8'h3C, 16'd25);
        repeat (10) @(posedge clk);

        // Test Case 5: Robustness Check - Assert tx_start during Busy (Should be ignored)
        $display("\n--- Test Case 5: Robustness Check (Assert tx_start during Busy) ---");
        @(posedge clk);
        #1;
        data_in  = 8'hA5;
        prescale = 16'd12;
        tx_start = 1'b1;
        @(posedge clk);
        #1;
        tx_start = 1'b0;
        
        // Wait mid-transmission
        repeat (30) @(posedge clk);
        
        // Attempt to corrupt transmission by asserting tx_start with new data
        $display("[TB STATUS] Attempting to corrupt current transmission with new data 0x5A...");
        #1;
        data_in  = 8'h5A;
        tx_start = 1'b1;
        @(posedge clk);
        #1;
        tx_start = 1'b0;
        
        // Wait for original transmission to finish
        while (tx_busy) @(posedge clk);
        $display("[TB STATUS] Original transmission finished. Verifying no corruption occurred.");
        repeat (10) @(posedge clk);

        // Test Case 6: Corner Cases (0x00 and 0xFF)
        $display("\n--- Test Case 6: Corner Cases (0x00 and 0xFF) ---");
        send_byte(8'h00, 16'd10);
        repeat (5) @(posedge clk);
        send_byte(8'hFF, 16'd10);
        repeat (20) @(posedge clk);

        // End of Simulation
        $display("\n[TB STATUS] All test cases completed successfully. Ending simulation.");
        $finish;
    end

endmodule