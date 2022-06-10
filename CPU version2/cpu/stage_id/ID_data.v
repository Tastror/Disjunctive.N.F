`timescale 1ns / 1ps

module id_data(
    input wire [31:0] instruction,
    output wire [5:0] opcode,
    output wire [5:0] funct,
    output wire [4:0] rs,
    output wire [5:0] rt,
    output wire [4:0] rd,
    output wire [4:0] sa,  // sa and base are the same
    output wire [15:0] imm,  // imm and offset are the same
    output wire [25:0] instIndex,
    output wire [19:0] code,
    output wire [2:0] sel
);

assign opcode = instruction[31:26];
assign funct = instruction[5:0];

assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign sa = instruction[10:6];

assign imm = instruction[15:0];
assign instIndex = instruction[25:0];

assign code = instruction[25:6];
assign sel = instruction[2:0];

endmodule
