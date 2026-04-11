/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_adaptive_clock_4mux (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Active-low reset → convert to active-high
    wire rst = ~rst_n;

    // Select lines mapping from inputs
    wire [1:0] sel1 = ui_in[1:0];
    wire [1:0] sel2 = ui_in[3:2];
    wire [1:0] sel3 = ui_in[5:4];
    wire [1:0] sel4 = ui_in[7:6];

    // Counter
    reg [3:0] count;

    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 4'b0000;
        else
            count <= count + 1;
    end

    // Clock divisions
    wire clk_div2  = count[0];
    wire clk_div4  = count[1];
    wire clk_div8  = count[2];
    wire clk_div16 = count[3];

    // MUX function
    function mux4;
        input [1:0] sel;
        input d0, d1, d2, d3;
        begin
            case(sel)
                2'b00: mux4 = d0;
                2'b01: mux4 = d1;
                2'b10: mux4 = d2;
                2'b11: mux4 = d3;
            endcase
        end
    endfunction

    // Outputs mapped to uo_out
    assign uo_out[0] = mux4(sel1, clk_div2, clk_div4, clk_div8, clk_div16);
    assign uo_out[1] = mux4(sel2, clk_div2, clk_div4, clk_div8, clk_div16);
    assign uo_out[2] = mux4(sel3, clk_div2, clk_div4, clk_div8, clk_div16);
    assign uo_out[3] = mux4(sel4, clk_div2, clk_div4, clk_div8, clk_div16);

    // Unused outputs = 0
    assign uo_out[7:4] = 4'b0000;

    // Not using bidirectional IOs
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule


