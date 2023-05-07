// Junhyoung Lee & Sangmin Lee
// 02/15/2022
// EE 371
// Lab #4 Task #2
// This program is designed for a binary search algorithm, 
// which searches through an array to locate an 8-bit value A

// DE1_SoC module communicates to the physical FPGA board
// Input: KEY(4-bit), SW(1-bit), CLOCK_50(1-bit)
// Output: 6 HEXs(7-bit), LEDR(10-bit)
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input logic CLOCK_50;
	
	logic found, done;		// (1-bit) found and done connected to LED
	logic [4:0] addr;			// (5-bit) the result address for given data shown in HEX
	logic [7:0] A;				// (8-bit) given data input to find corresponding the address
	
	logic reset, s;			// (1-bit) reset and start
	logic not_found;			// (1-bit) the given data is not found in the array
	
	// turn off other HEXs that are not used
	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	
	// the given data is not found even after the binary search is done
	assign not_found = (~found) & (done);
	
	assign A = SW[7:0];
	assign s = SW[9];
	assign reset = ~KEY[0];
	assign LEDR[9] = found;
	assign LEDR[8] = not_found;
	
	search S (.*, .clk(CLOCK_50));
	
	// first digit of the address shown a, 10th digit of the address shown in b
	logic [3:0] a, b;
	assign a = addr % 5'd16;
	assign b = addr / 5'd16;
	
	// shows the address in hexadecimal
	logic [6:0] HEX_0, HEX_1;
	seg7 segA (.bcd(a), .leds(HEX_0));
	seg7 segB (.bcd(b), .leds(HEX_1));
	
	always_comb begin
	
		if (not_found) begin		// if the given data is not found in the array, turn off the HEXs
			HEX0 = 7'b1111111;
			HEX1 = 7'b1111111;
		end
		else begin 					// show the found address on HEXs
			HEX0 = HEX_0;
			HEX1 = HEX_1;
		end
			
	end
	
				
endmodule


/*
//divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	
	input logic clock;
	output logic [31:0] divided_clocks = 32'b0;
	
	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
	
endmodule
*/


`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
	logic CLOCK_50;
   logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
   logic [3:0] KEY; 
   logic [9:0] SW;
   logic [9:0] LEDR;

   DE1_SoC dut (.*);

	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 CLOCK_50 <= 0;
		 forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	integer i;
   initial begin

		KEY[0] <= 0;											@(posedge CLOCK_50);
		KEY[0] <= 1; SW[9] <= 0; SW[7:0] <= 8'd1;		@(posedge CLOCK_50);	// test for A = 1
																	@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
						 SW[9] <= 1;							@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
		for (i=0; i<20; i++)									@(posedge CLOCK_50);
						 SW[9] <= 0;							@(posedge CLOCK_50);
	
	
		KEY[0] <= 0;											@(posedge CLOCK_50);
		KEY[0] <= 1; SW[9] <= 0; SW[7:0] <= 8'd24;	@(posedge CLOCK_50); // test for A = 24
																	@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
						 SW[9] <= 1;							@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
		for (i=0; i<20; i++)									@(posedge CLOCK_50);
						 SW[9] <= 0;							@(posedge CLOCK_50);
						 
						 
		KEY[0] <= 0;											@(posedge CLOCK_50);
		KEY[0] <= 1; SW[9] <= 0; SW[7:0] <= 8'd31;	@(posedge CLOCK_50); // test for A = 31
																	@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
						 SW[9] <= 1;							@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
		for (i=0; i<20; i++)									@(posedge CLOCK_50);
						 SW[9] <= 0;							@(posedge CLOCK_50);						 
						 
						 
		KEY[0] <= 0;											@(posedge CLOCK_50);
		KEY[0] <= 1; SW[9] <= 0; SW[7:0] <= 8'd34;	@(posedge CLOCK_50); // test for A = 34
																	@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
						 SW[9] <= 1;							@(posedge CLOCK_50);
																	@(posedge CLOCK_50);
		for (i=0; i<20; i++)									@(posedge CLOCK_50);
						 SW[9] <= 0;							@(posedge CLOCK_50);	
		
						 
      $stop;

    end
	 
endmodule
