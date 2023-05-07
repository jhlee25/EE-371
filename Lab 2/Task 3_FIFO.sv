// Junhyoung Lee & Sangmin Lee
// 01/24/2022
// EE 371
// Lab #2 Task #3
// This program uses dual port memory to implement FIFO design with circular queue

// This module is designed to have FIFO with read and write for circular queue

module FIFO #(
				  parameter depth = 4,		// number of the words in the module
				  parameter width = 8		// number of bits in a word
				  )(
					 input logic clk, reset,				// 1-bit input clk and reset
					 input logic read, write,				// 1-bit input read and write
					 input logic [width-1:0] inputBus,	// 8-bit input from user
					output logic empty, full,				// 1-bit output empty and full
					output logic [width-1:0] outputBus,	// 8-bit output for outputBus
					
					output logic [depth-1:0] read_Addr, // 4-bit output for read address
					output logic [depth-1:0] write_Addr // 4-bit output for write address
				   );
					
	/* 	Define_Variables_Here		*/
	logic [depth-1:0] rAddr;		// 4-bit output for read address
	logic [depth-1:0] wAddr;		// 4-bit output for write address
	
	assign read_Addr = rAddr;
	assign write_Addr = wAddr;
	
	/*			Instantiate_Your_Dual-Port_RAM_Here			*/
	ram16x8 RAM (.clock(clk),	.data(inputBus), .rdaddress(rAddr), .wraddress(wAddr), .wren, .q(outputBus));
	
	/*			FIFO-Control_Module			*/				
	FIFO_Control #(depth) FC (.clk, .reset, .read, .write, .wr_en(wren), .empty, .full, 
									  .readAddr(rAddr), .writeAddr(wAddr));
	
endmodule 


`timescale 1 ps / 1 ps
module FIFO_testbench();
	
	parameter depth = 4, width = 8;
	
	logic clk, reset;
	logic read, write;
	logic [width-1:0] inputBus;
	logic resetState;
	logic empty, full;
	logic [width-1:0] outputBus;
	logic [depth-1:0] read_Addr;
	logic [depth-1:0] write_Addr;
	
	FIFO #(depth, width) dut (.*);
	
	parameter CLK_Period = 100;
	
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period/2) clk <= ~clk;
	end
	
	initial begin 
		reset <= 1;								  										@(posedge clk);
		reset <= 0; write <= 0; read <= 0; inputBus <= 0;					@(posedge clk);
																							@(posedge clk);
																							@(posedge clk);
																							@(posedge clk);
						inputBus <= (inputBus + 1); write <= 1; read <= 0; @(posedge clk);
						write <= 0; read <= 0; 										@(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
						inputBus <= (inputBus + 1); write <= 1; read <= 0; @(posedge clk);
						write <= 0; read <= 0; 										@(posedge clk);						
																						   @(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
						inputBus <= (inputBus + 1); write <= 1; read <= 0; @(posedge clk);
						write <= 0; read <= 0; 										@(posedge clk);						
																						   @(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
						inputBus <= (inputBus + 1); write <= 1; read <= 0; @(posedge clk);
						write <= 0; read <= 0;									   @(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
						inputBus <= (inputBus + 1); write <= 1; read <= 0; @(posedge clk);
						write <= 0; read <= 0; 										@(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
																						   @(posedge clk);
						write <= 0; read <= 1; @(posedge clk); repeat (5)  @(posedge clk);
						write <= 0; read <= 0; repeat(2) 						@(posedge clk);
																							@(posedge clk);
																							@(posedge clk);
																							@(posedge clk);

		$stop; // end simulation
	end // initial
	
	
endmodule 