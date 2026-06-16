`timescale 1ns/1ps

module uart_tx (
    input  logic        clk,          // System clock
    input  logic        rst_n,        // Active-low asynchronous reset
    input  logic        tx_start,     // Start transmission trigger
    input  logic [7:0]  data_in,      // Parallel data byte to transmit
    input  logic [15:0] prescale,     // Baud rate prescaler value
    output logic        tx_out,       // Serial UART output
    output logic        tx_busy       // Transmitter busy status flag
);

    // FSM State Encoding
    typedef enum logic [1:0] {
        ST_IDLE  = 2'b00,
        ST_START = 2'b01,
        ST_DATA  = 2'b10,
        ST_STOP  = 2'b11
    } state_t;

    // Internal Registers
    state_t      state;               // Current state register
    logic [7:0]  data_reg;            // Latched data register
    logic [15:0] prescale_reg;        // Latched prescaler register
    logic [15:0] baud_cnt;            // Baud rate generator counter
    logic [2:0]  bit_idx;             // Data bit index counter (0 to 7)

    // Synchronous FSM and Output Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= ST_IDLE;
            data_reg     <= 8'h00;
            prescale_reg <= 16'h0000;
            baud_cnt     <= 16'h0000;
            bit_idx      <= 3'b000;
            tx_out       <= 1'b1;     // UART idle state is high
            tx_busy      <= 1'b0;     // Not busy on reset
        end else begin
            case (state)
                ST_IDLE: begin
                    tx_out   <= 1'b1; // Hold line high during idle
                    tx_busy  <= 1'b0;
                    baud_cnt <= 16'h0000;
                    
                    if (tx_start) begin
                        state        <= ST_START;
                        data_reg     <= data_in;
                        // Guard against invalid prescaler values (minimum divisor is 2)
                        prescale_reg <= (prescale < 16'd2) ? 16'd2 : prescale;
                        tx_busy      <= 1'b1;
                        tx_out       <= 1'b0; // Drive start bit low immediately
                    end
                end

                ST_START: begin
                    if (baud_cnt >= prescale_reg - 1) begin
                        baud_cnt <= 16'h0000;
                        state    <= ST_DATA;
                        bit_idx  <= 3'b000;
                        tx_out   <= data_reg[0]; // Drive first data bit (LSB)
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                ST_DATA: begin
                    if (baud_cnt >= prescale_reg - 1) begin
                        baud_cnt <= 16'h0000;
                        if (bit_idx == 3'd7) begin
                            state  <= ST_STOP;
                            tx_out <= 1'b1; // Drive stop bit high
                        end else begin
                            bit_idx <= bit_idx + 1'b1;
                            tx_out  <= data_reg[bit_idx + 1]; // Drive next bit
                        end
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                ST_STOP: begin
                    if (baud_cnt >= prescale_reg - 1) begin
                        baud_cnt <= 16'h0000;
                        state    <= ST_IDLE;
                        tx_busy  <= 1'b0; // Clear busy flag
                    end else begin
                        baud_cnt <= baud_cnt + 1'b1;
                    end
                end

                default: begin
                    state <= ST_IDLE;
                end
            endcase
        end
    end

endmodule