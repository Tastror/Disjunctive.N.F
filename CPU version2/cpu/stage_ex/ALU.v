`timescale 1ns / 1ps

module ALU(
    // input
    input wire [11:0] alu_control,
    input wire alu_op2,
    input wire [31:0] alu_src1,
    input wire [31:0] alu_src2,
    // output
    output wire [31:0] alu_result,
    output wire [31:0] alu_result_high,
    output wire alu_zero
);

//              0  1  2  3  4  5  6  7   8   9  10  11
// ctl_alu_mux [+, -, *, /, &, |, ^, <<, >>, <, ==, >]
// [0~3 op2 u, 5 op2 ~|, 8 op2 >>sra, 9 op2 >=, a op2 !=, b op2 <=]

wire op_add, op_sub, op_mul, op_div, op_and, op_or, op_xor, op_sll, op_srl, op_less, op_equal, op_great;
wire op_addu, op_subu, op_mulu, op_divu, op_nor, op_sra, op_geq, op_neq, op_leq;

assign op_add = alu_control[0] & ~alu_op2;
assign op_addu = alu_control[0] & alu_op2;
assign op_sub = alu_control[1] & ~alu_op2;
assign op_subu = alu_control[1] & alu_op2;
assign op_mul = alu_control[2] & ~alu_op2;
assign op_mulu = alu_control[2] & alu_op2;
assign op_div = alu_control[3] & ~alu_op2;
assign op_divu = alu_control[3] & alu_op2;
assign op_and = alu_control[4];
assign op_or = alu_control[5] & ~alu_op2;
assign op_nor = alu_control[5] & alu_op2;
assign op_xor = alu_control[6];
assign op_sll = alu_control[7];
assign op_srl = alu_control[8] & ~alu_op2;
assign op_sra = alu_control[8] & alu_op2;
assign op_less = alu_control[9] & ~alu_op2;
assign op_geq = alu_control[9] & alu_op2;
assign op_equal = alu_control[10] & ~alu_op2;
assign op_neq = alu_control[10] & alu_op2;
assign op_great = alu_control[11] & ~alu_op2;
assign op_leq = alu_control[11] & alu_op2;

wire [31:0] add_result;
wire [31:0] addu_result;
wire [31:0] sub_result;
wire [31:0] subu_result;
wire [31:0] mul_result;
wire [31:0] mulu_result;
wire [31:0] mul_result_high;
wire [31:0] mulu_result_high;
wire [31:0] div_result;
wire [31:0] divu_result;
wire [31:0] div_result_high;
wire [31:0] divu_result_high;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] nor_result;
wire [31:0] xor_result;
wire [31:0] sll_result;
wire [31:0] srl_result;
wire [31:0] sra_result;
wire [31:0] less_result;
wire [31:0] less_result_zero;
wire [31:0] geq_result;
wire [31:0] geq_result_zero;
wire [31:0] equal_result;
wire [31:0] equal_result_zero;
wire [31:0] neq_result;
wire [31:0] neq_result_zero;
wire [31:0] great_result;
wire [31:0] great_result_zero;
wire [31:0] leq_result;
wire [31:0] leq_result_zero;
    
assign add_result = alu_src1 + alu_src2;
assign addu_result = alu_src1 + alu_src2;
assign sub_result = alu_src1 - alu_src2;
assign subu_result = alu_src1 - alu_src2;
assign mul_result = 0;
assign mulu_result = 0;
assign mul_result_high = 0;
assign mulu_result_high = 0;
assign div_result = 0;
assign divu_result = 0;
assign div_result_high = 0;
assign divu_result_high = 0;
assign and_result = alu_src1 & alu_src2;
assign or_result = alu_src1 | alu_src2;
assign nor_result = ~or_result;
assign xor_result = alu_src1 ^ alu_src2;
assign sll_result = 0;
assign srl_result = 0;
assign sra_result = 0;
assign less_result = 0;
assign less_result_zero = 0;
assign geq_result = 0;
assign geq_result_zero = 0;
assign equal_result = 0;
assign equal_result_zero = 0;
assign neq_result = 0;
assign neq_result_zero = 0;
assign great_result = 0;
assign great_result_zero = 0;
assign leq_result = 0;
assign leq_result_zero = 0;

assign alu_result = 
    {32{op_add}} & add_result |
    {32{op_addu}} & addu_result |
    {32{op_sub}} & sub_result |
    {32{op_subu}} & subu_result |
    {32{op_mul}} & mul_result |
    {32{op_mulu}} & mulu_result |
    {32{op_div}} & div_result |
    {32{op_divu}} & divu_result |
    {32{op_and}} & and_result |
    {32{op_or}} & or_result |
    {32{op_nor}} & nor_result |
    {32{op_xor}} & xor_result |
    {32{op_sll}} & sll_result |
    {32{op_srl}} & srl_result |
    {32{op_sra}} & sra_result |
    {32{op_less}} & less_result |
    {32{op_geq}} & geq_result |
    {32{op_equal}} & equal_result |
    {32{op_neq}} & neq_result |
    {32{op_great}} & great_result |
    {32{op_leq}} & leq_result
;
assign alu_result_high =
    {32{op_mul}} & mul_result_high |
    {32{op_mulu}} & mulu_result_high |
    {32{op_div}} & div_result_high |
    {32{op_divu}} & divu_result_high
;
assign alu_zero =
    {32{op_less}} & less_result_zero |
    {32{op_geq}} & geq_result_zero |
    {32{op_equal}} & equal_result_zero |
    {32{op_neq}} & neq_result_zero |
    {32{op_great}} & great_result_zero |
    {32{op_leq}} & leq_result_zero
;
	
endmodule
