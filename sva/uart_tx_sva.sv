`timescale 1ns/1ps

module uart_tx_sva (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_start,
    input  logic [7:0]  data_in,
    input  logic [15:0] prescale,
    input  logic        tx_out,
    input  logic        tx_busy,
    // Internal signals bound for assertion checks
    input  logic [1:0]  state,
    input  logic [7:0]  data_reg,
    input  logic [15:0] prescale_reg,
    input  logic [15:0] baud_cnt,
    input  logic [2:0]  bit_idx
);

    // 1. Reset Behavior: Outputs must be in their default state when reset is active
    property p_reset_state;
        @(posedge clk) !rst_n |-> (tx_out == 1'b1 && tx_busy == 1'b0 && state == 2'b00);
    endproperty
    ast_reset_state: assert property (p_reset_state);

    // 2. Protocol Correctness: tx_busy must rise on the cycle after tx_start is asserted in IDLE
    property p_tx_busy_rise;
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b00 && tx_start) |=> (tx_busy == 1'b1);
    endproperty
    ast_tx_busy_rise: assert property (p_tx_busy_rise);

    // 3. Protocol Correctness: Start bit must be low (0) during ST_START state
    property p_start_bit_low;
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b01) |-> (tx_out == 1'b0);
    endproperty
    ast_start_bit_low: assert property (p_start_bit_low);

    // 4. Protocol Correctness: Stop bit must be high (1) during ST_STOP state
    property p_stop_bit_high;
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b11) |-> (tx_out == 1'b1);
    endproperty
    ast_stop_bit_high: assert property (p_stop_bit_high);

    // 5. Data Integrity: Latched data must remain stable during the entire transmission
    property p_data_stable;
        @(posedge clk) disable iff (!rst_n)
        (state != 2'b00) |-> $stable(data_reg);
    endproperty
    ast_data_stable: assert property (p_data_stable);

    // 6. Data Integrity: Latched prescaler must remain stable during the entire transmission
    property p_prescale_stable;
        @(posedge clk) disable iff (!rst_n)
        (state != 2'b00) |-> $stable(prescale_reg);
    endproperty
    ast_prescale_stable: assert property (p_prescale_stable);

    // 7. Protocol Robustness: tx_start must be ignored if tx_busy is high
    property p_ignore_start_during_busy;
        @(posedge clk) disable iff (!rst_n)
        (tx_busy && tx_start) |=> (state != 2'b01 || $past(state) == 2'b01);
    endproperty
    ast_ignore_start_during_busy: assert property (p_ignore_start_during_busy);

    // Cover Properties for Key Scenarios
    cov_back_to_back_tx: cover property (
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b11 && baud_cnt == prescale_reg - 1 && tx_start)
    );

    cov_max_prescale_tx: cover property (
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b01 && prescale_reg >= 16'd25)
    );

endmodule

// Bind Statement to attach SVA to the RTL module
bind uart_tx uart_tx_sva i_uart_tx_sva (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .data_in(data_in),
    .prescale(prescale),
    .tx_out(tx_out),
    .tx_busy(tx_busy),
    .state(state),
    .data_reg(data_reg),
    .prescale_reg(prescale_reg),
    .baud_cnt(baud_cnt),
    .bit_idx(bit_idx)
);