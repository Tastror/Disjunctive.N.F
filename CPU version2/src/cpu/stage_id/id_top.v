// 完全组合逻辑

module id_top(
    //output
    rs,
    rt,
    rd,
    shamt,
    imm,
    instr_index,
    RegWrite,
    RegDst,
    ALUSrc,
    ALUOp,
    MemRead,
    MemWrite,
    MemToReg,
    //input
    dist,
    enable,
    rst_n
);

input [31:0] dist;
input enable;
input rst_n;

output [4:0] rs;
output [4:0] rt;
output [4:0] rd;
output [4:0] shamt;
output [15:0] imm;
output [25:0] instr_index;

wire [5:0] funct;
wire [5:0] op;

assign op = inst[31:26];
assign rs = inst[25:21];
assign rt = inst[20:16];
assign rd = inst[15:11];
assign shamt = inst[10:6];
assign funct = inst[5:0];

assign imm = inst[15:0];
assign instr_index[25:0];
assign code = inst[25:6];

id_control #(
    .op (op),
    .funct (funct),
    .rt (rt),
    .RegWrite (RegWrite),
    .RegDst (RegDst),
    .ALUSrc (ALUSrc),
    .ALUOp (ALUOp),
    .MemRead (MemRead),
    .MemWrite (MemWrite),
    .MemToReg (MemToReg)
)

endmodule