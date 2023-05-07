// Junhyoung Lee & Sangmin Lee
// 01/13/2022
// EE 371
// Lab #1
// This program shows number of cars in the parkinglot with photosensors that detects activity of a car

// seg7 module translates a givn 4 bits input to a number related to the 7 segments HEXs

module seg7 (bcd, leds);
	
	input logic [3:0] bcd;				// given 4 bits input
	output logic [6:0] leds;			// 7-bit leds representing number 0 to 9

	always_comb begin
		
		case(bcd)	
			
				4'b0000: leds = 7'b1000000;	// 0
				4'b0001: leds = 7'b1111001;	// 1
				4'b0010: leds = 7'b0100100;	// 2
				4'b0011: leds = 7'b0110000;	// 3
				4'b0100: leds = 7'b0011001;	// 4
				4'b0101: leds = 7'b0010010;	// 5
				4'b0110: leds = 7'b0000010;	// 6
				4'b0111: leds = 7'b1111000;	// 7
				4'b1000: leds = 7'b0000000;	// 8
				4'b1001: leds = 7'b0010000;	// 9
				default: leds = 7'bx;
			
		endcase
	
	end

endmodule


module seg7_testbench ();
	
	logic [3:0] bcd;				// given 4 bits input
	logic [6:0] leds;				// 7-bit leds representing number 0 to 9
	
	seg7 dut (.bcd(bcd), .leds(leds));
	
	integer i;
	initial begin
		
		for (i=0; i<10; i++) begin
			
			bcd = i; #10;
			
		end
	
	end
	
endmodule	