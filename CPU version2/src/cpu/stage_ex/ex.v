module ex(
    //output
    pc_zero_sign,
    ex_res,
    reg_addr,
    pc_branch_addr,
    alu_src1,
    alu_src2,
    alu_op,
    //input
    ALUOp,
    ALUSrc,
    RegDst,
    shamt,
    rt,
    rd,
    reg_rdata1,
    reg_rdata2,
    npc
);

wire pc_zero_sign;
wire [31:0] ex_res;
wire [31:0] reg_addr;
wire [31:0] pc_branch_addr;
wire [31:0] alu_src1;
wire [31:0] alu_src2;
wire [19:0] alu_op;

wire [5:0] ALUOp;
wire ALUSrc;
wire [1:0] RegDst;
wire [4:0] shamt;
wire [4:0] rt;
wire [4:0] rd;
wire [31:0] reg_rdata1;
wire [31:0] reg_rdata2;
wire [31:0] npc;

// 控制部分还没写

endmodule