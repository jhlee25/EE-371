// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded

// rush_hour module uses full and empty status to get start and end rush hour of the day
// Input: clock clk(1-bit), reset(1-bit), parking lot full signal(1-bit), parking lot empty signal(1-bit)
//			 current time of the day hour(3-bit)
// Output: start of rush hour start_h(3-bit), end of rush hour end_h(3-bit)
//			  if there was no rush at all no_rush(1-bit)

module rush_hour (clk, reset, hour, full, empty, start_h, end_h, no_rush);

	input logic clk, reset, full, empty;
	input logic [2:0] hour;
	
	output logic [2:0] start_h, end_h;
	output logic no_rush;
	
	logic init_all;			// (1-bit) init state
	logic start_rh;			// (1-bit) start_ state
	logic end_rh;				// (1-bit) end_ state
	logic done_rh;				// (1-bit) done state
	
	rush_hour_control control (.*);
	rush_hour_datapath datapath (.*);
	
endmodule


// rush_hour_control module gives the singal to datapath
// Input: clock clk(1-bit), reset(1-bit), parking lot full signal(1-bit), parking lot empty signal(1-bit)
// Output: (1-bit) init state logic, start_ state logic, end_ state logic, done state logic
module rush_hour_control (
	
	input logic clk, reset, full, empty,
	output logic init_all, start_rh, end_rh, done_rh
	);
		
	enum {init, start_, end_, done} ps, ns;
	
	// control path
	always_comb begin
	
		case(ps)
		
			init: 					ns = start_;
			
			start_: if (full) 	ns = end_;		// if the parking lot is full, go to end
					  else 			ns = start_;
							 
			end_:	  if(empty) 	ns = done;		// if the parking lot is empty, go to done and end the rush hpur
					  else 			ns = end_;
			
			done: 					ns = done; 		// stay in done until reset

		endcase
		
		init_all = (ps==init);
		start_rh = (ps==start_);
		end_rh 	= (ps==end_);
		done_rh 	= (ps==done);
	end
	
	always_ff @ (posedge clk) begin
		if (reset)
			ps <= init;
		else
			ps <= ns;		
	end	
	
endmodule



// rush_hour_datapath module recieves the signal from contoller and gives the output to top-level module
// Input: clock clk(1-bit), (1-bit) init state logic, start_ state logic, end_ state logic, done state logic
// Output: start of rush hour start_h(3-bit), end of rush hour end_h(3-bit)
// 		  if there was no rush at all no_rush(1-bit)
module rush_hour_datapath (

	input logic clk, init_all, start_rh, end_rh, done_rh,
	input logic [2:0] hour,
	output logic [2:0] start_h, end_h,
	output logic no_rush
	);
	
	// temporary end of rush hour (indicating if there is any)
	logic end_tmp;
	
	// data path
	always_ff @ (posedge clk) begin
	
		if(init_all) begin
			start_h <= 3'b000;
			end_h <= 3'b000;
			
			end_tmp <= 0;
		end
		
		else if (start_rh) begin
			start_h <= hour;			// it gets full (start of rush hour)
		end
		
		else if (end_rh) begin
			end_h <= hour; 			// it is empty and done rush hour
		end
		
		else if (done_rh) begin
			end_tmp <= 1'b1;			// the check up is done
		end
				
	end

	assign no_rush = ~(end_tmp);	// there was no rush at all
	
endmodule



`timescale 1 ps / 1 ps
module rush_hour_testbench ();

	logic clk, reset, full, empty;
	logic [2:0] hour;
	
	logic [2:0] start_h, end_h;
	logic no_rush;
	
	rush_hour dut (.*);
	
	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
	
		reset <= 1; full <= 0; empty <= 0; hour <= 3'd0; @(posedge clk);
		reset <= 0; full <= 0; empty <= 0; hour <= 3'd0; @(posedge clk);	
															repeat(2) @(posedge clk);	
		reset <= 0; full <= 1; empty <= 0; hour <= 3'd2; @(posedge clk);
															repeat(2) @(posedge clk);
		reset <= 0; full <= 1; empty <= 0; hour <= 3'd3; @(posedge clk); // full for mutliple hours
															repeat(2) @(posedge clk);
		reset <= 0; full <= 0; empty <= 1; hour <= 3'd5; @(posedge clk);
															repeat(2) @(posedge clk);
		reset <= 0; full <= 0; empty <= 1; hour <= 3'd7; @(posedge clk); // empty for multiple hours
															repeat(2) @(posedge clk);																										
																			
		$stop;
		
	end
	
endmodule
