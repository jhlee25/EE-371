// Junhyoung Lee & Sangmin Lee
// 01/13/2022
// EE 371
// Lab #1
// This program shows number of cars in the parkinglot with photosensors that detects activity of a car

// DE1_SoC module communicates to the physical FPGA board

module DE1_SoC #(parameter width = 5) (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, GPIO_0);
	
	input logic CLOCK_50; 												// 1-bit 50MHz clock
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// 6 HEXs of 7-bits
	output logic [9:0] LEDR;											// 10-bit LEDR
	// SW and KEY cannot be declared if GPIO_0 is declared on LabsLand
	inout logic [33:0] GPIO_0;
	
	logic a, b;										// 1-bit a and b that connected to GPIO_0
	logic exit, enter;							// 1-bit exit and enter ouput from pakringlot and input for counter
	logic [width-1:0] counter_out;			// 5-bit output from counter
	logic [3:0] digit0, digit1;				// 4-bit of each digit number of counter_out
	logic [6:0] digit0_led, digit1_led;		// 7-bit of each digit number of counter_out that will show up at HEX
	logic clk, reset;								// 1-bit clk for CLOCK_50, reset for GPIO_0
	
	assign reset = GPIO_0[9];
	assign clk = CLOCK_50;
	
	assign a = GPIO_0[5];
	assign b = GPIO_0[7];
	
	assign GPIO_0[26] = GPIO_0[5];			// GPIO_0[5] is connected to GPIO_0[26]
	assign GPIO_0[27] = GPIO_0[7];			// GPIO_0[7] is connected to GPIO_0[27]
		
	parkinglot act (.clk, .reset, .a, .b, .enter, .exit);
	
	counter COUNT (.out(counter_out), .inc(enter), .dec(exit), .reset, .clk);
	
	seg7 SEG7_0 (.bcd(digit0), .leds(digit0_led));
	seg7 SEG7_1 (.bcd(digit1), .leds(digit1_led));
	
	always_comb begin
	
		digit0 = counter_out % 4'd10;		// first digit (10th digit) of the output from counter
		digit1 = counter_out / 4'd10;		// second digit (1st digit) of the output from counter
		
		if (counter_out == 5'b0) begin
			HEX5 = 7'b1000110;	// C
			HEX4 = 7'b1000111;	// L
			HEX3 = 7'b0000110;	// E
			HEX2 = 7'b0001000;	// A
			HEX1 = 7'b0101111;	//	r
			HEX0 = digit0_led;	// 0
		end
		
		else if (counter_out < 5'd25) begin
			HEX5 = 7'b1111111;	
			HEX4 = 7'b1111111;	
			HEX3 = 7'b1111111;	
			HEX2 = 7'b1111111;	
			HEX1 = digit1_led;	
			HEX0 = digit0_led;	
		end
		
		else begin
			HEX5 = 7'b0001110;	// F
			HEX4 = 7'b1000001;	// U
			HEX3 = 7'b1000111;	// L
			HEX2 = 7'b1000111;	// L
			HEX1 = digit1_led;	
			HEX0 = digit0_led;
		end
	
	end
				
endmodule


module DE1_SoC_testbench ();

	logic CLOCK_50; 												// 1-bit 50MHz clock
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;	// 6 HEXs of 7-bits
	// SW and KEY cannot be declared if GPIO_0 is declared on LabsLand
	wire [33:0] GPIO_0;
	
	logic clk, reset;
	logic a, b;
	
	assign GPIO_0[9] = reset;
	assign GPIO_0[5] = a;
	assign GPIO_0[7] = b;

	DE1_SoC dut (.CLOCK_50(clk), .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .GPIO_0);
	
	//clock setup
	parameter clock_period = 100;
	initial begin
		clk <= 0;
		// every 50 period, the most divided clock is high and low
		forever #(clock_period /2) clk <= ~clk;
	end //initial
	
	integer i;
	initial begin
		
		reset <= 1;						@(posedge clk);
		reset <= 0;						@(posedge clk);
		
		a <= 1; b <= 1;				@(posedge clk);
		
		for (i=1; i<=26; i++) begin
			a <= 0;				@(posedge clk);
			b <= 0;				@(posedge clk);
			a <= 1;				@(posedge clk);
			b <= 1;				@(posedge clk);
		end
		
											@(posedge clk);
		
		$stop; //end simulation	
								
	end //initial
		
endmodule	