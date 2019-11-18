/******************************************************************************** 
  File:           comp_unit_tb.sv
  Description:  
  Board:          DE2-115 
  Date:           November 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
`timescale 1ns/1ps
module comp_unit_tb();
	// Input Wires
	logic clk, reset,  mult_en, add_en, out_en;
	logic [31:0] Ain, Bin; 
	
	// Output Wires
	logic[31:0] Cout, Aout, Bout;
	logic overflow;
	
	logic [5:0] testnum, errors;
	
	comp_unit comp(clk, reset,  mult_en, add_en, out_en, Ain, Bin, Cout, Aout, Bout, overflow);
	
	always 
	begin
		clk = 0; #20; clk = 1; #20;
	end
	
	always
	begin
		reset = 1'b1;
		mult_en = 1'b0;
		add_en = 1'b0;
		out_en = 1'b0;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
			
		#40;
		
		reset = 1'b0;
		mult_en = 1'b1;
		add_en = 1'b0;
		out_en = 1'b0;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
		
		#200;
		
		reset = 1'b0;
		mult_en = 1'b0;
		add_en = 1'b1;
		out_en = 1'b0;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
		
		#280;
		
		reset = 1'b0;
		mult_en = 1'b0;
		add_en = 1'b0;
		out_en = 1'b1;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
		
		#40;
		
		reset = 1'b0;
		mult_en = 1'b1;
		add_en = 1'b0;
		out_en = 1'b0;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
		
		#200;
		
		reset = 1'b0;
		mult_en = 1'b0;
		add_en = 1'b1;
		out_en = 1'b0;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
		
		#280;
		
		reset = 1'b0;
		mult_en = 1'b0;
		add_en = 1'b0;
		out_en = 1'b1;
		Ain = 32'h400ccccd;
		Bin = 32'h40533333;
		
		#40;
	end
	
endmodule
	
	