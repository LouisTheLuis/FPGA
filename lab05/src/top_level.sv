`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz, //clock @ 100 mhz
  input wire btnc, //btnc (used for reset)
  input wire eth_crsdv,
  input wire [1:0] eth_rxd,

  output logic [15:0] led, 
  output logic eth_refclk,
  output logic eth_rstn
  );
    logic [15:0] counter;
    logic axiov;
    logic [1:0] axiod;

    // Global system reset
    assign eth_rstn = btnc; 

    // Generate 50mhz clock
    divider clk_div (
        .clk(clk_100mhz), 
        .ethclk(eth_refclk));

    // Ethernet module
    ether eth (
        .clk(eth_refclk),
        .rst(eth_rstn),
        .rxd(eth_rxd),
        .crsdv(eth_crsdv),
        .axiov(axiov),
        .axiod(axiod));

    // LEDs count the number of dibits received from the Ethernet cable
    always_ff @(posedge eth_refclk) begin
        if (eth_rstn) begin
            counter <= 0;
        end else begin
            if (axiov) begin
                counter <= counter + 1;
            end
        end
    end
    assign led = counter;

endmodule

`default_nettype wire