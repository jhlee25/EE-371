// Junhyoung Lee & Sangmin Lee
// 01/24/2022
// EE 371
// Lab #2 Task #3
// This program uses dual port memory to implement FIFO design with circular queue

// DE1_SoC module communicates to the physical FPGA board

module DE1_SoC #(parameter depth = 4, parameter width = 8)
					(CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR);
	
	input logic CLOCK_50; 												// 1-bit 50MHz clock
	input logic [9:0] SW;												// 10-bits SW
	input logic [3:0] KEY; 												// Active low property, 4-bits KEY
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// 6 HEXs of 7-bits
	output logic [9:0] LEDR;											// 10-bit LEDR
	
	/*
	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk; // 32-bit divided clk
	parameter whichClock = 25; // 25th of divided clock from clock_divider
	clock_divider cdiv (CLOCK_50, clk);
	*/
	
	// logic to convey the data going in an out from each module	
	logic [width - 1:0] data_in;
	logic [width - 1:0] data_out;
	logic [width - 1:0] r_addr;
	logic [width - 1:0] w_addr;
	
	assign data_in = SW[7:0];
	
	// logic for enabling read and write and for these press
	logic r_input, w_input, r_input_p, w_input_p;
	
	assign r_input = SW[9];
	assign w_input = SW[8];
	
	// the read and write inputs through userInput makes as one press at time
	userInput r (.clk(CLOCK_50), .reset(reset), .in(r_input), .out(r_input_p));
	userInput w (.clk(CLOCK_50), .reset(reset), .in(w_input), .out(w_input_p));
	
	// Instantiate FIFO module
	FIFO #(depth, width) fifo (.clk(/*clk[whichClock]*/CLOCK_50), .reset(~KEY[0]), .read(r_input_p), .write(w_input_p), .inputBus(data_in), 
										.empty(LEDR[8]), .full(LEDR[9]), .outputBus(data_out),
										.read_Addr(r_addr), .write_Addr(w_addr));
	
	// logic to store output in order to display correct hexadecimal on display
	logic [6:0] HEX5_, HEX4_, HEX3_, HEX2_, HEX1_, HEX0_;	
	
	// data input in hexadecimal
	seg7 hex5 (.bcd(data_in[7:4]), .leds(HEX5_));
	assign HEX5 = HEX5_;
	seg7 hex4 (.bcd(data_in[3:0]), .leds(HEX4_));
	assign HEX4 = HEX4_;
	
	// address for read and write
	seg7 hex3 (.bcd(r_addr[3:0]), .leds(HEX3_));
	assign HEX3 = HEX3_;
	seg7 hex2 (.bcd(w_addr[3:0]), .leds(HEX2_));
	assign HEX2 = HEX2_;
	
	// data output in hexadecimal
	seg7 hex1 (.bcd(data_out[7:4]), .leds(HEX1_));
	assign HEX1 = HEX1_;
	seg7 hex0 (.bcd(data_out[3:0]), .leds(HEX0_));
	assign HEX0 = HEX0_;	
	
endmodule


`timescale 1 ps / 1 ps
module DE1_SoC_testbench ();

	parameter depth = 4, width = 8;

	logic CLOCK_50; 												// 1-bit 50MHz clock
	logic [9:0] SW;												// 10-bits SW
	logic [3:0] KEY; 												// Active low property, 4-bits KEY
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;		// 6 HEXs of 7-bits
	logic [9:0] LEDR;												// 10-bit LEDR
	
	DE1_SoC #(depth, width) dut (.CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .SW, .LEDR, .KEY);
	
	//clock setup
	parameter clock_period = 100;
	initial begin
		CLOCK_50 <= 0;
		// every 50 period, the most divided clock is high and low
		forever #(clock_period /2) CLOCK_50 <= ~CLOCK_50;
	end //initial
	
	initial begin
		
		KEY[0]<= 0;								  										@(posedge CLOCK_50);
		KEY[0]<= 1; SW[9] <= 0; SW[8] <= 0; SW[7:0] <= 8'b00000000; 	@(posedge CLOCK_50);
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[8] <= 1;  SW[0] <= 1; 									@(posedge CLOCK_50);
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[8] <= 0;  SW[0] <= 0; 									@(posedge CLOCK_50);						
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[8] <= 1;  SW[1] <= 1; 									@(posedge CLOCK_50);
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[8] <= 0;  SW[1] <= 0; 									@(posedge CLOCK_50);						
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[8] <= 1;  SW[1] <= 1; 									@(posedge CLOCK_50);
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[8] <= 0;  SW[1] <= 0; 									@(posedge CLOCK_50);						
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);
						SW[9] <= 1; SW[0] <= 0;										@(posedge CLOCK_50);
						SW[9] <= 0; SW[0] <= 0;										@(posedge CLOCK_50);
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);	
						SW[9] <= 1; SW[0] <= 0;										@(posedge CLOCK_50);
						SW[9] <= 0; SW[0] <= 0;										@(posedge CLOCK_50);
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);	
						SW[9] <= 1; SW[0] <= 0;										@(posedge CLOCK_50);
						SW[9] <= 0; SW[0] <= 0;										@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);	
																							@(posedge CLOCK_50);																	
																							@(posedge CLOCK_50);	
			
		$stop; //end simulation	
								
	end //initial
		
endmodule	