`timescale 1ns / 1ps



module id_control(
    input wire [5:0] opcode,
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire [4:0] sa,
    input wire [5:0] funct,

    output wire ctl_pc_first_mux, // 0, or depends on alu_res
    output wire [4:0] ctl_pc_second_mux, // [first, index, rs_data, break, recover]

    output wire [1:0] ctl_aluSrc1_mux, // aluSrc1: MUX2_32b, [rs_data, sa]
    output wire [2:0] ctl_aluSrc2_mux, // aluSrc1: MUX3_32b, [rt_data, imm_32, 0]
    output wire [13:0] ctl_alu_mux,
    output wire ctl_alu_op2,
    output wire [4:0] ctl_alures_merge_mux, // alures_merge: MUX5_32b, [alu_res, PC+8, HI_rdata, LO_rdata, CP0_data]
    
    output wire ctl_dataRam_en,
    output wire ctl_dataRam_wen,

    output wire ctl_rf_wen,
    output wire [1:0] ctl_rfWriteData_mux, // rfInData: MUX2_32b, [alures_merge, ramdata]
    output wire [2:0] ctl_rfWriteAddr_mux, // rfInAddr: MUX3_5b, [rd, rt, 31]

    output wire ctl_low_wen,
    output wire ctl_high_wen,
    output wire [1:0] ctl_low_mux,  // [alu_res, rs_data]
    output wire [1:0] ctl_high_mux,  // [alu_res_high, rs_data]
    
    output wire ctl_imm_zero_extend,

    output wire ctl_jr_choke,
    output wire ctl_chosen_choke,

    output wire [2:0] ctl_data_size, // [1, 2, 4]
    output wire ctl_data_zero_extend,

    output wire ctl_eret,
    output wire ctl_exception,
    output wire ctl_cp0_read,
    output wire ctl_cp0_write,
    output wire [4:0] ctl_cp0_exception_code
);

wire ADD, ADDI, ADDU, ADDIU, SUB, SUBU, SLT, SLTI, SLTU, SLTIU, DIV, DIVU, MUL, MULT, MULTU;
wire AND, ANDI, LUI, NOR, OR, ORI, XOR, XORI;
wire SLL, SRL, SRA, SLLV, SRLV, SRAV;
wire BEQ, BNE, BGEZ, BLTZ, BGTZ, BLEZ, BGEZAL, BLTZAL;
wire J, JAL, JR, JALR;
wire MFHI, MFLO, MTHI, MTLO;
wire BREAK, SYSCALL;
wire LB, LBU, LH, LHU, LW, SB, SH, SW;
wire ERET, MFC0, MTC0;
wire NOP;

assign ADD = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100000);
assign ADDI = (opcode == 6'b001000);
assign ADDU = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100001);
assign ADDIU = (opcode == 6'b001001);
assign SUB = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100010);
assign SUBU = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100011);
assign SLT = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b101010);
assign SLTI = (opcode == 6'b001010);
assign SLTU = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b101011);
assign SLTIU = (opcode == 6'b001011);
assign DIV = (opcode == 6'b000000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b011010);
assign DIVU = (opcode == 6'b000000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b011011);
assign MUL = (opcode == 6'b011100) & (sa == 5'b00000) & (funct == 6'b000010);
assign MULT = (opcode == 6'b000000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b011000);
assign MULTU = (opcode == 6'b000000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b011001);
assign AND = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100100);
assign ANDI = (opcode == 6'b001100);
assign LUI = (opcode == 6'b001111) & (rs == 5'b00000);
assign NOR = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100111);
assign OR = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100101);
assign ORI = (opcode == 6'b001101);
assign XOR = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b100110);
assign XORI = (opcode == 6'b001110);
assign SLL = (opcode == 6'b000000) & (rs == 5'b00000) & (funct == 6'b000000) & (|rd | |rt | |sa); // if not add this, sll and nop will be at the same time...
assign SRL = (opcode == 6'b000000) & (rs == 5'b00000) & (funct == 6'b000010);
assign SRA = (opcode == 6'b000000) & (rs == 5'b00000) & (funct == 6'b000011);
assign SLLV = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b000100);
assign SRLV = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b000110);
assign SRAV = (opcode == 6'b000000) & (sa == 5'b00000) & (funct == 6'b000111);
assign BEQ = (opcode == 6'b000100);
assign BNE = (opcode == 6'b000101);
assign BGEZ = (opcode == 6'b000001) & (rt == 5'b00001);
assign BLTZ = (opcode == 6'b000001) & (rt == 5'b00000);
assign BGTZ = (opcode == 6'b000111) & (rt == 5'b00000);
assign BLEZ = (opcode == 6'b000110) & (rt == 5'b00000);
assign BGEZAL = (opcode == 6'b000001) & (rt == 5'b10001);
assign BLTZAL = (opcode == 6'b000001) & (rt == 5'b10000);
assign J = (opcode == 6'b000010);
assign JAL = (opcode == 6'b000011);
assign JR = (opcode == 6'b000000) & (rt == 5'b00000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b001000);
assign JALR = (opcode == 6'b000000) & (rt == 5'b00000) & (sa == 5'b00000) & (funct == 6'b001001);
assign MFHI = (opcode == 6'b000000) & (rs == 5'b00000) & (rt == 5'b00000) & (sa == 5'b00000) & (funct == 6'b010000);
assign MFLO = (opcode == 6'b000000) & (rs == 5'b00000) & (rt == 5'b00000) & (sa == 5'b00000) & (funct == 6'b010010);
assign MTHI = (opcode == 6'b000000) & (rt == 5'b00000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b010001);
assign MTLO = (opcode == 6'b000000) & (rt == 5'b00000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b010011);
assign BREAK = (opcode == 6'b000000) & (funct == 6'b001101);
assign SYSCALL = (opcode == 6'b000000) & (funct == 6'b001100);
assign LB = (opcode == 6'b100000);
assign LBU = (opcode == 6'b100100);
assign LH = (opcode == 6'b100001);
assign LHU = (opcode == 6'b100101);
assign LW = (opcode == 6'b100011);
assign SB = (opcode == 6'b101000);
assign SH = (opcode == 6'b101001);
assign SW = (opcode == 6'b101011);
assign ERET = (opcode == 6'b010000) & (rs == 5'b10000) & (rt == 5'b00000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b011000);
assign MFC0 = (opcode == 6'b010000) & (rs == 5'b00000) & (sa == 5'b00000) & (funct[5:3] == 6'b000);
assign MTC0 = (opcode == 6'b010000) & (rs == 5'b00100) & (sa == 5'b00000) & (funct[5:3] == 6'b000);
assign NOP = (opcode == 6'b000000) & (rs == 5'b00000) & (rt == 5'b00000) & (rd == 5'b00000) & (sa == 5'b00000) & (funct == 6'b000000);



assign ctl_pc_first_mux =
    BEQ | BNE | BGEZ | BLTZ | BGTZ | BLEZ | BGEZAL | BLTZAL
;


// pcValue: MUX4_32b, [first, index, rs_data, break, recover]
assign ctl_pc_second_mux[0] =
    ADD | ADDI | ADDU | ADDIU | SUB | SUBU | SLT | SLTI | SLTU | SLTIU |
    DIV | DIVU | MUL | MULT | MULTU | AND | ANDI | LUI | NOR | OR | ORI |
    XOR | XORI | SLL | SRL | SRA | SLLV | SRLV | SRAV | BEQ | BNE | BGEZ |
    BLTZ | BGTZ | BLEZ | BGEZAL | BLTZAL | MFHI | MFLO | MTHI | MTLO |
    LB | LBU | LH | LHU | LW | SB | SH | SW | MFC0 | MTC0 |
    NOP
;
assign ctl_pc_second_mux[1] =
    J | JAL
;
assign ctl_pc_second_mux[2] =
    JR | JALR
;
assign ctl_pc_second_mux[3] =
    BREAK | SYSCALL
;
assign ctl_pc_second_mux[4] =
    ERET 
;


// aluSrc1: MUX2_32b, [rs_data, sa]
assign ctl_aluSrc1_mux[0] =
    ADD | ADDI | ADDU | ADDIU | SUB | SUBU | SLT | SLTI | SLTU | SLTIU |
    DIV | DIVU | MUL | MULT | MULTU | AND | ANDI | NOR | OR | ORI | XOR |
    XORI | SLLV | SRLV | SRAV | BEQ | BNE | BGEZ | BLTZ | BGTZ | BLEZ |
    BGEZAL | BLTZAL | LB | LBU | LH | LHU | LW | SB | SH | SW
;
assign ctl_aluSrc1_mux[1] =
    SLL | SRL | SRA
;


// aluSrc1: MUX3_32b, [rt_data, imm_32, 0]
assign ctl_aluSrc2_mux[0] =
    ADD | ADDU | SUB | SUBU | SLT | SLTU | DIV | DIVU | MUL | MULT |
    MULTU | AND | NOR | OR | XOR | SLL | SRL | SRA | SLLV | SRLV | SRAV |
    BEQ | BNE
;
assign ctl_aluSrc2_mux[1] =
    ADDI | ADDIU | SLTI | SLTIU | ANDI | ORI | XORI | LB | LBU | LH | LHU |
    LW | SB | SH | SW | LUI
;
assign ctl_aluSrc2_mux[2] =
    BLTZ | BGTZ | BLEZ | BGEZ | BGEZAL | BLTZAL
;


//              0  1  2  3  4  5  6  7   8   9  10  11 12
// ctl_alu_mux [+, -, *, /, &, |, ^, <<, >>, <, ==, >, <u]
// [5 op2 ~|, 9 op2 >=, a op2 !=, b op2 <=]
assign ctl_alu_mux[0] =
    ADD | ADDI | ADDU | ADDIU | LB | LBU | LH | LHU | LW | SB | SH | SW
;
assign ctl_alu_mux[1] =
    SUB | SUBU
;
assign ctl_alu_mux[2] =
    MUL | MULT | MULTU
;
assign ctl_alu_mux[3] =
    DIV | DIVU
;
assign ctl_alu_mux[4] =
    AND | ANDI
;
assign ctl_alu_mux[5] =
    NOR | OR | ORI
;
assign ctl_alu_mux[6] =
    XOR | XORI
;
assign ctl_alu_mux[7] =
    SLL | SLLV
;
assign ctl_alu_mux[8] =
    SRL | SRA | SRLV | SRAV
;
assign ctl_alu_mux[9] =
    SLT | SLTI | BGEZ | BLTZ | BGEZAL | BLTZAL
;
assign ctl_alu_mux[10] =
    BEQ | BNE
;
assign ctl_alu_mux[11] =
    BGTZ | BLEZ
;
assign ctl_alu_mux[12] =
    SLTU | SLTIU
;
assign ctl_alu_mux[13] =
    LUI
;


assign ctl_alu_op2 =
    ADDU | ADDIU | SUBU | SLTU | SLTIU | DIVU | MULTU | NOR | SRA | SRAV |
     BNE | BGEZ | BLEZ | BGEZAL
;


// alures_merge: MUX5_32b, [alu_res, PC+8, HI_rdata, LO_rdata, CP0_data]
assign ctl_alures_merge_mux[0] =
    ADD | ADDI | ADDU | ADDIU | SUB | SUBU | SLT | SLTI | SLTU | SLTIU |
    MUL | AND | ANDI | NOR | OR | ORI | XOR | XORI | SLL | SRL | SRA |
    SLLV | SRLV | SRAV | LB | LBU | LH | LHU | LW | LUI | SB | SH | SW
;
assign ctl_alures_merge_mux[1] =
    BGEZAL | BLTZAL | JAL | JALR
;
assign ctl_alures_merge_mux[2] =
    MFHI
;
assign ctl_alures_merge_mux[3] =
    MFLO
;
assign ctl_alures_merge_mux[4] =
    MFC0
;


assign ctl_dataRam_en =
    LB | LBU | LH | LHU | LW | SB | SH | SW
;


assign ctl_dataRam_wen =
    SB | SH | SW
;


assign ctl_rf_wen =
    ADD | ADDI | ADDU | ADDIU | SUB | SUBU | SLT | SLTI | SLTU | SLTIU |
    MUL | AND | ANDI | LUI | NOR | OR | ORI | XOR | XORI | SLL | SRL |
    SRA | SLLV | SRLV | SRAV | BGEZAL | BLTZAL | JAL | JALR | MFHI | MFLO |
    LB | LBU | LH | LHU | LW | MFC0
;


// rfInData: MUX2_32b, [alures_merge, ramdata]
assign ctl_rfWriteData_mux[0] =
    ADD | ADDI | ADDU | ADDIU | SUB | SUBU | SLT | SLTI | SLTU | SLTIU |
    MUL | AND | ANDI | NOR | OR | ORI | XOR | XORI | SLL | SRL | SRA | SLLV |
    SRLV | SRAV | LUI | BGEZAL | BLTZAL | JAL | JALR | MFHI | MFLO | MFC0
;
assign ctl_rfWriteData_mux[1] =
    LB | LBU | LH | LHU | LW
;


// rfInAddr: MUX3_5b, [rd, rt, 31]
assign ctl_rfWriteAddr_mux[0] =
    ADD | ADDU | SUB | SUBU | SLT | SLTU | MUL | AND | NOR | OR | XOR |
    SLL | SRL | SRA | SLLV | SRLV | SRAV | MFHI | MFLO
;
assign ctl_rfWriteAddr_mux[1] =
    ADDI | ADDIU | SLTI | SLTIU | ANDI | LUI | ORI | XORI | LB | LBU |
    LH | LHU | LW | MFC0
;
assign ctl_rfWriteAddr_mux[2] =
    BGEZAL | BLTZAL | JAL | JALR
;


assign ctl_low_wen =
    DIV | DIVU | MULT | MULTU | MTLO
;


assign ctl_high_wen =
    DIV | DIVU | MULT | MULTU | MTHI
;


// [alu_res, rs_data]
assign ctl_low_mux[0] =
    DIV | DIVU | MULT | MULTU
;
assign ctl_low_mux[1] =
    MTLO
;


// [alu_res, rs_data]
assign ctl_high_mux[0] =
    DIV | DIVU | MULT | MULTU
;
assign ctl_high_mux[1] =
    MTHI
;


assign ctl_imm_zero_extend =
    ANDI | ORI | XORI
;


assign ctl_jr_choke =
    JR | JALR
;
assign ctl_chosen_choke =
    BEQ | BNE | BGEZ | BGTZ | BLEZ | BLTZ | BGEZAL | BLTZAL
;


assign ctl_data_size[0] = 
    LB | LBU | SB
;
assign ctl_data_size[1] =
    LH | LHU | SH
;
assign ctl_data_size[2] =
    LW | SW
;


assign ctl_data_zero_extend = 
    LBU | LHU
;


assign ctl_eret =
    ERET
;
assign ctl_cp0_read =
    MFC0
;
assign ctl_cp0_write =
    MTC0
;


assign ctl_exception = 
    SYSCALL | BREAK
;


assign ctl_cp0_exception_code =
    SYSCALL ? 5'h8 : (
        BREAK ? 5'h9 : 5'h0
    )
;


endmodule