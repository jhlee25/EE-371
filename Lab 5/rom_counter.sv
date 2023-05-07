// Junhyoung Lee & Sangmin Lee
// 02/24/2022
// EE 371
// Lab #5 Task #2
// This program uses the audio CODEC on the DE1-SoC board to generate and filter
// noise from both an external source and an internal memory

// rom_counter module update the address of the memory by incrementing one
// Input: (1-bit) clock clk, reset, switch_9 for enabling SW[9], read and write logic
// Output: (24-bit) rom address out
module rom_counter(clk, reset, switch_9, read, write, out);

	input logic clk, reset, switch_9, read, write;
	logic [15:0] addr;
	output logic [23:0] out; 
	
	// increment addr when SW9 is high
	always @(posedge clk) begin
		if(reset || (addr == 24'd47999)) begin
			addr <= 0;
		end
		else if (switch_9 & (read & write)) begin
			addr <= (addr + 1);
		end	
	end 
	
	rom ROM (.address(addr), .clock(clk), .q(out));
	
endmodule



`timescale 1 ps / 1 ps 	
module rom_counter_testbench();
	logic clk, reset, switch_9, read, write;
	logic [23:0] out; 
	
	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 clk <= 0;
		 forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
   rom_counter dut(.*);

	initial begin
		reset<= 1;								  						@(posedge clk);
		reset<= 0; switch_9 <= 0; read <= 0; write <= 0;   @(posedge clk); 
														 repeat(5)		@(posedge clk);
					  switch_9 <= 1; read <= 1; write <= 1;   @(posedge clk); 
														 repeat(20)		@(posedge clk);
		$stop;
	end
	
endmodule
