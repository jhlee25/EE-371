// Junhyoung Lee & Sangmin Lee
// 03/12/2022
// EE 371
// Lab #6 Task #2
// This program simulate the 3D parkinglot with rush hour and number of cars recorded 

// seg7 module displays all the given data to the HEX display in hexadecimal
// Input: reset(1-bit), number of cars entered at each time(4-bit), current time of the day(3-bit),
//			 ram address(3-bit), start of rush hour(3-bit), end of rush hour(3-bit),
//			 current parking lot status curr_occup(2-bit), the end of 8th hour end_rush_hour(1-bit), 
//			 if there was no rush at all no_rush(1-bit)
// Output: (7-bit) HEX displays

module seg7 (
	
	input logic reset,
	input logic [3:0] num_cars,
	input logic [2:0] hour, 
	input logic [2:0] ram_addr,
	input logic [2:0] start_h, 
	input logic [2:0] end_h,
	input logic [1:0] curr_occup,
	input logic end_rush_hour,
	input logic no_rush,

	output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	);
	
	logic [6:0] nc; 		// num_cars
	logic [6:0] tod; 		// time of day
	logic [6:0] ra; 		// ram address
	logic [6:0] st; 		// start time
	logic [6:0] et; 		// end time
	logic [6:0] nos; 		// number of spots 
	
	// num_cars
	always_comb begin 
		case (num_cars)
			//        Light: 6543210 
			4'b0000: nc = 7'b1000000; // 0
			4'b0001: nc = 7'b1111001; // 1  
			4'b0010: nc = 7'b0100100; // 2  
			4'b0011: nc = 7'b0110000; // 3  
			4'b0100: nc = 7'b0011001; // 4 
			4'b0101: nc = 7'b0010010; // 5  
			4'b0110: nc = 7'b0000010; // 6  
			4'b0111: nc = 7'b1111000; // 7 
			4'b1000: nc = 7'b0000000; // 8	
			4'b1001: nc = 7'b0011000; // 9
			4'b1010: nc = 7'b0001000; // A
			4'b1011: nc = 7'b0000011; // B
			4'b1100: nc = 7'b1000110; // C
			4'b1101: nc = 7'b0100001; // D
			4'b1110: nc = 7'b0000110; // E	
			4'b1111: nc = 7'b0001110; // F				
			default: nc = 7'b1111111;   
		endcase  
	end
	
	// time of day
	always_comb begin
		case (hour)
			//        Light: 6543210 
			3'b000: tod = 7'b1000000; // 0
			3'b001: tod = 7'b1111001; // 1  
			3'b010: tod = 7'b0100100; // 2  
			3'b011: tod = 7'b0110000; // 3  
			3'b100: tod = 7'b0011001; // 4 
			3'b101: tod = 7'b0010010; // 5  
			3'b110: tod = 7'b0000010; // 6  
			3'b111: tod = 7'b1111000; // 7 	
			default: tod = 7'b1111111;   
		endcase  
	end
	
	// ram address
	always_comb begin
		case (ram_addr)
			//       Light: 6543210 
			3'b000: ra = 7'b1000000; // 0
			3'b001: ra = 7'b1111001; // 1  
			3'b010: ra = 7'b0100100; // 2  
			3'b011: ra = 7'b0110000; // 3  
			3'b100: ra = 7'b0011001; // 4 
			3'b101: ra = 7'b0010010; // 5  
			3'b110: ra = 7'b0000010; // 6  
			3'b111: ra = 7'b1111000; // 7 	
			default: ra = 7'b1111111;   
		endcase  
	end
	
	// start time
	always_comb begin 
		case (start_h)
			//       Light: 6543210 
			3'b000: st = 7'b1000000; // 0
			3'b001: st = 7'b1111001; // 1  
			3'b010: st = 7'b0100100; // 2  
			3'b011: st = 7'b0110000; // 3  
			3'b100: st = 7'b0011001; // 4 
			3'b101: st = 7'b0010010; // 5  
			3'b110: st = 7'b0000010; // 6  
			3'b111: st = 7'b1111000; // 7 	
			default: st = 7'b1111111;   
		endcase  
	end
	
	// end time
	always_comb begin 
		case (end_h)
			//          Light: 6543210 
			3'b000: et = 7'b1000000; // 0
			3'b001: et = 7'b1111001; // 1  
			3'b010: et = 7'b0100100; // 2  
			3'b011: et = 7'b0110000; // 3  
			3'b100: et = 7'b0011001; // 4 
			3'b101: et = 7'b0010010; // 5  
			3'b110: et = 7'b0000010; // 6  
			3'b111: et = 7'b1111000; // 7 	
			default: et = 7'b1111111;   
		endcase  
	end	
	
	// number of spots left
	always_comb begin 
		case (curr_occup)
			//       Light: 6543210 
			2'b00: nos = 7'b0110000; // 3 
			2'b01: nos = 7'b0100100; // 2  
			2'b10: nos = 7'b1111001; // 1  
			2'b11: nos = 7'b1000000; // 0 
			default: nos = 7'b1111111;   
		endcase  
	end
	
	// HEXs display
	always_comb begin
		
		if (!end_rush_hour) begin 			// during the rush hour
			
			if (curr_occup==2'd3) begin   // when the parkinglot is full
				HEX5 = tod; 					// time of day
				HEX4 = 7'b1111111;
				HEX3 = 7'b0001110; // F
				HEX2 = 7'b1000001; // U
				HEX1 = 7'b1000111; // L
				HEX0 = 7'b1000111; // L
			end
			
			else begin	
				HEX5 = tod; 					// time of day
				HEX4 = 7'b1111111;
				HEX3 = 7'b1111111;
				HEX2 = 7'b1111111;
				HEX1 = 7'b1111111;
				HEX0 = nos; 					// number of spots left
			end
		
		end
			
		else begin								// the rush hour is over
			
			if (no_rush) begin				// no rush hour at all
				HEX5 = 7'b1111111;
				HEX4 = 7'b1111110;			// dash
				HEX3 = 7'b1111110;			// dash
				HEX2 = ra;						// ram address
				HEX1 = nc;						// num_cars
				HEX0 = 7'b1111111;
			end
			
			else begin							// if there as a rush hour
				HEX5 = 7'b1111111;
				HEX4 = et;						// end time
				HEX3 = st;						// start time
				HEX2 = ra;						// ram address
				HEX1 = nc;						// num_cars
				HEX0 = 7'b1111111;
			end
			
		end
	
	end

endmodule	



module seg7_testbench();

	logic reset;
	logic [3:0] num_cars;
	logic [2:0] hour;
	logic [2:0] ram_addr;
	logic [2:0] start_h, end_h;
	logic [1:0] curr_occup;
	logic end_rush_hour;
	logic no_rush;

	logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

	seg7 dut (.*);
	
	integer i;
	
	initial begin 
		end_rush_hour = 0;
		for(i=0; i<2**3; i++) begin
			{hour} = i; {curr_occup} = i; {num_cars} = i; {ram_addr} = i; {start_h} = i; {end_h} = i ;#10;
		end // end for loop
		
		end_rush_hour = 1;
		for(i=0; i<2**3; i++) begin
			{hour} = i; {curr_occup} = i; {num_cars} = i; {ram_addr} = i; {start_h} = i; {end_h} = i ;#10;
		end // end for loop
	end

endmodule	