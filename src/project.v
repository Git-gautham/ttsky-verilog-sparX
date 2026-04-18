/*
 * Copyright (c) 2026 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_prog_clk_router (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs (unused)
    output wire [7:0] uio_out,  // IOs (unused)
    output wire [7:0] uio_oe,   // IOs (unused)
    input  wire       ena,      // always 1 (ignore)
    input  wire       clk,      // system clock
    input  wire       rst_n     // active-low reset
);

    //--------------------------------------------------
    // Reset conversion
    //--------------------------------------------------
    wire rst = ~rst_n;

    //--------------------------------------------------
    // Input decoding (same as your design)
    //--------------------------------------------------
    wire [2:0] addr  = ui_in[2:0];
    wire [3:0] data  = ui_in[6:3];
    wire       wr_en = ui_in[7];

    //--------------------------------------------------
    // 1. 16-bit Master Counter
    //--------------------------------------------------
    reg [15:0] counter;

    always @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 16'd0;
        else
            counter <= counter + 1;
    end

    //--------------------------------------------------
    // 2. Write Edge Detection
    //--------------------------------------------------
    reg wr_en_d;

    always @(posedge clk or posedge rst) begin
        if (rst)
            wr_en_d <= 1'b0;
        else
            wr_en_d <= wr_en;
    end

    wire wr_pulse = wr_en & ~wr_en_d;

    //--------------------------------------------------
    // 3. 8x4 Register File
    //--------------------------------------------------
    reg [3:0] config_reg [7:0];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                config_reg[i] <= i;  // default mapping
        end
        else if (wr_pulse) begin
            config_reg[addr] <= data;
        end
    end

    //--------------------------------------------------
    // 4. Output Crossbar (8 x 16:1 mux)
    //--------------------------------------------------
    genvar j;

    generate
        for (j = 0; j < 8; j = j + 1) begin : OUTPUT_MUX
            assign uo_out[j] = counter[ config_reg[j] ];
        end
    endgenerate

    //--------------------------------------------------
    // Unused IOs (MANDATORY for TT)
    //--------------------------------------------------
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule


