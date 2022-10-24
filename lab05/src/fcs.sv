`default_nettype none
`timescale 1ns / 1ps

module cksum(
    input wire clk,
    input wire rst,
    input wire axiiv,
    input wire [1:0] axiid,

    output logic done,
    output logic kill
);

endmodule

`default_nettype wire