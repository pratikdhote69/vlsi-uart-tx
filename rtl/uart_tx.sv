`timescale 1ns/1ps
module uart_tx(
    input  logic clk,
    input  logic reset,
    input  logic [7:0] tx_data,
    input  logic tx_valid,
    output logic tx_ready,
    output logic tx_out
);

// shift_reg needs to be 9 bits: 1 start bit + 8 data bits.
// The stop bit is handled separately.
logic [8:0] shift_reg;
// Counter for 10 bits (0-9) to cover 1 start bit + 8 data bits + 1 stop bit.
// Counts down from 9 to 0.
logic [3:0] counter;
// Flag to indicate if a transmission is in progress.
logic tx_busy;

// Internal signal to determine the next state of tx_out.
// This helps to correctly drive tx_out in the same cycle tx_valid is asserted.
logic next_tx_out;

// Combinational logic to determine the next_tx_out value based on current state.
// This ensures tx_out is correctly driven for the start bit in the initial cycle
// and for subsequent data/stop bits.
always_comb begin
    next_tx_out = 1'b1; // Default to idle high (or stop bit)

    if (!tx_busy && tx_valid) begin
        // If a new transmission is requested and the transmitter is idle,
        // the output should immediately go low for the start bit.
        next_tx_out = 1'b0;
    end else if (tx_busy) begin
        // If transmission is in progress:
        if (counter > 4'd0) begin
            // Output the current LSB of shift_reg (start bit or data bit).
            next_tx_out = shift_reg[0];
        end else begin
            // All data bits (and start bit) have been transmitted.
            // Output the stop bit.
            next_tx_out = 1'b1;
        end
    end
    // If !tx_busy and !tx_valid, next_tx_out remains 1'b1 (idle).
end


always @(posedge clk) begin
    if (reset) begin
        // Reset the module to its idle state.
        shift_reg <= 9'd0;
        counter <= 4'd0;
        tx_busy <= 1'b0;
        tx_ready <= 1'b1; // Ready to accept new data.
        tx_out <= 1'b1;   // UART idle state is high.
    end else begin
        // Default assignments for outputs. These will be overridden by specific state logic.
        // tx_ready defaults to 1'b1 (ready) unless busy.
        // tx_out is driven by next_tx_out.
        tx_ready <= 1'b1;
        tx_out <= next_tx_out; // CRITICAL FIX: Drive tx_out from the combinational next_tx_out.

        // Internal registers hold their value by default if not explicitly updated.
        // Explicit assignments like 'shift_reg <= shift_reg;' are redundant in always_ff blocks.

        if (tx_valid && !tx_busy) begin
            // A new transmission request is received and the transmitter is idle.
            // Load the data into the shift register.
            // Frame format for shift_reg: {Data[7:0], Start_Bit (0)}.
            shift_reg <= {tx_data, 1'b0};
            tx_busy <= 1'b1;    // Mark transmitter as busy.
            tx_ready <= 1'b0;   // Not ready for new data during transmission.
            counter <= 4'd9;    // Initialize counter for 10 bits (9 down to 0).
                                // This covers 1 start bit, 8 data bits, and 1 stop bit.
        end else if (tx_busy) begin
            // Transmission is currently in progress.
            tx_ready <= 1'b0; // Still not ready for new data.

            if (counter > 4'd0) begin
                // Transmit data bits (including the start bit, which was output in the previous cycle).
                // 'shift_reg' is shifted right to bring the next bit to the LSB position.
                shift_reg <= shift_reg >> 1; // Shift right, LSB first.
                counter <= counter - 4'd1;   // Decrement bit counter.
            end else begin
                // All data bits (and start bit) have been transmitted, and the stop bit has been output.
                // Transmission complete, return to idle.
                tx_busy <= 1'b0;
                // counter and shift_reg will retain their values (0 and 0 respectively)
                // until a new transmission starts or reset occurs.
            end
        end
        // If neither (tx_valid && !tx_busy) nor tx_busy, the module is idle.
        // In this case, tx_ready retains its default assignment (1'b1).
        // tx_out is driven by next_tx_out, which defaults to 1'b1 when idle.
    end
end

endmodule