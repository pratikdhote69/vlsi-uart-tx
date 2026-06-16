`timescale 1ns/1ps

module uart_tx (
    input  logic        clk,       // System clock
    input  logic        rst_n,     // Active-low asynchronous reset
    input  logic        tx_start,  // Start transmission trigger
    input  logic [7:0]  data_in,   // 8-bit data to transmit
    input  logic [15:0] prescale,  // Clock cycles per bit (Baud divisor)
    output logic        tx_out,    // Serial TX output line
    output logic        tx_busy    // Transmitter busy status flag
);

    // FSM State Encoding
    typedef enum logic [1:0] {
        ST_IDLE  = 2'b00,
        ST_START = 2'b01,
        ST_DATA  = 2'b10,
        ST_STOP  = 2'b11
    } state_t;

    state_t state_reg, state_next;

    // Internal Registers
    logic [15:0] clk_cnt_reg, clk_cnt_next; // Baud rate generator counter
    logic [2:0]  bit_cnt_reg, bit_cnt_next; // Data bit index counter (0 to 7)
    logic [7:0]  sh_reg, sh_next;           // Shift register for serialization
    logic        tx_out_reg, tx_out_next;   // Registered TX output
    logic        tx_busy_reg, tx_busy_next; // Registered busy flag

    // Sequential Block: State and Register Update
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg    <= ST_IDLE;
            clk_cnt_reg  <= '0;
            bit_cnt_reg  <= '0;
            sh_reg       <= '0;
            tx_out_reg   <= 1'b1; // UART idle state is high
            tx_busy_reg  <= 1'b0;
        end else begin
            state_reg    <= state_next;
            clk_cnt_reg  <= clk_cnt_next;
            bit_cnt_reg  <= bit_cnt_next;
            sh_reg       <= sh_next;
            tx_out_reg   <= tx_out_next;
            tx_busy_reg  <= tx_busy_next;
        end
    end

    // Combinational Block: Next-State and Output Logic
    always_comb begin
        // Default assignments to prevent latches
        state_next    = state_reg;
        clk_cnt_next  = clk_cnt_reg;
        bit_cnt_next  = bit_cnt_reg;
        sh_next       = sh_reg;
        tx_out_next   = tx_out_reg;
        tx_busy_next  = tx_busy_reg;

        case (state_reg)
            ST_IDLE: begin
                tx_out_next  = 1'b1;
                tx_busy_next = 1'b0;
                clk_cnt_next = '0;
                bit_cnt_next = '0;
                if (tx_start) begin
                    sh_next      = data_in; // Latch input data
                    tx_busy_next = 1'b1;
                    state_next   = ST_START;
                end
            end

            ST_START: begin
                tx_out_next  = 1'b0; // Start bit is low
                tx_busy_next = 1'b1;
                if (clk_cnt_reg >= (prescale - 1)) begin
                    clk_cnt_next = '0;
                    state_next   = ST_DATA;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1'b1;
                end
            end

            ST_DATA: begin
                tx_out_next  = sh_reg[0]; // Send LSB first
                tx_busy_next = 1'b1;
                if (clk_cnt_reg >= (prescale - 1)) begin
                    clk_cnt_next = '0;
                    sh_next      = {1'b0, sh_reg[7:1]}; // Shift right
                    if (bit_cnt_reg == 3'd7) begin
                        bit_cnt_next = '0;
                        state_next   = ST_STOP;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1'b1;
                    end
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1'b1;
                end
            end

            ST_STOP: begin
                tx_out_next  = 1'b1; // Stop bit is high
                tx_busy_next = 1'b1;
                if (clk_cnt_reg >= (prescale - 1)) begin
                    clk_cnt_next = '0;
                    tx_busy_next = 1'b0;
                    state_next   = ST_IDLE;
                end else begin
                    clk_cnt_next = clk_cnt_reg + 1'b1;
                end
            end

            default: begin
                state_next = ST_IDLE;
            end
        endcase
    end

    // Continuous assignment to output ports
    assign tx_out  = tx_out_reg;
    assign tx_busy = tx_busy_reg;

endmodule