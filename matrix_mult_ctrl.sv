module matrix_mult_ctrl ( clk, reset, start, rdA1, rdA2, rdA3, rdA4, rdB1, rdB2, rdB3, rdB4, mult_en, add_en, out_en, done, outcount);

	input logic clk, reset, start;
	
	output logic rdA1, rdA2, rdA3, rdA4, rdB1, rdB2, rdB3, rdB4, mult_en, add_en, out_en, done;
	output logic [3:0] outcount;
	
	// Defining States
	typedef enum logic [2:0] {RST, INI, LDI, MUL, ADD, OUT} statetype;
	statetype CS, NS;
	
	// Counter Signals
	logic [2:0] count, nextcount;
	logic [3:0] topcount, nexttopcount, nextoutcount;
	
	// State Flip-flops
	always_ff @(posedge clk)
		if (reset) CS <= RST;
		else begin
			CS <= NS;
			count <= nextcount;
			topcount <= nexttopcount;
			outcount <= nextoutcount;
		end
		
	
	always_comb
		case (CS)
			RST: 	begin
						NS = INI;
						nextcount = 0;
					end
			INI:  if (start) begin
						NS = LDI; 
						nextcount = 0;
					end
					else begin
						NS = INI;
						nextcount = 0;
					end
			LDI: 	if (topcount == 4'd11) begin
						NS = OUT;					
						nextcount = 0;
					end
					else begin
						NS = MUL; 
						nextcount = 0;
					end
			MUL: 	if (count == 3'd5) begin 
						NS = ADD; 
						nextcount = 0;
					end
					else begin 
						NS = MUL;
						nextcount = count + 3'd1;
					end
			ADD:	if (count == 3'd7) begin
						NS = LDI; 
						nextcount = 0;
					end
					else begin
						NS = ADD;
						nextcount = count + 3'd1;
					end
			OUT:	if (outcount == 4'd15) begin
						NS = RST;
						nextcount = 0;
					end
					else begin
						NS = OUT;
						nextcount = 0;
					end
			default: begin
							NS = RST; 
							nextcount = 0;
						end
							
		endcase
	
	
	// Counters
	assign nexttopcount = (CS == LDI) ? topcount + 4'd1 : 
									(CS == RST) ? 4'd0 :
									topcount;
	assign nextoutcount = (CS == OUT) ? outcount + 3'd1: 3'd0;
	
	// Outputs
	assign rdA1 = (CS == LDI) ? (topcount < 4'd5) ? 1'd1 : 1'd0 :
											1'd0;
	assign rdA2 = (CS == LDI) ? (((topcount > 4'd0) && (topcount < 4'd6)) ? 1'd1 : 1'd0) : 
											1'd0;
	assign rdA3 = (CS == LDI) ? (((topcount > 4'd1) && (topcount < 4'd7)) ? 1'd1 : 1'd0) :
											1'd0;
	assign rdA4 = (CS == LDI) ? (((topcount > 4'd2) && (topcount < 4'd8)) ? 1'd1 : 1'd0): 
											1'd0;
	assign rdB1 = (CS == LDI) ? ((topcount < 4'd5) ? 1'd1 : 1'd0) : 
											1'd0;
	assign rdB2 = (CS == LDI) ? (((topcount > 4'd0) && (topcount < 4'd6)) ? 1'd1 : 1'd0) : 
											1'd0;
	assign rdB3 = (CS == LDI) ? (((topcount > 4'd1) && (topcount < 4'd7)) ? 1'd1 : 1'd0) : 
											1'd0;
	assign rdB4 = (CS == LDI) ? (((topcount > 4'd2) && (topcount < 4'd8)) ? 1'd1 : 1'd0) : 
											1'd0;
	assign add_en = (CS == ADD) ? 1'b1 : 1'b0;
	assign mult_en = (CS == MUL) ? 1'b1 : 1'b0;
	assign out_en = (CS == LDI) ? 1'b1 : 1'b0;
	assign done = (CS == OUT) ? 1'b1 : 1'b0;
	
	
endmodule	