`timescale 1ns / 1ps

// // 完全组合逻辑

// module id_top(
//     //output
//     rs,
//     rt,
//     rd,
//     shamt,
//     imm,
//     instr_index,
//     RegWrite,
//     RegDst,
//     ALUSrc,
//     ALUOp,
//     MemRead,
//     MemWrite,
//     MemToReg,
//     //input
//     inst,
//     enable,
//     rst_n
// );

// input wire [31:0] inst;
// input wire enable;
// input wire rst_n;

// output reg [4:0] rs;
// output reg [4:0] rt;
// output reg [4:0] rd;
// output reg [4:0] shamt;
// output reg [15:0] imm;
// output reg [25:0] instr_index;

// output reg RegWrite;
// output reg [1:0] RegDst;
// output reg ALUSrc;
// output reg [5:0] ALUOp;
// output reg MemRead;
// output reg MemWrite;
// output reg MemToReg;

// reg [5:0] funct;
// reg [5:0] op;

// always @(*) begin
//     assign op = inst[31:26];
//     assign rs = inst[25:21];
//     assign rt = inst[20:16];
//     assign rd = inst[15:11];
//     assign shamt = inst[10:6];
//     assign funct = inst[5:0];
    
//     assign imm = inst[15:0];
//     assign instr_index = inst[25:0];
// //    assign code = inst[25:6];
// end

// id_control d(
//     .op (op),
//     .funct (funct),
//     .rt (rt),
//     .RegWrite (RegWrite),
//     .RegDst (RegDst),
//     .ALUSrc (ALUSrc),
//     .ALUOp (ALUOp),
//     .MemRead (MemRead),
//     .MemWrite (MemWrite),
//     .MemToReg (MemToReg)
// );

// endmodule


