// Junhyoung Lee & Sangmin Lee
// 02/04/2022
// EE 371
// Lab #3 Task #2
// This program displays images from an FPGA using DE1_SoC VGA video-out port

// DE1_SoC module communicates to the physical FPGA board
// Input: KEY(4-bit), SW(1-bit), CLOCK_50(1-bit)
// Output: 6 HEXs(7-bit), LEDR(10-bit), VGA_R, VGA_G, VGA_B(8-bit),
//			  VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS(1-bit)

module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;

	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign HEX0 = '1;
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	assign LEDR = SW;
	
	logic [9:0] x0, x1, x;
	logic [8:0] y0, y1, y;
	logic frame_start;
	logic pixel_color;
	
	// Generate clk off of CLOCK_50, whichClock picks rate.
	logic [31:0] clk;
	parameter whichClock = 20;
	clock_divider cdiv(CLOCK_50, clk);
	
	
	//////// DOUBLE_FRAME_BUFFER ////////
	logic dfb_en;
	assign dfb_en = 1'b0;
	/////////////////////////////////////
	
	VGA_framebuffer fb(.clk(CLOCK_50), .rst(1'b0), .x, .y,
				.pixel_color, .pixel_write(1'b1), .dfb_en, .frame_start,
				.VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
				.VGA_BLANK_N, .VGA_SYNC_N);
	
	// 4 states FSM: init, start, drawing, done
	enum {init, start, drawing, done} ps, ns;
	
	// (10-bit) tmp_x_start: temporary starting x coordinate
	// (10-bit) done_x: the destination coordinate for x
	// (10-bit) x_start: current x0
	// (10-bit) x_end: current x1
	logic [9:0] tmp_x_start, done_x, x_start, x_end;
	
	// (1-bit) reset fsm: reseting the animation
	// (1-bit) start_: starting the animation
	logic reset_fsm, start_;

	assign reset = SW[9];					// reseting the line_drawer
	assign reset_fsm = SW[8];
	assign start_ = SW[0];
	
	assign tmp_x_start = 10'd100;
	assign done_x = 10'd200;
	
	// assign y as 100, becuase it is not changing
	assign y0 = 100;
	assign y1 = 100;
	
	always_comb begin
	
		case(ps)
			
			// initial state
			init: if(start_) 						ns = start;
					else 								ns = init;
			
			// start drawing
			start: if((x_end == done_x + 1)) ns = done;
					 else 							ns = drawing;
			
			// draw one pixel at a time
			drawing: if((x_end == done_x)) 	ns = start;
						else 							ns = drawing;
			
			// stop drawing
			done: 									ns = done;
			
		endcase
		
	end
	
	always_ff @(posedge CLOCK_50) begin
		
		if(reset_fsm) begin		
			ps <= init;
			pixel_color <= 1'b0;			// color: black
			x0 <= 10'd0;					// for erasing purpose
			x1 <= 10'd600;
		end
		
		else begin
			ps <= ns;
			
			if(ps == init) begin
				pixel_color <= 1'b1;		// color: white
    			
				x_start <= tmp_x_start; 
    			x_end <= tmp_x_start; 
				
				x0 <= tmp_x_start;
				x1 <= tmp_x_start;
			end
			
			else if(ps == start) begin
				x0 <= x_start;
				x1 <= x_end + 1;
			end
			
			else if(ps == drawing) begin
				x_end <= x_end + 1;		// draw one pixel per one clock cycle
				x1 <= x_end;
			end
			
		end
		
	end
	
	// draw lines between (x0, y0) and (x1, y1)
	line_drawer lines (.clk(CLOCK_50), .reset(reset),
				.x0, .y0, .x1, .y1, .x, .y);
				
endmodule


//divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	
	input logic clock;
	output logic [31:0] divided_clocks = 32'b0;
	
	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
	
endmodule


module DE1_Soc_testbench();
	logic CLOCK_50;
   logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5; 
   logic [3:0] KEY; 
   logic [9:0] SW;
   logic [9:0] LEDR;
   logic [7:0] VGA_R;
   logic [7:0] VGA_G;
   logic [7:0] VGA_B;
   logic VGA_BLANK_N;
   logic VGA_CLK;
   logic VGA_HS;
   logic VGA_SYNC_N;
   logic VGA_VS;

   DE1_SoC dut (.*);

	// clock setup
	parameter CLOCK_PERIOD = 100;
	initial begin
		 CLOCK_50 <= 0;
		 forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end

	
   initial begin
	
		// first test: erase when it ends the drawing
		SW[9] <= 0; SW[8] <= 1; SW[0] <= 1;  	@(posedge CLOCK_50);
															@(posedge CLOCK_50);
		SW[9] <= 0; SW[8] <= 0; SW[0] <= 1; 	@(posedge CLOCK_50);
															@(posedge CLOCK_50);
		SW[9] <= 0; SW[8] <= 0; SW[0] <= 0; 	@(posedge CLOCK_50);
										repeat(125) 	@(posedge CLOCK_50);	// draw
		SW[9] <= 0; SW[8] <= 1; SW[0] <= 0;  	@(posedge CLOCK_50);	// erase	
															@(posedge CLOCK_50);
															@(posedge CLOCK_50);
															@(posedge CLOCK_50);
															@(posedge CLOCK_50);
		SW[9] <= 0; SW[8] <= 0; SW[0] <= 0;  	@(posedge CLOCK_50);	// erase		

		
		// second test: erase during the drawing			
		SW[9] <= 0; SW[8] <= 1; SW[0] <= 1;  	@(posedge CLOCK_50);
															@(posedge CLOCK_50);
		SW[9] <= 0; SW[8] <= 0; SW[0] <= 1; 	@(posedge CLOCK_50);
															@(posedge CLOCK_50);
		SW[9] <= 0; SW[8] <= 0; SW[0] <= 0; 	@(posedge CLOCK_50);
										repeat(60) 		@(posedge CLOCK_50);	// draw
		SW[9] <= 0; SW[8] <= 1; SW[0] <= 0;  	@(posedge CLOCK_50);	// erase	
															@(posedge CLOCK_50);
															@(posedge CLOCK_50);
															@(posedge CLOCK_50);
															@(posedge CLOCK_50);
		SW[9] <= 0; SW[8] <= 0; SW[0] <= 0;  	@(posedge CLOCK_50);	// erase			
		
      $stop;

    end
	 
endmodule
