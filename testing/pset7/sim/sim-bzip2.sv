/* hack to make catsoop happy */

`ifndef CATSOOP
`default_nettype none
`endif /* ! CATSOOP */

`timescale 1ns / 1ps

`define CP	10
`define HCP	(`CP / 2)

`define MSG	64'h67_69_60_d1_9d_78_5a_5b
`define CRC	32'h96_cb_5e_37

/* the result of the crc32-bzip2 is
 * post-complemented during transmission.
 * as a result, we'll no longer end up with
 * a zero result when we shift the crc32 into
 * our LFSR. instead, we get this non-zero
 * magic value which should be consistent
 * across sends
 */
`define MAGIC_CHECK 32'h38_fb_22_84

module crcsim;

	logic clk;
	logic rst;
	logic axiiv;
	logic [1:0] axiid;
	logic axiov;
	logic [31:0] axiod;

	logic [0:63] msg;
	logic [0:31] rcrc;
	logic testok;

	integer i;

	crc uut(.clk(clk), .rst(rst), .axiiv(axiiv), .axiid(axiid), .axiov(axiov), .axiod(axiod));

	initial begin: CLK
		clk = 0;
		forever #`HCP clk = ~clk;
	end

	initial begin: MAIN
`define MKWAVEFORM 1;
`ifdef MKWAVEFORM
		$dumpfile("obj/crc32-bzip2-dp.vcd");
		$dumpvars(0, crcsim);
`endif /* MKWAVEFORM */

		/* spin up the lfsr */
		testok = 1;
		msg = `MSG;

		rst = 1;
		axiiv = 0;
		axiid = 0;
		#`CP;

		rst = 0;
		#`CP;

		$display("== test one: correct CRC generation ==");

		for (i = 0; i < 64; i = i + 2) begin
			axiiv = 1;
			axiid = {msg[i], msg[i+1]};

			if (!axiov) testok = 0;
			#`CP;
		end

		axiid = 0;
		axiiv = 0;

		for (i = 0; i < 2; i = i + 1) begin
			if (!axiov) testok = 0;
			else if (axiod != `CRC) testok = 0;
			#`CP;
		end

		if (^axiod === 1'bX) testok = 0;
		else if (^axiov === 1'bX) testok = 0;

		$display("== test one result: %s", (testok) ? "OK" : "FAIL");
		if (!testok) $finish;

		rst = 1;
		axiiv = 0;
		axiid = 0;
		#`CP;

		rst = 0;
		#`CP;

		$display("== test two: correct residue generation ==");

		for (i = 0; i < 64; i = i + 2) begin
			axiiv = 1;
			axiid = {msg[i], msg[i+1]};

			if (!axiov) testok = 0;
			#`CP;
		end
		
		rcrc = axiod;

		for (i = 0; i < 32; i = i + 2) begin
			axiiv = 1;
			axiid = {rcrc[i], rcrc[i+1]};

			if (!axiov) testok = 0;
			#`CP;
		end

		axiid = 0;
		axiiv = 0;

		for (i = 0; i < 2; i = i + 1) begin
			if (!axiov) testok = 0;
			else if (axiod != `MAGIC_CHECK) testok = 0;
			#`CP;
		end

		if (^axiod === 1'bX) testok = 0;
		else if (^axiov === 1'bX) testok = 0;

		$display("== test two result: %s", (testok) ? "OK" : "FAIL");
		$finish;
	end
endmodule

`ifndef CATSOOP
`default_nettype wire
`endif /* ! CATSOOP */