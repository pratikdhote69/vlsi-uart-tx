`timescale 1ns/1ps

module uart_tx (
    input  logic        clk,          // System clock
    input  logic        rst_n,        // Asynchronous active-low reset
    input  logic        tx_start,     // Start transmission trigger
    input  logic [7:0]  tx_data,      // 8-bit data payload
    input  logic [15:0] baud_limit,   // Baud rate divisor limit
    output logic        tx_out,       // Serial TX output line
    output logic        tx_busy       // Transmitter busy status flag
);

    // FSM State Definitions using SystemVerilog strongly-typed enum
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state, next_state;

    // Internal Registers
    logic [15:0] baud_cnt;            // Counter for baud rate generation
    logic [2:0]  bit_cnt;             // Counter for transmitted data bits (0 to 7)
    logic [7:0]  shift_reg;           // Shift register to hold and serialize data
    logic        baud_tick;           // Pulse asserted when baud_cnt reaches baud_limit

    // Baud Rate Generator Counter
    // Counts from 0 to baud_limit to establish the duration of 1 serial bit
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt <= 16'h0000;
        end else if (state == IDLE) begin
            baud_cnt <= 16'h0000;
        end else begin
            if (baud_cnt >= baud_limit) begin
                baud_cnt <= 16'h0000;
            end else begin
                baud_cnt <= baud_cnt + 1'b1;
            end
        end
    end

    // Generate baud_tick pulse when counter reaches the limit
    assign baud_tick = (baud_cnt == baud_limit);

    // FSM State Transition and Output Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx_out    <= 1'b1; // UART idle state is high
            tx_busy   <= 1'b0;
            bit_cnt   <= 3'b000;
            shift_reg <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    tx_out  <= 1'b1;
                    tx_busy <= 1'b0;
                    bit_cnt <= 3'b000;
                    
                    if (tx_start) begin
                        shift_reg <= tx_data; // Latch input data
                        tx_busy   <= 1'b1;
                        state     <= START;
                    end
                end

                START: begin
                    tx_out  <= 1'b0; // Start bit is always low
                    tx_busy <= 1'b1;
                    
                    if (baud_tick) begin
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx_out  <= shift_reg[0]; // Present LSB to output
                    tx_busy <= 1'b1;
                    
                    if (baud_tick) begin
                        shift_reg <= {1'b0, shift_reg[7:1]}; // Shift right
                        if (bit_cnt == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                end

                STOP: begin
                    tx_out  <= 1'b1; // Stop bit is always high
                    tx_busy <= 1'b1;
                    
                    if (baud_tick) begin
                        state   <= IDLE;
                        tx_busy <= 1'b0;
                    end
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule