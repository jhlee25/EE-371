// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded

// counter module increase the ram address by 1 in every clock cycle (divided clock)
// Input: reset(1-bit), divided clock clk(1-bit), increment signal incr(1-bit)
// Output: increasing ram address out (3-bit)

module counter (reset, clk, incr, out);

	input logic reset, clk, incr;
	output logic [2:0] out;	
	
	always_ff @ (posedge clk) begin
			
		if (reset)
			out <= 3'b0;
		else if (incr)
			out <= out + 3'b1;
				
	end

endmodule



module counter_testbench ();

	logic reset, clk, incr;
	logic [2:0] out;						
	
	counter dut (.*);
	
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
		
		incr <=1;
		for (i=1; i<=2**5; i++) begin
			@(posedge clk);
		end
										@(posedge clk);
										@(posedge clk);
	
		$stop; //end simulation	
							
	end //initial
	
endmodule	