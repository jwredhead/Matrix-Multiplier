/******************************************************************************** 
  File:         	comp_unit.sv
  Description:  
  Board:          DE2-115 
  Date:           November 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
module comp_unit(clk, mult_en, add_en, out_en, Ain, Bin, Cout, Aout, Bout, overflow);
	
	// Inputs
	input logic clk, mult_en, add_en;
	input logic [31:0] Ain, Bin;
	
	// Outputs
	output logic overflow;
	output logic [31:0] Cout, Aout, Bout;
	
	// Internal Clock Signal
	logic  m_overflow, a_overflow, out_en;
	logic [31:0] multout;
	
	// Multiply inputs
	FP_Mult mult(mult_en, clk, Ain, Bin, m_overflow, multout);
	
	// Add Result to C register value
	FP_Adder adder(add_en, clk, multout, Cout, a_overflow, Cin);
	
	// Output Register
	register C(clk, reset, out_en, Cin, Cout);
	
	// Outputs
	assign overflow = m_overflow | a_overflow;
	assign Aout = Ain;
	assign Bout = Bin;

endmodule