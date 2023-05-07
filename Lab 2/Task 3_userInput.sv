// Junhyoung Lee & Sangmin Lee
// 01/24/2022
// EE 371
// Lab #2 Task #3
// This program uses dual port memory to implement FIFO design with circular queue

// This module to process user input that will treat long press as one press and insure stability

module userInput(clk, reset, in, out);
	input logic clk, reset, in;		// 1-bit clk, reset, and in
	output logic out;						// 1-bit output
	
	
	enum {S0, S1} ps, ns; // Present state, Next state
	
	// State logic of how key inputs should be handled 
	always_comb begin
		case (ps)
			// If input 1 then transisiton to state 1, else stay in state 0
			S0: if (in) ns = S1;
					else ns = S0;
			// If input 1 stay in state 1 otherwise transistion to state 0	
			S1: if (in) ns = S1;
					else ns = S0;
		endcase
	end
	
	// Only high on the intial change from state 0 to state 1
	// Corresponds to the intial press of the button
	assign out = (ps == S0) & in;
	
	//sequential logic (DFFs)
		always_ff @(posedge clk) begin
			if (reset)
				ps <= S0;
			else
				ps <= ns;
		end
		
endmodule

// userInput test bench, test long press of input and a short to verify the output
// is processed correctly
module userInput_testbench();

	logic clk, reset, in, out;
		
	userInput dut (.clk, .reset, .in, .out);
	
		//clock setup
		parameter clock_period = 100;
		
		initial begin
			clk <= 0;
			forever #(clock_period /2) clk <= ~clk;
					
		end //initial

		initial begin
		
			reset <= 1;         @(posedge clk);
			reset <= 0; in<=0;   @(posedge clk);
									  @(posedge clk);
			                    @(posedge clk);	
			                    @(posedge clk);	
			            in<=1;   @(posedge clk);	
							in<=1;   @(posedge clk);
			            in<=1;   @(posedge clk);	
							in<=1;   @(posedge clk);		
									  @(posedge clk);	
			                    @(posedge clk);	
			                    @(posedge clk);	
							in<=0;   @(posedge clk);	
									  @(posedge clk);	
									  @(posedge clk);
									  @(posedge clk); 
			            in<=1;   @(posedge clk);	
							in<=1;   @(posedge clk);
			            in<=1;   @(posedge clk);	
							in<=1;   @(posedge clk);	
									  @(posedge clk);
									  @(posedge clk);
							in<=0;   @(posedge clk);	
									  @(posedge clk);	
									  @(posedge clk);
									  @(posedge clk); 
			            in<=1;   @(posedge clk);
							in<=0;   @(posedge clk);	
									  @(posedge clk);
									  @(posedge clk); 	

			$stop; //end simulation							
							
		end //initial
endmodule

