`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/04 14:11:57
// Design Name: 
// Module Name: ALU
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


module ALU(
	input 	[11:0] 		alu_control,
	input	[31:0] 		alu_src1,
	input 	[31:0] 		alu_src2,
	output 	[31:0] 		alu_result
    );
	
	//现在有12个操作
	wire 				op_add; 	//加法操作
	wire 				op_sub;		//减法操作
	wire				op_slt;		//有符号比较，小于置位
	wire 				op_sltu;	//无符号比较，小于置位
	wire 				op_and; 	//按位与?
	wire				op_nor;		//按位与非
	wire 				op_or;		//按位或?
	wire 				op_xor;		//按位异或
	wire				op_sll; 	//逻辑左移，shift left logical
	wire 				op_srl;		//逻辑右移，shift right logical
	wire 				op_sra;		//算术右移，shift right arithmetic
	wire 				op_lui; 	//高位加载，load upper immediate	注意输入为src2
	
	//11个存储结果的寄存器，空间换时间?
	wire 	[31:0]	 	add_sub_result;
	wire 	[31:0]		slt_result;
	wire 	[31:0]	 	sltu_result;
	wire 	[31:0]	 	and_result;
	wire 	[31:0]		nor_result;
	wire 	[31:0]	 	or_result;	
	wire 	[31:0]	 	xor_result;
	wire 	[31:0]		sll_result;
	wire 	[31:0]	 	srl_result;
	wire 	[31:0]	 	sra_result;
	wire 	[31:0]	 	lui_result;
	
	//{and, nor, or, xor, lui}
	assign and_result = alu_src1 & alu_src2;
	assign or_result = alu_src1 | alu_src2;
	assign nor_result = ~or_result;
	assign xor_result = alu_src1 ^ alu_src2;
	assign lui_result = {alu_src2[15:0], 16'b0};
	
	//{add, sub}
	wire	[31:0]		adder_a;
	wire	[31:0] 		adder_b;
	wire				adder_carryin;
	wire	[31:0]		adder_result;
	wire				adder_carryout;
	wire				adder_mid_carryout;
	
	assign adder_a = alu_src1;
	assign adder_b = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;
	assign adder_carryin = (op_sub | op_slt | op_sltu) ? 1'b1 : 1'b0;
	adder_16b lo(.src1(alu_src1[15:0]), .src2(alu_arc2[15:0]), .carryin(adder_carryin), .res(adder_result[15:0]), .carryout(adder_mid_carryout));
	adder_16b hi(.src1(alu_src1[31:16]), .src2(alu_arc2[31:16]), .carryin(adder_mid_carryout), .res(adder_result[31:16]), .carryout(adder_carryout));
	
	assign add_sub_result = adder_result;
	
	//{slt, sltu}
	//如果src1为负数，src2为正数；或src1,src2异号，相加结果为负数
	assign slt_result[31:1] = 31'b0; //占位
	assign slt_result[0] = (alu_src1[31] & ~alu_src2[31])
						 | (~alu_src1[31] ^ alu_src2[31]) & adder_result[31]);
						 
	assign sltu_result[31:1] = 31'b0; //占位
	assign sltu_result[0] = ~adder_carryout;
	
	//{sll. srl, sra}
	assign sll_result = alu_src2 << alu_src1[4:0];
	assign srl_result = alu_src2 >> alu_src1[4:0];
	assign sra_result = ($signed(alu_src2)) >>> alu_src1[4:0];
	
	assign alu_result = 	(
							(({32{op_add|op_sub}} & add_sub_result)
						|	({32{op_slt}}		 & slt_result))
						|	(({32{op_sltu}}		 & sltu_result)
						|	({32{op_and}}		 & and_result))
							) 
							| 
							(
							(({32{op_nor}}		 & nor_result)
						|	({32{op_or}}		 & or_result))
						|	(({32{op_xor}}		 & xor_result)
						|	({32{op_sll}}		 & sll_result))
							)
							|
							(
							(({32{op_srl}}		 & srl_result)
						|	({32{op_sra}}		 & sra_result))
						|	({32{op_lui}}		 & lui_result)
							);
	
endmodule
