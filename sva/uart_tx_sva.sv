`timescale 1ns/1ps

module uart_tx_sva (
    input logic        clk,
    input logic        rst_n,
    input logic        tx_start,
    input logic [7:0]  tx_data,
    input logic [15:0] baud_limit,
    input logic        tx_out,
    input logic        tx_busy,
    input logic [1:0]  state,
    input logic [2:0]  bit_cnt,
    input logic [15:0] baud_cnt
);

    // -------------------------------------------------------------------------
    // 1. Reset Behavior Assertion
    // -------------------------------------------------------------------------
    // When reset is active, tx_out must be high (idle) and tx_busy must be low.
    property p_reset_state;
        @(posedge clk) !rst_n |-> (tx_out == 1'b1 && tx_busy == 1'b0 && state == 2'b00);
    endproperty
    assert_reset_state: assert property (p_reset_state)
        else $error("[SVA_ERROR] Reset state violation! tx_out=%b, tx_busy=%b", tx_out, tx_busy);

    // -------------------------------------------------------------------------
    // 2. Protocol Assertion: Busy Flag Assertion
    // -------------------------------------------------------------------------
    // When a transmission starts from IDLE, tx_busy must assert on the next cycle.
    property p_busy_assert;
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b00 && tx_start) |=> (tx_busy == 1'b1);
    endproperty
    assert_busy_assert: assert property (p_busy_assert)
        else $error("[SVA_ERROR] tx_busy failed to assert on tx_start!");

    // -------------------------------------------------------------------------
    // 3. Protocol Assertion: Start Bit Correctness
    // -------------------------------------------------------------------------
    // During the START state, tx_out must be driven low (0).
    property p_start_bit_low;
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b01) |-> (tx_out == 1'b0);
    endproperty
    assert_start_bit_low: assert property (p_start_bit_low)
        else $error("[SVA_ERROR] Start bit is not low during START state!");

    // -------------------------------------------------------------------------
    // 4. Protocol Assertion: Stop Bit Correctness
    // -------------------------------------------------------------------------
    // During the STOP state, tx_out must be driven high (1).
    property p_stop_bit_high;
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b11) |-> (tx_out == 1'b1);
    endproperty
    assert_stop_bit_high: assert property (p_stop_bit_high)
        else $error("[SVA_ERROR] Stop bit is not high during STOP state!");

    // -------------------------------------------------------------------------
    // 5. Protocol Assertion: Baud Counter Limit
    // -------------------------------------------------------------------------
    // The baud counter must never exceed the configured baud_limit during active states.
    property p_baud_limit_bound;
        @(posedge clk) disable iff (!rst_n)
        (state != 2'b00) |-> (baud_cnt <= baud_limit);
    endproperty
    assert_baud_limit_bound: assert property (p_baud_limit_bound)
        else $error("[SVA_ERROR] baud_cnt exceeded baud_limit! baud_cnt=%d, limit=%d", baud_cnt, baud_limit);

    // -------------------------------------------------------------------------
    // 6. Data Integrity Assertion: State Hold Without Tick
    // -------------------------------------------------------------------------
    // The FSM state must remain stable until the baud counter reaches the baud limit.
    property p_state_hold;
        @(posedge clk) disable iff (!rst_n)
        (state != 2'b00 && baud_cnt < baud_limit) |=> (state == $past(state));
    endproperty
    assert_state_hold: assert property (p_state_hold)
        else $error("[SVA_ERROR] State transitioned before baud_tick occurred!");

    // -------------------------------------------------------------------------
    // 7. Functional Coverage Properties
    // -------------------------------------------------------------------------
    // Cover a complete transmission sequence from IDLE -> START -> DATA -> STOP -> IDLE
    cover_full_transmission: cover property (
        @(posedge clk) disable iff (!rst_n)
        (state == 2'b00 && tx_start) ##[1:$] (state == 2'b01) ##[1:$] (state == 2'b10) ##[1:$] (state == 2'b11) ##[1:$] (state == 2'b00)
    );

endmodule

// Bind Statement to attach SVA to the RTL module
bind uart_tx uart_tx_sva i_uart_tx_sva (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .baud_limit(baud_limit),
    .tx_out(tx_out),
    .tx_busy(tx_busy),
    .state(state),
    .bit_cnt(bit_cnt),
    .baud_cnt(baud_cnt)
);