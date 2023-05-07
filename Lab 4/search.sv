// Junhyoung Lee & Sangmin Lee
// 02/15/2022
// EE 371
// Lab #4 Task #2
// This program is designed for a binary search algorithm, 
// which searches through an array to locate an 8-bit value A

// search module finds the address for corresponding user input data using binary search
// Input: clock clk(1-bit), reset(1-bit), start s(1-bit), user input data A(8-bit)
// Output: done(1-bit), found(1-bit), address of the data A addr(5-bit)
module search (clk, reset, s, A, found, done, addr);

	input logic clk, reset, s;
	input logic [7:0] A;
	
	output logic found, done;
	output logic [4:0] addr;
	
	logic [7:0] a;					// current value of A to find the address(8-bit)
	logic [4:0] new_addr;		// the new address updated by (left + right / 2)
	logic [4:0] left, right;	// left point and right point for range of search
	logic check_last;				// check the last value of the array if it matches with the given data
	
	// for controller (1-bit)
	logic init_all, update_addr, set_left, set_right, set_found, set_done;
	
	search_controller C (.*);
	search_datapath D (.*);
	
	ram32x8 RAM (.address(new_addr),	.clock(clk), .data(0), .wren(0), .q(a));

endmodule


// The search_controller module
// Input: clock clk(1-bit), reset(1-bit), start s(1-bit), user input data A(8-bit)
//			 left and right boundary to do the binary search(5-bit), current value of A to find the address(8-bit)
//			 the new address updated by left + right / 2 (5-bit)
// Output: (1-bit) initiating all logic(init_all), update the addr(update_addr), change the left and right boundary(set_left, set_right)
//			  (1-bit) signal for found and done(set_found, set_done), checking the last value of the array(check_last)
module search_controller (
	
	input logic clk, reset, s,
	input logic [4:0] left, right,
	input logic [7:0]	a,
	input logic [7:0]	A,
	input logic [4:0] new_addr,
	output logic init_all, update_addr, set_left, set_right, set_found, set_done, check_last
	);
	
	enum {init, loop, search, hold, done} ps, ns;
	
	always_comb begin
	
		case(ps)
			
			// initial state
			init: ns = !s ? init : loop;
			
			// looping the binary search
			loop: ns = (left > right) ? done : search;
			
			// check if the current value matches with given value
			search: ns = (a == A) ? done : hold;
			
			// hold the address value for updating the RAM value
			hold: ns = (new_addr==left) ? done : loop;
			
			// finish the looping and show the result
			done: ns = s ? done : init;
		
		endcase
		
		// assign the output logic
		init_all = (ps==init);
		update_addr = (ps==loop);
		set_left = (ps==loop) & (a < A);
		set_right = (ps==loop) & (a > A);
		set_found = ((ps==loop) & (a == A)) || ((ps==loop) & (new_addr+1==A));
		check_last = ((ps==loop) & (new_addr+1==A));
		set_done = (ps==done);
		
	end
	
	
	always_ff @ (posedge clk)begin
		if (reset)
			ps <= init;
		else
			ps <= ns;		
	end	

endmodule


// The search_datapath module
// Input: (1-bit) initiating all logic(init_all), update the addr(update_addr), change the left and right boundary(set_left, set_right),
//			 (1-bit) signal for found and done(set_found, set_done),clock clk(1-bit), checking the last value of the array(check_last)
// Output: left and right boundary to do the binary search(5-bit), the new address updated by left + right / 2 (5-bit),
//			  done(1-bit), found(1-bit), address of the data A addr(5-bit)
module search_datapath (
	
	input logic init_all, update_addr, set_left, set_right, set_found, set_done,
	input logic clk,
	input logic check_last,

	output logic [4:0] left, right,
	output logic [4:0] new_addr,
	output logic found, done,
	output logic [4:0] addr
	);
	
	// set the new address by binary search (left boundary + right boundary / 2)
	assign new_addr = (left + right) / 2;
	
	always_ff @ (posedge clk) begin
		
		// initiate all the logic
		if (init_all) begin
			left <= 5'd0;
			right <= 5'd31;
			addr <= 5'd0;
			done <= 0;
			found <= 0;
		end
		
		// update the address and check if the given data is the last value in the array
		else if (update_addr)
			if (check_last) addr <= new_addr + 1;
			else				 addr <= new_addr;
		
		// set left boundary as new address which is updated before
		if (set_left)
			left <= new_addr;
		
		// set right boundary as new address which is updated before
		if (set_right)
			right <= new_addr;
		
		// set found high when the found signal is given
		if (set_found)
			found <= 1;
		
		// set done high when the done signal is given
		if (set_done)
			done <= 1;
	
	end

endmodule


`timescale 1 ps / 1 ps
module search_testbench ();
	logic clk, reset, s;
	logic [7:0] A;
	logic done, found;
	logic [4:0] addr;
	
	search dut (.*);
	
	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	integer i;
	initial begin
	
		reset <= 1; 									@(posedge clk);
		reset <= 0; A <= 8'd24; s <= 1; 			@(posedge clk);
		for (i=0; i<20; i++)							@(posedge clk);
		
		$stop;
	
	end

endmodule	