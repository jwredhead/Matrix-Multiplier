/******************************************************************************** 
  File:         	matrix_mult_datapath.sv
  Description:  
  Board:          DE2-115 
  Date:           November 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
module systolic_array(clk, reset, mult_en, add_en, out_en, A1, A2, A3, A4, B1, B2, B3, B4,
								C11, C12, C13, C14, C21, C22, C23, C24, C31, C32, C33, C34, C41, C42, C43, C44, overflow);
			
		input logic clk, reset, mult_en, add_en, out_en;
		input logic [31:0] A1, A2, A3, A4, B1, B2, B3, B4;
		
		output logic overflow;
		output logic [31:0] C11, C12, C13, C14, C21, C22, C23, C24, C31, C32, C33, C34, C41, C42, C43, C44;

		logic [15:0] internal_overflow;
		logic [31:0] C11_Aout, C11_Bout, C12_Aout, C12_Bout, C13_Aout, C13_Bout, C14_Aout, C14_Bout;
		logic [31:0] C21_Aout, C21_Bout, C22_Aout, C22_Bout, C23_Aout, C23_Bout, C24_Aout, C24_Bout;
		logic [31:0] C31_Aout, C31_Bout, C32_Aout, C32_Bout, C33_Aout, C33_Bout, C34_Aout, C34_Bout;
		logic [31:0] C41_Aout, C41_Bout, C42_Aout, C42_Bout, C43_Aout, C43_Bout, C44_Aout, C44_Bout;
		
		// If any compute unit overflow, set the overflow flag
		assign overflow = (internal_overflow > 16'd0);
			
		// Systolic Array
		comp_unit CELL_C11(clk, reset, mult_en, add_en, out_en, A1, 		B1, 			C11,	C11_Aout,	C11_Bout, internal_overflow[0]);
		comp_unit CELL_C12(clk, reset, mult_en, add_en, out_en, C11_Aout,	B2, 			C12,  C12_Aout,	C12_Bout, internal_overflow[1]);
		comp_unit CELL_C13(clk, reset, mult_en, add_en, out_en, C12_Aout,	B3, 			C13,	C13_Aout,	C13_Bout, internal_overflow[2]);
		comp_unit CELL_C14(clk, reset, mult_en, add_en, out_en, C13_Aout,	B4, 			C14,	C14_Aout,	C14_Bout, internal_overflow[3]);
		comp_unit CELL_C21(clk, reset, mult_en, add_en, out_en, A2, 		C11_Bout,	C21, 	C21_Aout, 	C21_Bout, internal_overflow[4]);
		comp_unit CELL_C22(clk, reset, mult_en, add_en, out_en, C21_Aout, C12_Bout,	C22, 	C22_Aout, 	C22_Bout, internal_overflow[5]);
		comp_unit CELL_C23(clk, reset, mult_en, add_en, out_en, C22_Aout, C13_Bout,	C23, 	C23_Aout, 	C23_Bout, internal_overflow[6]);
		comp_unit CELL_C24(clk, reset, mult_en, add_en, out_en, C23_Aout, C14_Bout,	C24, 	C24_Aout, 	C24_Bout, internal_overflow[7]);
		comp_unit CELL_C31(clk, reset, mult_en, add_en, out_en, A3, 		C21_Bout,	C31, 	C31_Aout, 	C31_Bout, internal_overflow[8]);
		comp_unit CELL_C32(clk, reset, mult_en, add_en, out_en, C31_Aout, C22_Bout,	C32, 	C32_Aout, 	C32_Bout, internal_overflow[9]);
		comp_unit CELL_C33(clk, reset, mult_en, add_en, out_en, C32_Aout, C23_Bout,	C33, 	C33_Aout, 	C33_Bout, internal_overflow[10]);
		comp_unit CELL_C34(clk, reset, mult_en, add_en, out_en, C33_Aout, C24_Bout,	C34,	C34_Aout, 	C34_Bout, internal_overflow[11]);
		comp_unit CELL_C41(clk, reset, mult_en, add_en, out_en, A4, 		C31_Bout,	C41, 	C41_Aout, 	C41_Bout, internal_overflow[12]);
		comp_unit CELL_C42(clk, reset, mult_en, add_en, out_en, C41_Aout, C32_Bout,	C42, 	C42_Aout, 	C42_Bout, internal_overflow[13]);
		comp_unit CELL_C43(clk, reset, mult_en, add_en, out_en, C42_Aout, C33_Bout,	C43, 	C43_Aout, 	C43_Bout, internal_overflow[14]);
		comp_unit CELL_C44(clk, reset, mult_en, add_en, out_en, C43_Aout, C34_Bout,	C44,	C44_Aout, 	C44_Bout, internal_overflow[15]);
		
		
endmodule