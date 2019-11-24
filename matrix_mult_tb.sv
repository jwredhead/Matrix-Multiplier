`timescale 1ns/1ps
module matrix_mult_tb();

	// Wires for inputs
	logic clock, resetn, read, write;
	logic [1:0] address;
	logic [31:0] writedata;
	
	// Wires for outputs
	logic[31:0] readdata, readdata_exp;
	
	// Test Vectors
	logic [15:0] vectornum, errors;
   logic [68:0] testvectors[400:0];
	
	// Instantiate DUT
	matrix_mult dut(clock, resetn, address, writedata, readdata, write, read);
	
	   // Generate clock 
   always
   begin
		clock = 0; #20; clock = 1; #20;
   end
	
	initial 
	begin
		$readmemb("matrix_mult.tv", testvectors);
		vectornum = 0; errors = 0;
	end
	
	always @(negedge clock)
	begin	
		#1; {resetn, read, write, address, writedata, readdata_exp} = testvectors[vectornum];
	end
	
	always @(posedge clock)
	begin
		#10;
		if (readdata != readdata_exp) begin
			$display("Error: inputs: resetn = %b, read = %b, write = %b, address = %b, writedata = %h", 
						resetn, read, write, address, writedata);
			$display("outputs: = %h (%h expected)", readdata, readdata_exp);
			errors = errors + 1;
		end
		vectornum = vectornum + 1;
		if (testvectors[vectornum] == 'bx) begin
			$display("$d tests completed with $d errors", vectornum, errors);
			$finish;
		end
	end
endmodule
