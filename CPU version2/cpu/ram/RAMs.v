`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Disjunctive.N.F
// Engineer: Tastror
// 
// Create Date: 2022/06/08 00:30:42
// Design Name: 
// Module Name: RAMs
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


module instruction_RAM(
    input wire write_enable,
    input wire clk,
    input wire [31:0] pc,
    input wire [31:0] write_data,
    output wire [31:0] instruction
);
parameter PC_INITIAL = 32'hbfc00000;

wire [31:0] temp;
wire [15:0] real_pc;
assign temp = pc - PC_INITIAL;
assign real_pc = temp[17:2];

dist_mem_gen_0 RAM_inst(
    // in
    .clk(clk), .a(real_pc), .we(write_enable), .d(write_data),
    // out
    .spo(instruction)
);

endmodule

module data_RAM(
    input wire clk,
    input wire en,
    input wire we,
    input wire [31:0] data_address,
    input wire [31:0] data,
    output wire [31:0] res
);
parameter ADDRESS_INITIAL = 32'h00000000;

wire [31:0] temp;
wire [15:0] real_address;
assign temp = data_address - ADDRESS_INITIAL;
assign real_address = temp[17:2];

dist_mem_gen_0 RAM_data(
    // in
    .clk(clk), .a(real_address), .we(we & en), .d(data),
    // out
    .spo(res)
);

endmodule
