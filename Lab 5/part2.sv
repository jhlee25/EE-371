// Junhyoung Lee & Sangmin Lee
// 02/24/2022
// EE 371
// Lab #5 Task #2
// This program uses the audio CODEC on the DE1-SoC board to generate and filter
// noise from both an external source and an internal memory

// part2 module produces static tone from the memory and plays the tone when Switch 9 is ON
// and plays the input audio when Switch 9 is OFF
// Input: (1-bit) clock CLOCK_50 and CLOCK2_50, (4-bit) KEY, (10-bit) SW
//			 (1-bit) AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT for Audio CODEC
// Output: (1-bit) FPGA_I2C_SCLK, AUD_XCK, AUD_DACDAT for Audio CODEC
module part2 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT, SW);

	input  CLOCK_50, CLOCK2_50;
	input  [3:0] KEY;
	input  [9:0] SW;
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	// Logic to hold the toggle switch for audio
	reg switch_9;
	
	// glitch protection
	always @(posedge CLOCK_50) begin
		switch_9 <= SW[9]; 
	end
	
	wire [23:0] out;
	
	// if switch 9 is high, play task 2 audio (static tone from memory) otherwise play task 1
   assign writedata_left = switch_9 ? out : readdata_left;
   assign writedata_right = switch_9 ? out : readdata_right;
	
	// only read and write when both are ready
	assign read = read_ready & write_ready;
	assign write = write_ready & read_ready;
	
	rom_counter r (.clk(CLOCK_50), .*);	
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule	