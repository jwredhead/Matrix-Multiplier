/******************************************************************************** 
  File:           register.sv
  Description:    This module implements a basic flip-flop register with load 
						enable and reset signals. When load_en and clk are high and reset 
						is low value of D is stored in the register and output on Q. When 
						reset and clk are high the register is reset back to 0.
  Board:          DE2-115 
  Date:           September 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
module register
	# (parameter width = 16)
	(input logic clk, reset, load_en,
		input logic [width-1:0] D,
		output logic [width-1:0] Q);
		
		always_ff @(posedge clk)
			if (reset) Q = 0;
			else if (load_en) Q = D;
endmodule
