`default_nettype none
`timescale 1ns / 1ps

module bitorder(
    input wire clk,
    input wire rst,
    input wire axiiv,
    input wire [1:0] axiid,

    output logic axiov,
    output logic [1:0] axiod
);

endmodule

`default_nettype wire