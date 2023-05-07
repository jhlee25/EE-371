// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded

// hour_counter module increase the hour by enable siganl upto 7
// Input: reset(1-ibt), clock clk(1-ibt), user input en(1-ibt)
// Output: current time which has range of 0-7(3-bit)

module hour_counter (reset, clk, en, curr_time);
	
	input logic reset, clk, en;
	output logic [2:0] curr_time;
	
	always_ff @ (posedge clk) begin
	
		if (reset) begin
			curr_time <= 0;
		end
		
		else if (en) begin
			curr_time <= (curr_time + 1);
		end
		
	end

endmodule



module hour_counter_testbench ();	
			
	logic reset, clk, en;
	logic [2:0] curr_time;
	
	hour_counter dut (.*);
	
	//clock setup
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		forever #(clock_period /2) clk <= ~clk;		
	end //initial
	
	integer i;
	initial begin
	
		reset <= 1;					@(posedge clk);	
		reset <= 0;					@(posedge clk);
		
		en <=1;
		for (i=1; i<=2**5; i++) begin
			@(posedge clk);
		end
										@(posedge clk);
										@(posedge clk);
	
		$stop; //end simulation	
							
	end //initial
	
endmodule	