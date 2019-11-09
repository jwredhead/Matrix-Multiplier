/******************************************************************************** 
  File:           register_tb.sv
  Description:    
  Board:          DE2-115 
  Date:           September 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
`timescale 1ns/1ps // time scale
module register_tb();

	// Wires for Inputs
	logic clk, reset, load_en;
	logic [15:0] D;
	
	// Wires for Outputs
	logic [15:0] Q, Q_expected;
	
	// Test Vectors
	logic [15:0] vectornum, errors;
   logic [34:0] testvectors[100:0];
   
   // instantiate device under test
   register dut(clk, reset, load_en, D, Q);
	
   // Generate clock 
   always
     begin
       clk = 0; #20; clk = 1; #20;
     end
	  
   // at start of test, load vectors
  initial
   begin
      $readmemb("register.tv", testvectors);
      vectornum = 0; errors = 0;
   end
	
// apply test vectors on rising edge of clk
   always @(negedge clk)
     begin
       // wait for 1 time unit before assignment
       #18; {reset,load_en,D,Q_expected} = testvectors[vectornum];
     end

   // check results on falling edge of clk
   always @(posedge clk)
    begin
       if (Q !== Q_expected) begin
         $display("Error: inputs = %b, %b, $d, ", reset, load_en, D);
         $display(" outputs = %d (%d expected)",
                Q, Q_expected);
         errors = errors + 1;
       end
       vectornum = vectornum + 1;
       if (testvectors[vectornum] === 'bx) begin
          $display("%d tests completed with %d errors", vectornum, errors);
          $finish;
       end
    end
endmodule