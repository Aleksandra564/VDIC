/******************************************************************************
 * (C) Copyright 2023 AGH University of Krakow, All Rights Reserved
 *
 * MODULE:    single_cycle
 * DEVICE:
 * PROJECT:   VDIC
 * AUTHOR:    szczygie
 * DATE:      2023 15:28:07
 *
 * ABSTRACT:  DUT component
 *
 *******************************************************************************/

module single_cycle (
    input  logic [7:0] A,
    input  logic [7:0] B,
    input  logic       clk,
    input  logic [2:0] op,
    input  logic       reset_n,
    input  logic       start,
    output logic       done_aax,
    output logic [8:0] result_aax
);

always_ff @(posedge clk) begin : result_blk
    if(!reset_n) begin
        result_aax <= '0;
    end
    else begin
        if(start)begin
            case(op)
                3'b001: result_aax  <= A + B;
                3'b010: result_aax  <= A & B;
                3'b011: result_aax  <= A ^ B;
                default: result_aax <= '0;
            endcase
        end
    end
end

always_ff @(posedge clk) begin : done_blk
    if(!reset_n) begin
        done_aax <= '0;
    end
    else begin
        if(start && (op != 3'b000)) begin
            done_aax <= '1;
        end
        else begin
            done_aax <= '0;
        end
    end
end

endmodule
