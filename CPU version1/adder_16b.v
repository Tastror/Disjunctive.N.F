`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/04 20:22:23
// Design Name: 
// Module Name: adder_16b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder_16b(
	input	[15:0]	src1,
	input 	[15:0]	src2,
	input			carryin,
	output 	[15:0]	res,
	output			carryout
    );
	
	wire 	[15:0]	p;
	wire	[15:0]	g;
	wire	[3:0]	P;
	wire 	[3:0]	G;
	wire	[16:0] 	c;
	
	assign c[0] = carryin;
	assign g = src1 & src2;
	assign p = src1 ^ src2;
	
	assign P[0] = p[3]  & p[2]  & p[1]  & p[0];
	assign P[1] = p[7]  & p[6]  & p[5]  & p[4];
	assign P[2] = p[11] & p[10] & p[9]  & p[8];
	assign P[3] = p[15] & p[14] & p[13] & p[12];
	
	assign G[0] = g[3]	|	(p[3] & g[2])	|	(p[3] & p[2] & g[1])	|	(p[3] & p[2] & p[1] & g[0])		;
	assign G[1] = g[7]	|	(p[7] & g[6])	|	(p[7] & p[6] & g[5])	|	(p[7] & p[6] & p[5] & g[4])		;
	assign G[2] = g[11]	|	(p[11] & g[10])	|	(p[11] & p[10] & g[9])	|	(p[11] & p[10] & p[9] & g[8])	;
	assign G[3] = g[15]	|	(p[15] & g[14])	|	(p[15] & p[14] & g[13])	|	(p[15] & p[14] & p[13] & g[12])	;
	
	assign c[1]  = g[0] 	 | (p[0] & c[0]);
    assign c[2]  = g[1] 	 | (p[1] & g[0]) 	| (p[1] & p[0] & c[0]);
    assign c[3]  = g[2] 	 | (p[2] & g[1]) 	| (p[2] & p[1] & g[0]) 		| (p[2] & p[1] & p[0] & c[0]);
		   
	assign c[4]  = G[0] 	 | (P[0] & c[0]);
		   
	assign c[5]  = g[4] 	 | (p[4] & c[4]);
    assign c[6]  = g[5] 	 | (p[5] & g[4]) 	| (p[5] & p[4] & c[4]);
    assign c[7]  = g[6] 	 | (p[6] & g[5]) 	| (p[6] & p[5] & g[4]) 		| (p[6] & p[5] & p[4] & c[4]);
		   
	assign c[8]  = G[1] 	 | (P[1] & G[0]) 	| (P[1] & P[0] & c[0]);
		   
	assign c[9]  = g[8] 	 | (p[8] & c[8]);
    assign c[10] = g[9]  	 | (p[9] & g[8]) 	| (p[9] & p[8] & c[8]);
    assign c[11] = g[10] 	 | (p[10] & g[9]) 	| (p[10] & p[9] & g[8]) 	| (p[10] & p[9] & p[8] & c[8]);
		   
	assign c[12] = G[2]  	 | (P[2] & G[1]) 	| (P[2] & P[1] & G[0]) 		| (P[2] & P[1] & P[0] & c[0]);
		   
	assign c[13] = g[12] 	 | (p[12] & c[12]);
    assign c[14] = g[13] 	 | (p[13] & g[12]) 	| (p[13] & p[12] & c[12]);
    assign c[15] = g[14] 	 | (p[14] & g[13]) 	| (p[14] & p[13] & g[12]) 	| (p[14] & p[13] & p[12] & c[12]);
		   
	assign c[16] = G[3]  	 | (P[3] & G[2]) 	| (P[3] & P[2] & G[1]) 		| (P[3] & P[2] & P[1] & G[0]) 	| (P[3] & P[2] & P[1] & P[0] & c[0]);
	
	assign carryout = c[16];
	
	assign res = (src1 ^ src2) ^ c[15:0];
	
endmodule
