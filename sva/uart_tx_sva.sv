`timescale 1ns/1ps

module uart_tx_sva (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        tx_start,
    input  logic [7:0]  data_in,
    input  logic [15:0] prescale,
    input  logic        tx_out,
    input  logic        tx_busy
);

    //-------------------------------------------------------------------------
    // 1. Reset Property
    //-------------------------------------------------------------------------
    property p_reset_state;
        @(posedge clk) !rst_n |-> (tx_out == 1'b1 && tx_busy == 1'b0);
    endproperty
    a_reset_state: assert property (p_reset_state);

    //-------------------------------------------------------------------------
    // 2. Protocol Assertions
    //-------------------------------------------------------------------------

    // Assertion: tx_busy must rise on the cycle after tx_start is asserted (if not already busy)
    property p_tx_busy_rise;
        @(posedge clk) disable iff (!rst_n)
        (tx_start && !tx_busy) |=> tx_busy;
    endproperty
    a_tx_busy_rise: assert property (p_tx_busy_rise);

    // Assertion: Start bit must be low (0) immediately upon entering transmission
    property p_start_bit_low;
        @(posedge clk) disable iff (!rst_n)
        (tx_start && !tx_busy) |=> (tx_out == 1'b0);
    endproperty
    a_start_bit_low: assert property (p_start_bit_low);

    // Assertion: No transmission activity without tx_start
    property p_no_spurious_tx;
        @(posedge clk) disable iff (!rst_n)
        $fell(tx_out) |-> (tx_busy || $past(tx_start));
    endproperty
    a_no_spurious_tx: assert property (p_no_spurious_tx);

    // Assertion: tx_busy must remain high for the entire duration of the frame
    // Total frame duration in clock cycles = prescale * 10 (1 start + 8 data + 1 stop)
    property p_tx_busy_duration;
        logic [15:0] local_prescale;
        @(posedge clk) disable iff (!rst_n)
        (tx_start && !tx_busy, local_prescale = prescale) |=> 
        tx_busy[*1] ##0 (tx_busy == 1'b1) [*1:$] ##1 (tx_busy == 1'b0);
    endproperty
    a_tx_busy_duration: assert property (p_tx_busy_duration);

    // Assertion: Stop bit must be high (1) at the end of transmission
    property p_stop_bit_high;
        @(posedge clk) disable iff (!rst_n)
        $fell(tx_busy) |-> (tx_out == 1'b1);
    endproperty
    a_stop_bit_high: assert property (p_stop_bit_high);

    //-------------------------------------------------------------------------
    // 3. Cover Properties
    //-------------------------------------------------------------------------
    
    // Cover successful transmission start
    c_tx_start: cover property (@(posedge clk) disable iff (!rst_n) tx_start && !tx_busy);

    // Cover back-to-back transmission
    c_back_to_back: cover property (
        @(posedge clk) disable iff (!rst_n)
        $fell(tx_busy) ##1 (tx_start && !tx_busy)
    );

endmodule

// Bind statement to connect SVA to the RTL module
bind uart_tx uart_tx_sva i_uart_tx_sva (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .data_in(data_in),
    .prescale(prescale),
    .tx_out(tx_out),
    .tx_busy(tx_busy)
);