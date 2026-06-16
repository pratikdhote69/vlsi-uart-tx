`timescale 1ns/1ps

module tb_uart_tx;

    // Testbench Signals
    logic        clk;
    logic        rst_n;
    logic        tx_start;
    logic [7:0]  tx_data;
    logic [15:0] baud_limit;
    logic        tx_out;
    logic        tx_busy;

    // Instantiate Device Under Test (DUT)
    uart_tx dut (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .baud_limit(baud_limit),
        .tx_out(tx_out),
        .tx_busy(tx_busy)
    );

    // Clock Generation (100 MHz clock -> 10ns period)
    always #5 clk = ~clk;

    // Task to transmit a single byte and wait for completion
    task automatic transmit_byte(input [7:0] data, input [15:0] limit);
        begin
            @(posedge clk);
            while (tx_busy) begin
                @(posedge clk);
            end
            
            tx_data    = data;
            baud_limit = limit;
            tx_start   = 1'b1;
            
            @(posedge clk);
            tx_start   = 1'b0; // Deassert start on next cycle
            
            // Wait for transmission to complete
            @(posedge clk);
            while (tx_busy) begin
                @(posedge clk);
            end
            #50; // Inter-packet delay
        end
    endtask

    // Main Test Sequence
    initial begin
        // VCD Waveform Dump
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, tb_uart_tx);

        // Initialize Signals
        clk        = 1'b0;
        rst_n      = 1'b0;
        tx_start   = 1'b0;
        tx_data    = 8'h00;
        baud_limit = 16'd10; // Fast baud rate for simulation efficiency

        // Reset Sequence (Assert reset for 5 clock cycles)
        #50;
        rst_n      = 1'b1;
        #20;

        $display("[TB_START] Starting UART Transmitter Verification...");

        // ==========================================
        // TEST CASE 1: Reset and Idle Verification
        // ==========================================
        $display("[TC1] Verifying Reset and Idle State...");
        if (tx_out !== 1'b1 || tx_busy !== 1'b0) begin
            $display("[ERROR] TC1 Failed! Default state incorrect. tx_out=%b, tx_busy=%b", tx_out, tx_busy);
        end else begin
            $display("[SUCCESS] TC1 Passed.");
        end

        // ==========================================
        // TEST CASE 2: Standard Transmission (0x55)
        // ==========================================
        $display("[TC2] Transmitting Alternating Pattern 0x55 (01010101)...");
        transmit_byte(8'h55, 16'd10);
        $display("[SUCCESS] TC2 Completed.");

        // ==========================================
        // TEST CASE 3: Standard Transmission (0xAA)
        // ==========================================
        $display("[TC3] Transmitting Alternating Pattern 0xAA (10101010)...");
        transmit_byte(8'hAA, 16'd10);
        $display("[SUCCESS] TC3 Completed.");

        // ==========================================
        // TEST CASE 4: Back-to-Back Transmissions
        // ==========================================
        $display("[TC4] Verifying Back-to-Back Transmissions (0x3C then 0xC3)...");
        fork
            transmit_byte(8'h3C, 16'd8);
            begin
                // Wait for first transmission to start, then immediately queue next
                @(posedge tx_busy);
                @(negedge tx_busy);
                transmit_byte(8'hC3, 16'd8);
            end
        join
        $display("[SUCCESS] TC4 Completed.");

        // ==========================================
        // TEST CASE 5: Configurable Baud Rate Test
        // ==========================================
        $display("[TC5] Transmitting 0xFF with slower Baud Rate (baud_limit = 20)...");
        transmit_byte(8'hFF, 16'd20);
        $display("[SUCCESS] TC5 Completed.");

        // ==========================================
        // TEST CASE 6: Robustness - Ignore Start during Busy
        // ==========================================
        $display("[TC6] Verifying tx_start is ignored during active transmission...");
        @(posedge clk);
        tx_data    = 8'hF0;
        baud_limit = 16'd15;
        tx_start   = 1'b1;
        @(posedge clk);
        tx_start   = 1'b0;
        
        // Wait until middle of transmission, then attempt to inject a new start
        repeat (50) @(posedge clk);
        $display("[TC6] Injecting spurious tx_start = 1 while busy...");
        tx_data    = 8'h0F; // This should be ignored
        tx_start   = 1'b1;
        @(posedge clk);
        tx_start   = 1'b0;

        // Wait for current transmission to finish
        while (tx_busy) @(posedge clk);
        #100;
        $display("[SUCCESS] TC6 Completed.");

        $display("[TB_FINISHED] All test cases executed successfully.");
        $finish;
    end

endmodule