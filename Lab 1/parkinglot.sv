// Junhyoung Lee & Sangmin Lee
// 01/13/2022
// EE 371
// Lab #1
// This program shows number of cars in the parkinglot with photosensors that detects activity of a car

// parkinglot module detect the activity of a car by photosensors

module parkinglot (clk, reset, a, b, enter, exit);

	input logic clk, reset;			// given input: 1-bit clk from CLOCK_50, 1-bit reset from user
	input logic a, b;					// given input: 1-bit a and b from user input by SW 1 and SW 0
	output logic enter, exit;		// output: 1-bit enter and exit represents activity of a car
	
	enum {S0, S1, S2, S3} ps, ns;	// 2-bit of present state and next state
	
	// next state logic
	always_comb begin
		
		case (ps)
			
			// S0: initial state "00" as a and b
			S0:	if (a)				ns = S1;
					else if (b) 		ns = S3;
					else					ns = S0;
			
			// S1: a state "10" as a and b
			S1:	if (b)				ns = S2;
					else if (~a)		ns = S0;
					else					ns = S1;

			// S2: a state "11" as a and b
			S2:	if (~a)				ns = S3;
					else if (~b)		ns = S1;
					else					ns = S2;
					
			// S3: a state "01" as a and b
			S3:	if (~b)				ns = S0;
					else if (a)			ns = S2;
					else					ns = S3;
		
		endcase
	
	end
	
	assign enter = (ps==S3) & (ns==S0);
	assign exit = (ps==S1) & (ns==S0);
	
	always_ff @(posedge clk) begin
	
		if (reset)
			ps <= S0;
		else
			ps <= ns;
	
	end
	
endmodule


module parkinglot_testbench ();

	logic clk, reset;			// given input: 1-bit clk from divided clock, 1-bit reset from user
	logic a, b;					// given input: 1-bit a and b from user input by SW 1 and SW 0
	logic enter, exit;		// output: 1-bit enter and exit represents activity of a car
	
	parkinglot dut (.clk(clk), .reset(reset), .a(a), .b(b), .enter(enter), .exit(exit));

	//clock setup
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		// every 50 period, the most divided clock is high and low
		forever #(clock_period /2) clk <= ~clk;		
	end //initial
	
	initial begin
	
		reset <= 1;									@(posedge clk);
		reset <= 0;	a<=0;	b<=0;					@(posedge clk);	// entering
						a<=1;							@(posedge clk);
								b<=1;					@(posedge clk);
						a<=0;							@(posedge clk);
								b<=0;					@(posedge clk);	// enter = 1
								
								b<=1;					@(posedge clk);	// exiting
						a<=1;							@(posedge clk);
								b<=0;					@(posedge clk);
						a<=0;							@(posedge clk);	// exit = 1
														@(posedge clk);

		$stop; //end simulation	
							
	end //initial

endmodule	
	
	
