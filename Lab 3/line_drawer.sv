// Junhyoung Lee & Sangmin Lee
// 02/04/2022
// EE 371
// Lab #3 Task #2
// This program displays images from an FPGA using DE1_SoC VGA video-out port

// This module recieved two points and gives the output to draw one pixel at each clock cycle
// Input: given clock and reset (1-bit), two points represented as x0, y0 and x1, y1 (10-bit for x, 9-bit for y)
// Output: Pixels being drawn by this module x and y (10-bit for x, 9-bit for y)

module line_drawer(
	input logic clk, reset,
	
	// x and y coordinates for the start and end points of the line
	input logic [9:0] x0, x1, 
	input logic [8:0] y0, y1,

	//outputs cooresponding to the coordinate pair (x, y)
	output logic [9:0] x,
	output logic [8:0] y
	);
	
	/*
	 * You'll need to create some registers to keep track of things
	 * such as error and direction
	 * Example: */
	logic is_steep;								// 1-bit boolean logic for is_steep
	logic [9:0] x_00, x_01, x_10, x_11;		// 11-bit first temporary x and y (used for is_steep)
	logic [8:0] y_00, y_01, y_10, y_11;		// 11-bit second temporary x and y (used for x0 > x1)
	
	logic signed [11:0] error;					// 12-bit error that handle the rounding issue of y
	logic signed [8:0] y_step;					// 3-bit y step which is decided by y0 and y1
	
	logic signed [9:0] delta_x;				// 10-bit delta x value
	logic signed [8:0] delta_y;				// 9-bit delta y value
	
	logic signed [9:0] x_;						// 10-bit temporary output x value
	logic signed [8:0] y_;						// 9-bit temporary output y value
	
	// absolute value of delta x and y
	logic [9:0]abs_x;								// 10-bit absolute value of x1-x0
	logic [8:0] abs_y;							// 9-bit absolute value of y1-y0
	
	// absolute change in x and y
	assign abs_x = (x1 > x0) ? (x1 - x0) : (x0 - x1);
	assign abs_y = (y1 > y0) ? (y1 - y0) : (y0 - y1);
	
	// assigns steep high or low depending on if the change in x or y is greater
	assign is_steep = (abs_y > abs_x);
	
	// is_steep and x0 > x1 cases
	always_comb begin
		
		// if steep cases
		if (is_steep) begin
			x_00 = y0;
			y_00 = x0;
			x_10 = y1;
			y_10 = x1;
		end	else	begin
			x_00 = x0;
			y_00 = y0;
			x_10 = x1;
			y_10 = y1;
		end
		
		// x0 > x1 cases
		if (x0 > x1) begin
			x_01 = x_10;
			y_01 = y_10;
			x_11 = x_00;
			y_11 = y_00;
		end	else	begin
			x_01 = x_00;
			y_01 = y_00;
			x_11 = x_10;
			y_11 = y_10;
		end
			
	end
	
	// delta_x and delta_y
	assign delta_x = x_11 - x_01;
	assign delta_y = abs_y;
	
	// if y0 < y1 cases
	always_comb begin
		if (y_01 < y_11)	y_step = 1;
		else 					y_step = -1;
	end
	
	// assign error 
	logic signed [11:0] error_0;
	assign error_0 = error + delta_y;
	
	
	logic loop;
	assign loop = ((x_ <= x_11)  || ((y_ <= (y_11)) && (y_step == 1)) || ((y_ >= (y_11)) && (y_step == -1))); // work on this

	always_ff @ (posedge clk) begin
		
		// initialization before looping
		if (reset) begin
			x_ <= x_01;
			y_ <= y_01;
			error <= -(delta_x/2);
		end
		
		// loops until both x and y are finished
		else if (loop) begin
			
			// if is_steep, swap the x and y
			if (is_steep) begin
				x <= y_;
				y <= x_;
			end
			else begin
				x <= x_;
				y <= y_;
			end
			
			// for the loop purpose
			if(x_ < (x_11)) begin
				x_ <= (x_ + 1);
			end 
			
			if(((y_ < (y_11)) && (y_step == 1)) || ((y_ > (y_11)) && (y_step == -1))) begin
				
				if (error_0 >= 0) begin
				
					y_ <= y_ + y_step;
					error <= error_0 - delta_x;
					
				end else
				
					error <= error_0;
					
			end
			
		end
		
		// once line is done drawing set x and y to 0
		else begin
				x <= 10'd0;
				y <= 9'd0;
		end 
		
	end 
     
endmodule



// testbench of the module line_drawer
module line_drawer_testbench ();

	logic clk, reset;
	logic [9:0] x0, x1;
	logic [8:0] y0, y1;
	
	logic [9:0] x;
	logic [8:0] y ;
  
	line_drawer dut (.*);
  
	parameter CLK_Period = 100;
	initial begin
		clk <= 1'b0;
		forever #(CLK_Period/2) clk <= ~clk;
	end

	initial begin
	
			reset <= 1; x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd3;  y1 <= 9'd5; @(posedge clk); // diagonal steep upwards
			reset <= 0; @(posedge clk); 
			repeat(10)  @(posedge clk);
			
			reset <= 1; x0 <= 10'd5; y0 <= 9'd5; x1 <= 10'd10;  y1 <= 9'd5; @(posedge clk); // straight horizontal line
			reset <= 0; @(posedge clk); 
			repeat(10)  @(posedge clk);
			
			reset <= 1; x0 <= 10'd1; y0 <= 9'd1; x1 <= 10'd5;  y1 <= 9'd3; @(posedge clk); // diagonal non steep upwards
			reset <= 0; @(posedge clk); 			
			repeat(10)  @(posedge clk);

			reset <= 1; x0 <= 10'd5; y0 <= 9'd5; x1 <= 10'd5;  y1 <= 9'd10; @(posedge clk); // straight vertical line
			reset <= 0; @(posedge clk); 
			repeat(10)  @(posedge clk);
			
			reset <= 1; x0 <= 10'd5; y0 <= 9'd5; x1 <= 10'd10;  y1 <= 9'd3; @(posedge clk); // diagonal non steep downwards
			reset <= 0; @(posedge clk); 
			repeat(10)  @(posedge clk);

			reset <= 1; x0 <= 10'd1; y0 <= 9'd5; x1 <= 10'd2;  y1 <= 9'd1; @(posedge clk); // diagonal steep downwards
			reset <= 0; @(posedge clk); 
			repeat(10)  @(posedge clk);

			$stop;
			
	end

endmodule	