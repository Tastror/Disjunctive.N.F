`timescale 1ns / 1ps

module ALU(
    // input
    input wire [13:0] alu_control,
    input wire alu_op2,
    input wire [31:0] alu_src1,
    input wire [31:0] alu_src2,
    input wire alu_op_load_store, // 0: store, 1: load
    input wire [2:0] alu_data_size,
    // output
    output wire [31:0] alu_result,
    output wire [31:0] alu_result_high,
    output wire alu_zero,
    output wire alu_exception,
    output wire [4:0] alu_exception_code,
    output wire [31:0] alu_BadVAddr_addr
);

//              0  1  2  3  4  5  6  7   8   9  10  11 12  13
// ctl_alu_mux [+, -, *, /, &, |, ^, <<, >>, <, ==, >, <u, lui]
// [0~3 op2 u, 5 op2 ~|, 8 op2 >>sra, 9 op2 >=, a op2 !=, b op2 <=]

wire op_add, op_sub, op_mul, op_div, op_and, op_or, op_xor, op_sll, op_srl, op_less, op_equal, op_great, op_less_unsigned, op_lui;
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
assign op_less_unsigned = alu_control[12];
assign op_lui = alu_control[13];

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
wire [31:0] less_unsigned_result;
wire [31:0] lui_result;

wire [31:0] pos_src1;
wire [31:0] pos_src2;
wire [31:0] divQuotient;
wire [31:0] divRemainder;
wire [63:0] mulAns;

wire exception_badAddr, exception_overflow;

// judge signed
wire a1_sign, a2_sign, all_pos, pos_neg, neg_pos, all_neg;
assign a1_sign = alu_src1[31];
assign a2_sign = alu_src2[31];
assign all_pos = ~alu_src1[31] & ~alu_src2[31];
assign pos_neg = ~alu_src1[31] & alu_src2[31];
assign neg_pos = alu_src1[31] & ~alu_src2[31];
assign all_neg = alu_src1[31] & alu_src2[31];
// judge over

assign pos_src1 = (a1_sign) ? (~alu_src1 + 1) : alu_src1;
assign pos_src2 = (a2_sign) ? (~alu_src2 + 1) : alu_src2;

assign add_result = alu_src1 + alu_src2;
assign addu_result = alu_src1 + alu_src2;
assign sub_result = alu_src1 - alu_src2;
assign subu_result = alu_src1 - alu_src2;

// mul with signed
assign mulAns = pos_src1 * pos_src2;
assign {mul_result_high, mul_result} =
    ((a1_sign ^ a2_sign == 1'b1) ? (~mulAns[63:0] + 1) : mulAns);

// div with signed
assign divQuotient = pos_src1 / pos_src2;
assign divRemainder = pos_src1 % pos_src2;
assign div_result =
    |pos_src2 == 1'b0 ? 32'h0 :
    ((a1_sign ^ a2_sign == 1'b1) ? (~divQuotient[31:0] + 1) : divQuotient);
assign div_result_high =
    |pos_src2 == 1'b0 ? 32'h0 :
    ((a1_sign == 1'b1) ? (~divRemainder[31:0] + 1) : divRemainder);

assign {mulu_result_high, mulu_result} = alu_src1 * alu_src2;
assign divu_result = alu_src1 / alu_src2;
assign divu_result_high = alu_src1 % alu_src2;
assign and_result = alu_src1 & alu_src2;
assign or_result = alu_src1 | alu_src2;
assign nor_result = ~or_result;
assign xor_result = alu_src1 ^ alu_src2;
assign sll_result = alu_src2 << alu_src1[4:0];
assign srl_result = alu_src2 >> alu_src1[4:0];
assign sra_result = $signed(alu_src2) >>> alu_src1[4:0];
assign less_result =
    all_pos & (alu_src1 < alu_src2) |
    pos_neg & 0 |
    neg_pos & 1 |
    all_neg & (alu_src1 < alu_src2)
;
assign less_result_zero = less_result[0];
assign geq_result = {{31'h0}, ~less_result[0]};
assign geq_result_zero = geq_result[0];
assign equal_result = (alu_src1 == alu_src2);
assign equal_result_zero = equal_result[0];
assign neq_result = {{31'h0}, ~equal_result[0]};
assign neq_result_zero = neq_result[0];
assign great_result =
    all_pos & (alu_src1 > alu_src2) |
    pos_neg & 1 |
    neg_pos & 0 |
    all_neg & (alu_src1 > alu_src2)
;
assign great_result_zero = great_result[0];
assign leq_result = {{31'h0}, ~great_result[0]};
assign leq_result_zero = leq_result[0];
assign less_unsigned_result = alu_src1 < alu_src2;
assign lui_result = {alu_src2[15:0], {16'h0}};

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
    {32{op_leq}} & leq_result |
    {32{op_less_unsigned}} & less_unsigned_result |
    {32{op_lui}} & lui_result
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

// wrong address
assign exception_badAddr =  (alu_data_size[1] & alu_result[0] != 1'b0) |
                            (alu_data_size[2] & alu_result[1:0] != 2'b0);
// overflow
assign exception_overflow = (all_neg & alu_result[31] == 1'b0) |
                            (all_pos & alu_result[31] == 1'b1);
// merge to exception
assign alu_exception = exception_badAddr | exception_overflow;
assign alu_exception_code = exception_badAddr ? (
                                alu_op_load_store ? 5'04 : 5'h05
                            ) : ( exception_overflow ? 5'0c : 5'h0);
assign alu_BadVAddr_addr = exception_badAddr ? alu_result : 32'h0;
	
endmodule
