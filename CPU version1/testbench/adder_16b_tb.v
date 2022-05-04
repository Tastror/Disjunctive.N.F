`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/04 21:59:12
// Design Name: 
// Module Name: adder_16b_tb
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


module adder_16b_tb();
	
	reg [15:0] 	tb_a;
	reg [15:0] 	tb_b;
	reg			tb_carryin;
	wire [15:0]	tb_c;
	wire 		tb_carryout;
	
	wire [16:0] tb_carry;
	
	adder_16b x(.src1(tb_a), .src2(tb_b), .carryin(tb_carryin), .res(tb_c), .carryout(tb_carryout), .c(tb_carry));
	
	initial begin 
		tb_a = 16'b1101_0101_0110_0011;
		tb_b = 16'b1011_0101_0101_0110;
		tb_carryin = 0;
	end
	
endmodule
