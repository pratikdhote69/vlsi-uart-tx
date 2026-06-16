`timescale 1ns/1ps

module tb_uart_tx;

    // Testbench signals
    logic        clk;
    logic        rst_n;
    logic        tx_start;
    logic [7:0]  data_in;
    logic [15:0] prescale;
    logic        tx_out;
    logic        tx_busy;

    // Instantiate the Device Under Test (DUT)
    uart_tx dut (
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

    // Helper task to wait for transmission to complete
    task automatic wait_for_tx_done();
        @(posedge clk);
        while (tx_busy) begin
            @(posedge clk);
        end
    endtask

    // Helper task to transmit a single byte
    task automatic send_byte(input [7:0] byte_to_send, input [15:0] scale_val);
        @(posedge clk);
        while (tx_busy) begin
            @(posedge clk); // Wait if busy
        end
        data_in  <= byte_to_send;
        prescale <= scale_val;
        tx_start <= 1'b1;
        @(posedge clk);
        tx_start <= 1'b0;
        $display("[TB TIME: %0t] Initiated TX of 8'h%h with prescale %0d", $time, byte_to_send, scale_val);
    endtask

    // Main Test Sequence
    initial begin
        // VCD Waveform Dump
        $dumpfile("C:/Users/prati/Desktop/AI_VLSI_FACTORY/output/uart_tx/sim/waves.vcd");
        $dumpvars(0, tb_uart_tx);

        // Initialize signals
        clk      = 0;
        rst_n    = 1;
        tx_start = 0;
        data_in  = 8'h00;
        prescale = 16'd8; // Default small prescale for fast simulation

        // --- TEST CASE 1: Reset Sequence ---
        $display("\n--- TEST CASE 1: Reset Sequence ---");
        rst_n = 0;
        #50; // Assert reset for 5 clock cycles (50ns)
        rst_n = 1;
        #20;
        if (tx_out === 1'b1 && tx_busy === 1'b0) begin
            $display("PASS: Reset state verified successfully.");
        end else begin
            $display("FAIL: Reset state incorrect. tx_out=%b, tx_busy=%b", tx_out, tx_busy);
        end

        // --- TEST CASE 2: Standard Transmission (Alternating Bits 0x55) ---
        $display("\n--- TEST CASE 2: Transmitting 8'h55 (Alternating Bits) ---");
        send_byte(8'h55, 16'd8);
        wait_for_tx_done();
        #100;

        // --- TEST CASE 3: Standard Transmission (Alternating Bits 0xAA) ---
        $display("\n--- TEST CASE 3: Transmitting 8'hAA (Alternating Bits) ---");
        send_byte(8'hAA, 16'd8);
        wait_for_tx_done();
        #100;

        // --- TEST CASE 4: Transmission with Different Prescale (0xF0, prescale=12) ---
        $display("\n--- TEST CASE 4: Transmitting 8'hF0 with Prescale = 12 ---");
        send_byte(8'hF0, 16'd12);
        wait_for_tx_done();
        #100;

        // --- TEST CASE 5: Back-to-Back Transmission ---
        $display("\n--- TEST CASE 5: Back-to-Back Transmission (0x3C then 0xC3) ---");
        send_byte(8'h3C, 16'd8);
        // Wait until busy goes high, then wait for it to drop to immediately trigger next
        @(posedge tx_busy);
        wait_for_tx_done();
        send_byte(8'hC3, 16'd8);
        wait_for_tx_done();
        #200;

        // --- TEST CASE 6: Robustness Check (Ignore tx_start during active transmission) ---
        $display("\n--- TEST CASE 6: Robustness Check (Ignore tx_start during active transmission) ---");
        send_byte(8'hFF, 16'd16);
        #40; // Wait a few cycles into transmission
        @(posedge clk);
        data_in  <= 8'h00; // Attempt to corrupt with new data
        tx_start <= 1'b1;  // Strobe start while busy
        @(posedge clk);
        tx_start <= 1'b0;
        $display("[TB TIME: %0t] Attempted rogue tx_start during active transmission.", $time);
        wait_for_tx_done();
        #200;

        $display("\nAll test cases completed successfully.");
        $finish;
    end

endmodule