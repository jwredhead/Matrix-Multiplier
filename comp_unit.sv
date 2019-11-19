/******************************************************************************** 
  File:         	comp_unit.sv
  Description:  
  Board:          DE2-115 
  Date:           November 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
module comp_unit(clk, reset,  mult_en, add_en, out_en, Ain, Bin, Cout, Aout, Bout, overflow);
	
	// Inputs
	input logic clk, reset, mult_en, add_en, out_en;
	input logic [31:0] Ain, Bin;
	
	// Outputs
	output logic overflow;
	output logic [31:0] Cout, Aout, Bout;
	
	// Internal Clock Signal
	logic  m_overflow, a_overflow;
	logic [31:0] multout,  Cin;
	
	// Multiply inputs
	FP_Mult mult(mult_en, clk, Ain, Bin, m_overflow, multout);
	
	// Add Result to C register value
	FP_Adder adder(add_en, clk, multout, Cout, a_overflow, Cin);
	
	// Output Registers
	register #(32) A(clk, reset, out_en, Ain, Aout);
	register #(32) B(clk, reset, out_en, Bin, Bout);
	register #(32) C(clk, reset, out_en, Cin, Cout);
	
	// Outputs
	assign overflow = m_overflow | a_overflow;

endmodule