// Junhyoung Lee & Sangmin Lee
// 01/24/2022
// EE 371
// Lab #2 Task #3
// This program uses dual port memory to implement FIFO design with circular queue

// This module control the FIFO with circulat queue implementation

module FIFO_Control #(
							 parameter depth = 4
							 )(
								input logic clk, reset,								// 1-bit input clk and reset
								input logic read, write,							// 1-bit input read and write
								output logic wr_en,									// 1-bit output write enable
								output logic empty, full,							// 1-bit output empty and full
								output logic [depth-1:0] readAddr, writeAddr // 4-bit output address for read & write
							  );
	
	/* 	Define_Variables_Here		*/
	logic [depth-1:0] read_ptr;			// 4-bit read pointer that indicates where the read pointer is
	logic [depth-1:0] write_ptr;			// 4-bit write pointer that indicates where the write pointer is
	
	enum {S0, S1, S2} ps, ns;
	
	/*		Combinational_Logic_Here	*/
	always_comb begin
		
		case(ps)
		
			// Initial state "Empty"
			S0: begin
					 if (write)														ns = S1;
					 else 															ns = S0;
				 end
			
			// "Neither" state
			S1: begin
					 // when write is enable and read_ptr is one position ahead to write_ptr
					 // this is the condition to move to Full state
					 if (write && ((write_ptr+1'b1)==read_ptr))			ns = S2;
					 
					 // when read is enable and write_ptr is one position ahead to read_ptr
					 // this is the condition to move to Empty state
					 else if (read && ((read_ptr+1'b1)==write_ptr))		ns = S0;
					 
					 else																ns = S1;
				 end
			
			// "Full" state
			S2: begin
					 if (read)														ns = S1;
					 else																ns = S2;
				 end
		
		endcase
		
	end
			
	/*		Sequential_Logic_Here		*/	
	always_ff @(posedge clk) begin
		if(reset) begin

			wr_en <= 1'b0;
			empty <= 1'b1; 
			full <= 1'b0; 
			
			readAddr <= '0;
			writeAddr <= '0;
			read_ptr <= '0;
			write_ptr <= '0;
			
		end else begin
			
			// dont't forget present state is next state unless reset!!!
			ps <= ns;
			
			// when read or write is enable, the pointer and address increments by 1
			if (read)
				read_ptr <= read_ptr + 1;
				readAddr <= read_ptr;
				
			if (write)
				write_ptr <= write_ptr + 1;
				writeAddr <= write_ptr;
			
			// according to present state, the empty and full are changed
			if (ps==S0)
				empty <= 1'b1;
			if (ps!=S0)
				empty <= 1'b0;
			
			if (ps==S2)
				full <= 1'b1;
			if (ps!=S2)
				full <= 1'b0;
			
			
			// when it is not full wr_en is enabled, when it is full wr_en is not enabled
			if ((ps!=S2) && write)
				wr_en <= 1'b1;
				
			if (ps==S2 || ~(write))
				wr_en <= 1'b0;
			
		end
	end

endmodule 


`timescale 1 ps / 1 ps
module FIFO_Control_testbench();

	parameter depth = 2;		// set depth as 2 for simulation purpose
	
	logic clk, reset;
	logic read, write;
	logic wr_en;
	logic empty, full;
	logic [depth-1:0] readAddr, writeAddr;
	
	FIFO_Control #(depth) dut (.clk, .reset, .read, .write, .wr_en, .empty, .full, .readAddr, .writeAddr);
	
	parameter CLK_Period = 100;
	
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period/2) clk <= ~clk;
	end
	
	initial begin
		
		reset <= 1;					  								   @(posedge clk);
		reset <= 0; write <= 0; read <= 0; 						@(posedge clk);
																			@(posedge clk);
																			@(posedge clk);
																			@(posedge clk);
						write <= 1; read <= 0; repeat (5) 		@(posedge clk); // Queue is Full
						write <= 0; read <= 0; repeat (2)		@(posedge clk);
																		   @(posedge clk);
																		   @(posedge clk);
																		   @(posedge clk);
						write <= 0; read <= 1; repeat (5) 		@(posedge clk); // Queue is Empty
						write <= 0; read <= 0; repeat (2) 		@(posedge clk);
																		   @(posedge clk);
																		   @(posedge clk);
																		   @(posedge clk);

															
		$stop; //end simulation	
	
	end
	
endmodule	

