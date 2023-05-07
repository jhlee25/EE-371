// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded

// keypress module treats a long press on the user input as one press
// Input: clock clk(1-bit), reset(1-bit), user input in(1-bit)
// Output: output out that is treated as one press even long press(1-bit)

module keypress (clk, reset, in, out);

	input logic clk, reset, in;
	output logic out;
	
	// consider long press as one press
	enum {S0, S1} ps, ns;						// 1-bit of present state and next state
	
	// next state logic
	always_comb begin
		
		case (ps)
			
			// S0: initial state "off"
			S0:	if (in)		ns = S1;
					else			ns = S0;
			
			// S1: a state "on"
			S1:	if (in)		ns = S1;
					else			ns = S0;
		
		endcase
	
	end
	
	assign out = ((ps==S0) & in); 
	
	always_ff @(posedge clk) begin
	
		if (reset)
			ps <= S0;
		else
			ps <= ns;
	end
	
endmodule



module keypress_testbench ();

	logic clk, reset, in;
	logic out;
	
	keypress dut (.*);
	
	//clock setup
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		// every 50 period, the most divided clock is high and low
		forever #(clock_period /2) clk <= ~clk;		
	end //initial
		
	initial begin
	
		reset <= 1;						@(posedge clk);
		reset <= 0; in <= 0;			@(posedge clk);
											@(posedge clk);
											@(posedge clk);
						in <= 1;			@(posedge clk);
						in <= 1;			@(posedge clk);
						in <= 1;			@(posedge clk);
						in <= 1;			@(posedge clk);
											@(posedge clk);
											@(posedge clk);
						in <= 0;			@(posedge clk);
											@(posedge clk);
											@(posedge clk);
											@(posedge clk);
						in <= 1;			@(posedge clk);
						in <= 1;			@(posedge clk);
						in <= 1;			@(posedge clk);
						in <= 1;			@(posedge clk);
											@(posedge clk);
											@(posedge clk);
						in <= 0;			@(posedge clk);
											@(posedge clk);

										
		$stop; //end simulation							
							
		end //initial

endmodule	