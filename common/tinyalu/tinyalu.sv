
/******************************************************************************
 * (C) Copyright 2023 AGH University of Krakow, All Rights Reserved
 *
 * MODULE:    tinyalu
 * DEVICE:
 * PROJECT:   VDIC
 * AUTHOR:    szczygie
 * DATE:      2023 15:28:07
 *
 * ABSTRACT:  DUT component
 *
 *******************************************************************************/

module tinyalu (
    input  logic [7:0]  A,
    input  logic [7:0]  B,
    input  logic        clk,
    input  logic [2:0]  op,
    input  logic        reset_n,
    input  logic        start,
    output logic        done,
    output logic [15:0] result
);

wire        start_single;
wire        start_mult;
wire        done_aax;
wire [8:0]  result_aax;
wire        done_mult;
wire [15:0] result_mult;

assign start_single = start & ~op[2];
assign start_mult   = start & op[2];
assign result       = op[2] ? result_mult : {7'd0, result_aax};
assign done         = op[2] ? done_mult : done_aax;

single_cycle u_single_cycle (
    .A,
    .B,
    .clk,
    .done_aax,
    .op,
    .reset_n,
    .result_aax,
    .start (start_single)
);

three_cycle u_three_cycle (
    .A,
    .B,
    .clk,
    .done_mult,
    .reset_n,
    .result_mult,
    .start(start_mult)
);

endmodule
