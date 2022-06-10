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
	input 	[19:0] 		alu_control,
	input	[31:0] 		alu_src1,
	input 	[31:0] 		alu_src2,
	output 	[31:0] 		alu_result
);
	
// 现在�???20个操�???
wire op_add;    // 加法操作
wire op_sub;    // 减法操作
wire op_slt;    // 有符号比较，小于置位
wire op_sltu;   // 无符号比较，小于置位
wire op_and;    // 按位�????
wire op_nor;    // 按位与非
wire op_or;     // 按位�????
wire op_xor;    // 按位异或
wire op_sll;    // 逻辑左移，shift left logical
wire op_srl;    // 逻辑右移，shift right logical
wire op_sra;    // 算术右移，shift right arithmetic
wire op_lui;    // 高位加载，load upper immediate	注意输入为src2
wire op_llo;
wire op_mult;
wire op_bltz;
wire op_blez;
wire op_bgtz;
wire op_bgez;
wire op_beq;
wire op_bneq;
	
// {
//     0:+,
//     1:-,
//     2:slt,
//     3:sltu,
//     4:and�???,
//     5:nor或非,
//     6:or�???,
//     7:xor异或,
//     8:sll逻辑左移,
//     9:srl逻辑右移,
//     10:sra算术右移,
//     11:lui高位加载,
//     12:llo低位加载,
//     13:multi,
//     14:bltz,
//     15:blez,
//     16:bgtz,
//     17:bgez,
//     18:beq,
//     19:bneq
// }

    assign op_add = alu_control[0];
	assign op_sub = alu_control[1];
	assign op_slt = alu_control[2];
	assign op_sltu = alu_control[3];
	assign op_and = alu_control[4];
	assign op_nor = alu_control[5];
	assign op_or = alu_control[6];
	assign op_xor = alu_control[7];
	assign op_sll = alu_control[8];
	assign op_srl = alu_control[9];
	assign op_sra = alu_control[10];
	assign op_lui = alu_control[11];
	assign op_llo = alu_control[12];
	assign op_mult = alu_control[13];
	assign op_bltz = alu_control[14];
	assign op_blez = alu_control[15];
	assign op_bgtz = alu_control[16];
	assign op_bgez = alu_control[17];
	assign op_beq = alu_control[18];
	assign op_bneq = alu_control[19];

	//19个存储结果的寄存
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
	wire 	[31:0]	 	llo_result;
	wire 	[31:0]	 	mult_result;
	wire 	[31:0]	 	bltz_result;
	wire 	[31:0]	 	blez_result;
	wire 	[31:0]	 	bgtz_result;
	wire 	[31:0]	 	bgez_result;
	wire 	[31:0]	 	beq_result;
	wire 	[31:0]	 	bneq_result;
	
	//{and, nor, or, xor, lui, llo}
	assign and_result = alu_src1 & alu_src2;
	assign or_result = alu_src1 | alu_src2;
	assign nor_result = ~or_result;
	assign xor_result = alu_src1 ^ alu_src2;
	assign lui_result = {alu_src2[15:0], 16'b0};
	assign llo_result = {16'b0, alu_src2[31:16]};
	
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
//	adder_16b lo(.src1(alu_src1[15:0]), .src2(alu_src2[15:0]), .carryin(adder_carryin), .res(adder_result[15:0]), .carryout(adder_mid_carryout));
//	adder_16b hi(.src1(alu_src1[31:16]), .src2(alu_src2[31:16]), .carryin(adder_mid_carryout), .res(adder_result[31:16]), .carryout(adder_carryout));
    assign adder_result = adder_a + adder_b;
	
	assign add_sub_result = adder_result;
	
	//{slt, sltu}
	//如果src1为负数，src2为正数；或src1,src2异号，相加结果为负数
	assign slt_result[31:1] = 31'b0; //占位
	assign slt_result[0] = (alu_src1[31] & ~alu_src2[31])
						 | (~(alu_src1[31] ^ alu_src2[31]) & adder_result[31]);
						 
	assign sltu_result[31:1] = 31'b0; //占位
	assign sltu_result[0] = ~adder_carryout;
	
	//{sll. srl, sra}
	assign sll_result = alu_src2 << alu_src1[4:0];
	assign srl_result = alu_src2 >> alu_src1[4:0];
	assign sra_result = ($signed(alu_src2)) >>> alu_src1[4:0];
	
	//{其余暂时没写}

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
						|	(({32{op_lui}}		 & lui_result)
						|	({32{op_llo}}		 & llo_result))
							)
							|
							(
							(({32{op_mult}}		 & mult_result)
						|	({32{op_bltz}}		 & bltz_result))
						|	(({32{op_blez}}		 & blez_result)
						|	({32{op_bgtz}}		 & bgtz_result))
							)
							|
							(
							(({32{op_bgez}}		 & mult_result)
						|	({32{op_beq}}		 & bltz_result))
						|	(({32{op_bneq}}		 & blez_result))
							);
	
endmodule
