// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded

// car_counter module count number of cars entered and store the data to ram
// Input: clock clk(1-bit), reset(1-bit), open_gate signal(1-bit), enable signal(1-bit)
//			 ram address(3-bit), time of the day hour(3-bit)
// Output: number of cars corresponding hour of the day (4-bit)

module car_counter (clk, reset, open_gate, en, ram_addr, hour, num_cars);
	
	input logic clk, reset, open_gate, en;
	input logic [2:0] ram_addr;
	input logic [2:0] hour;
	output logic [3:0] num_cars;
	
	logic open_gate_stable; 			// stabled logic for open_gate
	keypress key (.clk, .reset, .in(open_gate), .out(open_gate_stable));
	
	logic [3:0] count;					// number of cars whenever entered the gate, and it is stored in ram
	
	always_ff @ (posedge clk) begin
	
		if (reset) begin
			count <= 3'd0;
		end
		
		else if (open_gate_stable) begin
			count <= (count + 3'd1);
		end
		
	end
	
	ram4x8 ram(
		.clock(clk),
		.data(count),
		.rdaddress(ram_addr),
		.wraddress(hour),
		.wren(en),
		.q(num_cars));
		
endmodule



`timescale 1 ps / 1 ps 	
module car_counter_testbench ();
	
	logic clk, reset, open_gate, en;
	logic [2:0] ram_addr;
	logic [2:0] hour;
	logic [3:0] num_cars;
	
	car_counter dut(.*);
	
	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
	
		reset <= 1; open_gate <= 0; en <= 0; hour <= 3'd0; @(posedge clk);
		reset <= 0; open_gate <= 0; en <= 1; hour <= 3'd1; @(posedge clk);
																			@(posedge clk);
						open_gate <= 1; en <= 0; hour <= 3'd2; @(posedge clk); // one car enters at hour 2 tests user input
						open_gate <= 1; en <= 0; hour <= 3'd2; @(posedge clk);
						open_gate <= 0; en <= 1; hour <= 3'd2; @(posedge clk);
															  repeat(2) @(posedge clk);
						open_gate <= 1; en <= 0; hour <= 3'd3; @(posedge clk); // two cars enter at hour 3
						open_gate <= 0; en <= 0; hour <= 3'd3; @(posedge clk);
						open_gate <= 1; en <= 0; hour <= 3'd3; @(posedge clk);
						open_gate <= 0; en <= 1; hour <= 3'd3; @(posedge clk);
															  repeat(2) @(posedge clk);	
						open_gate <= 0; en <= 0; hour <= 3'd4; @(posedge clk); // no cars enter at hour 4
						open_gate <= 0; en <= 1; hour <= 3'd4; @(posedge clk);
															  repeat(2) @(posedge clk);
						open_gate <= 0; en <= 0; hour <= 3'd0; @(posedge clk); // cycle back through ram to see if it displays correct number of cars
																			@(posedge clk); // total number of cars = 3
						open_gate <= 0; en <= 0; hour <= 3'd1; @(posedge clk); 
																			@(posedge clk);		
						open_gate <= 0; en <= 0; hour <= 3'd2; @(posedge clk); 
																			@(posedge clk);																				
						open_gate <= 0; en <= 0; hour <= 3'd3; @(posedge clk); 
																			@(posedge clk);
						open_gate <= 0; en <= 0; hour <= 3'd4; @(posedge clk); 
																			@(posedge clk);																				

		$stop;
		
	end
	
endmodule
