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

output reg pc_zero_sign;
output reg [31:0] ex_res;
output reg [31:0] reg_addr;
output reg [31:0] pc_branch_addr;
output reg [31:0] alu_src1;
output reg [31:0] alu_src2;
output reg [19:0] alu_op;

input wire [5:0] ALUOp;
input wire ALUSrc;
input wire [1:0] RegDst;
input wire [4:0] shamt;
input wire [4:0] rt;
input wire [4:0] rd;
input wire [31:0] reg_rdata1;
input wire [31:0] reg_rdata2;
input wire [31:0] npc;

always @(*)
    case (ALUOp)
        6'd0: assign alu_op = 20'b0000_0000_0000_0001;
        6'd1: assign alu_op = 20'b0000_0000_0000_0010;
        6'd2: assign alu_op = 20'b0000_0000_0000_0100;
        6'd3: assign alu_op = 20'b0000_0000_0000_1000;
        6'd4: assign alu_op = 20'b0000_0000_0001_0010;
        6'd5: assign alu_op = 20'b0000_0000_0010_0000;
        6'd6: assign alu_op = 20'b0000_0000_0100_0000;
        6'd7: assign alu_op = 20'b0000_0000_1000_0000;
        6'd8: assign alu_op = 20'b0000_0001_0000_0000;
        6'd9: assign alu_op = 20'b0000_0001_0000_0000;
        6'd10: assign alu_op = 20'b0000_0010_0000_0000;
        6'd11: assign alu_op = 20'b0000_0100_0000_0000;
        6'd12: assign alu_op = 20'b0000_1000_0000_0000;
        6'd13: assign alu_op = 20'b0001_0000_0000_0000;
    endcase

endmodule