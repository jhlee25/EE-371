// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded

// DE1_SoC module communicates to the physical FPGA board
// Input: CLOCK_50(1-bit), KEY(4-bit), SW(10-bit), V_GPIO(13-bit)
// Output: HEX display(7-bit), LEDR(10-bit), V_GPIO(13-bit)

module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, KEY, SW, V_GPIO);

	// define ports
	input logic CLOCK_50;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	
	inout  logic [35:23] V_GPIO;

	logic [31:0] clk;							// (32-bit) divided clock
	parameter whichClock = 25;				// 25th of the divided clock
	clock_divider cdiv(CLOCK_50, clk);
	
   // reset
	logic reset;
	assign reset = SW[9];
	
	// FPGA Inputs ------------------------------------------------------
	logic entrance;						// a car waiting at the entrance
	logic exit;								// a car waiting at the exit
	logic spot1, spot2, spot3; 		// parking spot 1, 2, and 3
	logic [1:0] curr_occup;				// number of the parking spot currently occupied
	
	assign entrance = V_GPIO[23]; 	// presene at entrance gate
	assign exit = V_GPIO[24]; 			// presene at exit gate
	assign spot1 = V_GPIO[28]; 		// presene parking 1
	assign spot2 = V_GPIO[29]; 		// presene parking 2	
	assign spot3 = V_GPIO[30]; 		// presene parking 3
	// ------------------------------------------------------------------
	
	// assign the number of spots to the total of the spots currently 
	assign curr_occup = (spot1 ? 1 : 0) + (spot2 ? 1 : 0) + (spot3 ? 1 : 0);
	
	// FPGA Outputs -----------------------------------------------------
	logic empty, full;
	assign V_GPIO[26] = spot1;			// LED parking 1
	assign V_GPIO[27] = spot2;			// LED parking 2
	assign V_GPIO[32] = spot3;			// LED parking 3
	assign V_GPIO[34] = full;			// LED Full
	
	assign full = (spot1 & spot2 & spot3); 	 // all the spots are occupied
	assign empty = (!spot1 & !spot2 & !spot3); // all the spots are available
	
	logic open_gate; 						// when parkinglot is not full and car is at gate
	logic close_gate; 					// when a car is leaving
	assign open_gate = (!full & entrance);
	assign close_gate = exit;
	
	assign V_GPIO[31] = open_gate;	// opens the entrance gate
	assign V_GPIO[33] = close_gate;	// opens the exit gate
	// ------------------------------------------------------------------
	
	// advance the work day hour by 1 hour
	logic key_raw, key_stable; 	// key_raw: user input / key_stable: after metastability
	
	// meta stability
	always_ff @(posedge CLOCK_50) begin
		key_raw <= ~KEY[0];
	end
	
	// make the user input key to stable
	keypress key (.clk(CLOCK_50), .reset, .in(key_raw), .out(key_stable));
	
	logic [2:0] hour; 					// curent time of day
	logic [2:0] start_h, end_h;	 	// start and end of rush hour
	logic no_rush; 						// if there was no rush at all
	
	// increment rush hour of the day by KEY[0]
	hour_counter h (.reset, .clk(CLOCK_50), .en(key_stable), .curr_time(hour));
	
	// using full and empty status to get start and end rush hour of the day
	rush_hour rh (.clk(CLOCK_50), .reset, .hour, .full, .empty, .start_h, .end_h, .no_rush);
	
	logic [3:0] num_cars; 		// number of cars
	logic [2:0] ram_addr; 		// the current ram address
	logic end_rush_hour;			// the end of 8th hour
	
	// once the end of 8th hour reached, keep the logic enabled
	always_ff @(posedge CLOCK_50) begin
	
		if(reset) begin
			end_rush_hour <= 1'b0;
		end
		
		else if((hour == 3'd7) & (key_stable)) begin
			end_rush_hour <= 1'b1; 
		end
	end
	
	// counter will start incrementing the ram address once the day has ended
	counter count (.reset, .clk(clk[whichClock]), .incr(end_rush_hour), .out(ram_addr));
	
	// total number of cars that have passed into the parkinglot
	car_counter c (.clk(CLOCK_50), .reset, .open_gate, .en(key_stable), .ram_addr, .hour, .num_cars);
	
	// HEX5: current time, HEX0: current number of parking spots left
	// At the end of the 8th hour (i.e. HEX5 shows “7”, and then you increment the hour one more time)
	// HEX4: end of rush hour, HEX3: start of rush hour
	// HEX2: RAM addr (rush hour), HEX1: total number of cars that have entered
	seg7 s7 (.reset, .hour, .curr_occup, .num_cars, .ram_addr, .end_rush_hour, .start_h, .end_h, 
				.no_rush, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);
		
	/*
	// Initialize HEX
   assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;

	// FPGA input
	assign V_GPIO[26] = SW[0];	// LED parking 1
	assign V_GPIO[27] = SW[1];	// LED parking 2
	assign V_GPIO[32] = SW[2];	// LED parking 3
	assign V_GPIO[34] = SW[3];	// LED full
	assign V_GPIO[31] = SW[4];	// Open entrance
	assign V_GPIO[33] = SW[5];	// Open exit

	// FPGA output
	assign LEDR[0] = V_GPIO[28];	// Presence parking 1
	assign LEDR[1] = V_GPIO[29];	// Presence parking 2
	assign LEDR[2] = V_GPIO[30];	// Presence parking 3
	assign LEDR[3] = V_GPIO[23];	// Presence entrance
	assign LEDR[4] = V_GPIO[24];	// Presence exit
	*/

endmodule  // DE1_SoC



//divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	
	input logic clock;
	output logic [31:0] divided_clocks = 32'b0;
	
	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
endmodule



`timescale 1 ps / 1 ps 	
module DE1_SoC_testbench();

	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	wire [35:23] V_GPIO;
	
	logic spot1, spot2, spot3;
	logic entrance, exit;
	
	assign V_GPIO[28] = spot1;
	assign V_GPIO[29] = spot2;	
	assign V_GPIO[30] = spot3;
	
	assign V_GPIO[23] = entrance; 
	assign V_GPIO[24] = exit; 
	
	DE1_SoC dut(.*);
	
	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 CLOCK_50 <= 0;
		 forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		SW[9]<= 1;								  													  	  @(posedge CLOCK_50);
		SW[9]<= 0; KEY[0] <= 0;	spot1 <= 1; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // increment the time of day by 1
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // one car currently in the parking lot
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 1; spot2 <= 1; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // 2 cars 
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 1; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); 
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 1; spot2 <= 1; spot3 <= 1; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // 3 cars full parking lot
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 1; spot3 <= 1; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // start of rush hour
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 1; spot2 <= 1; spot3 <= 1; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // full for mutliple cycles
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 1; spot3 <= 1; entrance <= 0; exit <= 0; @(posedge CLOCK_50); 
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 1; spot2 <= 1; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // 2 cars
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 1; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); 
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 1; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // 1 cars
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); 
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 1; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // empty lot, end of rush hour
					  KEY[0] <= 1;	spot1 <= 1; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // 7th hour
													  repeat(2) @(posedge CLOCK_50);
					  KEY[0] <= 0;	spot1 <= 0; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); // end of day 
					  KEY[0] <= 1;	spot1 <= 0; spot2 <= 0; spot3 <= 0; entrance <= 0; exit <= 0; @(posedge CLOCK_50); 
													  repeat(5) @(posedge CLOCK_50);														  
		$stop;
	end

endmodule	