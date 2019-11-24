/******************************************************************************** 
  File:         	matrix_mult.sv
  Description:  
  Board:          DE2-115 
  Date:           November 2019
  Author:         Justin Wilson, jkw0002@uah.edu
				
*********************************************************************************/
module matrix_mult(clock, resetn, address, writedata, readdata, write, read);

	// Signals for inputs
	input logic clock, resetn, write, read;
	input logic [1:0] address;
	input logic [31:0] writedata;
	
	// Signals for outputs
	output logic [31:0] readdata;
	
	// Internal Signals
	logic [31:0] Ctrl_Reg, In_Reg, Out_Reg;
	logic [31:0] A1, A2, A3, A4, B1, B2, B3, B4, Cout;
	logic [31:0] A1in, A2in, A3in, A4in, B1in, B2in, B3in, B4in, A1out, A2out, A3out, A4out, B1out, B2out, B3out, B4out;
	logic [7:0] fifo_sel, write_en, empty;
	logic A1full, A2full, A3full, A4full, B1full, B2full, B3full, B4full, clear;
	logic A1empty, A2empty, A3empty, A4empty, B1empty, B2empty, B3empty, B4empty;
	logic rdA1, rdA2, rdA3, rdA4, rdB1, rdB2, rdB3, rdB4;
	logic [31:0] C11, C12, C13, C14, C21, C22, C23, C24, C31, C32, C33, C34, C41, C42, C43, C44;
	logic start, mult_en, add_en, out_en, done, overflow;
	logic rdOUTFIFO;
	logic [3:0] count, usedw;
	
	// Only send read request to FIFO if read address is 2
	assign rdOUTFIFO = (address == 2'b10 & read) ? 1'b1 : 1'b0;
	
	// Assign read output by address value, can't read input register
	assign readdata = (address == 2'b00) ? Ctrl_Reg:
							(address == 2'b10) ? Out_Reg:
							2'd0;
	
	always_ff @(posedge clock or negedge resetn)
	begin
		if (~resetn)
		begin
			Ctrl_Reg[2:0] <= 3'd0;
			In_Reg <= 32'd0;
			write_en <= 8'd0;
		end
		// Write to register specified by address if not currently calculating
		else if (write & ~Ctrl_Reg[1])
			case (address)
				2'b00:	begin
							Ctrl_Reg[1:0] <= writedata[1:0];
							write_en <= 8'd0;
						end
				2'b01: 	begin
							In_Reg <= writedata;
							write_en[0] <= (write & address == 2'b01) & fifo_sel[0]; 
							write_en[1] <= (write & address == 2'b01) & fifo_sel[1];
							write_en[2] <= (write & address == 2'b01) & fifo_sel[2]; 	
							write_en[3] <= (write & address == 2'b01) & fifo_sel[3];
							write_en[4] <= (write & address == 2'b01) & fifo_sel[4];
							write_en[5] <= (write & address == 2'b01) & fifo_sel[5];
							write_en[6] <= (write & address == 2'b01) & fifo_sel[6];
							write_en[7] <= (write & address == 2'b01) & fifo_sel[7];
						end
				default: write_en <= 8'd0; 
			endcase
		// Set Done high when half data is in out FIFO
		else if (usedw[3]) begin
			Ctrl_Reg[2:1] <= 2'b10;
			write_en <= 8'd0;
		end
		else write_en <= 8'd0;
	end
	
	// Internal Reset signal
	assign clear = !resetn | Ctrl_Reg[0];
	
	// Control Register
	assign Ctrl_Reg[11:4] = {B4full, B3full, B2full, B1full, A4full, A3full, A2full, A1full};
	assign Ctrl_Reg[31:12] = 20'd0;
	
	always @(overflow)
		if (overflow) Ctrl_Reg[3] = 1'b1;
		else Ctrl_Reg[3] = 1'b0;
	
	
	
	// Write Logic
	assign fifo_sel = (!A1full) ? 8'b00000001: 
							(!A2full) ? 8'b00000010:
							(!A3full) ? 8'b00000100:
							(!A4full) ? 8'b00001000:
							(!B1full) ? 8'b00010000:
							(!B2full) ? 8'b00100000:
							(!B3full) ? 8'b01000000:
							(!B4full) ? 8'b10000000:
							8'b00000000;
							
	
	// Input FIFOs
	In_FIFO A1_FIFO(clock, In_Reg, rdA1, clear, write_en[0], A1empty, A1full, A1);
	In_FIFO A2_FIFO(clock, In_Reg, rdA2, clear, write_en[1], A2empty, A2full, A2);
	In_FIFO A3_FIFO(clock, In_Reg, rdA3, clear, write_en[2], A3empty, A3full, A3);
	In_FIFO A4_FIFO(clock, In_Reg, rdA4, clear, write_en[3], A4empty, A4full, A4);
	In_FIFO B1_FIFO(clock, In_Reg, rdB1, clear, write_en[4], B1empty, B1full, B1);
	In_FIFO B2_FIFO(clock, In_Reg, rdB2, clear, write_en[5], B2empty, B2full, B2);
	In_FIFO B3_FIFO(clock, In_Reg, rdB3, clear, write_en[6], B3empty, B3full, B3);
	In_FIFO B4_FIFO(clock, In_Reg, rdB4, clear, write_en[7], B4empty, B4full, B4);
	
	// Systolic Array Input Muxes
	assign A1in = (rdA1) ? A1 : 32'd0;
	assign A2in = (rdA2) ? A2 : 32'd0;
	assign A3in = (rdA3) ? A3 : 32'd0;
	assign A4in = (rdA4) ? A4 : 32'd0;
	assign B1in = (rdB1) ? B1 : 32'd0;
	assign B2in = (rdB2) ? B2 : 32'd0;
	assign B3in = (rdB3) ? B3 : 32'd0;
	assign B4in = (rdB4) ? B4 : 32'd0;
	
	// Systolic Array Input Registers
	register #(32) A1Reg(clock, clear, out_en, A1in, A1out);
	register #(32) A2Reg(clock, clear, out_en, A2in, A2out);
	register #(32) A3Reg(clock, clear, out_en, A3in, A3out);
	register #(32) A4Reg(clock, clear, out_en, A4in, A4out);
	register #(32) B1Reg(clock, clear, out_en, B1in, B1out);
	register #(32) B2Reg(clock, clear, out_en, B2in, B2out);
	register #(32) B3Reg(clock, clear, out_en, B3in, B3out);
	register #(32) B4Reg(clock, clear, out_en, B4in, B4out);
		
	// Systolic Array Control
	matrix_mult_ctrl control(clock, clear, Ctrl_Reg[1], rdA1, rdA2, rdA3, rdA4, rdB1, rdB2, rdB3, rdB4, 
							mult_en, add_en, out_en, done, count);
	
	// Systolic Array
	systolic_array array(clock, clear,  mult_en, add_en, out_en, A1out, A2out, A3out, A4out, B1out, B2out, B3out, B4out,
						C11, C12, C13, C14, C21, C22, C23, C24, C31, C32, C33, C34, C41, C42, C43, C44, overflow);
						
	// Output FIFO
	assign Cout = (count == 4'b0000)	? C11 :
						(count == 4'b0001) ? C12 :
						(count == 4'b0010) ? C13 : 
						(count == 4'b0011) ? C14 :
						(count == 4'b0100) ? C21 : 
						(count == 4'b0101) ? C22 :
						(count == 4'b0110) ? C23 :
						(count == 4'b0111) ? C24 :
						(count == 4'b1000) ? C31 : 
						(count == 4'b1001) ? C32 :
						(count == 4'b1010) ? C33 :
						(count == 4'b1011) ? C34 : 
						(count == 4'b1100) ? C41 :
						(count == 4'b1101) ? C42 : 
						(count == 4'b1110) ? C43 : 
						(count == 4'b1111) ? C44 : 
						32'd0;
	
	Out_FIFO outFIFO(clock, Cout, rdOUTFIFO, clear, done, Out_Reg, usedw); 
	
endmodule
						
	
	
						
