// Junhyoung Lee & Sangmin Lee
// 01/13/2022
// EE 371
// Lab #1
// This program shows number of cars in the parkinglot with photosensors that detects activity of a car

// counter module is designed to count number upto 25

module counter #(parameter width = 5) (out, inc, dec, reset, clk);

	output logic [width-1:0] out;			// output: 5-bit out representing binary value increases or decreases by 1
	input logic inc, dec;					// given input: 1-bit increment for counter, 1-bit decrement for counter
	input logic reset, clk;					// given input: 1-bit reset from user, 1-bit clk from CLOCK_50
	
	// sequential logic (DFFs)
	always_ff @(posedge clk) begin
			
		if (reset)
			out <= 5'b0;
		else if (inc & (out < 5'd25))
			out <= out + 5'b1;
		else if (dec & (out > 5'b0))
			out <= out - 5'b1;
				
	end

endmodule


module counter_testbench ();

	parameter width = 5;
	logic [width-1:0] out;				// output: 5-bit out representing binary value increases or decreases by 1
	logic inc, dec;						// given input: 1-bit increment for counter, 1-bit decrement for counter
	logic reset, clk;						// given input: 1-bit reset from user, 1-bit clk from CLOCK_50
	
	counter dut (.out(out), .inc(inc), .dec(dec), .reset(reset), .clk(clk));
	
	//clock setup
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		// every 50 period, the most divided clock is high and low
		forever #(clock_period /2) clk <= ~clk;		
	end //initial
	
	integer i;
	initial begin
	
		reset <= 1;					@(posedge clk);	
		reset <= 0;					@(posedge clk);
		
		inc <=1;
		for (i=1; i<=26; i++) begin
			@(posedge clk);
		end
		
		inc<=0;	dec<=1;
		for (i=1; i<=26; i++) begin
			@(posedge clk);
		end
										@(posedge clk);
										@(posedge clk);
	
		$stop; //end simulation	
							
	end //initial
	
endmodule	