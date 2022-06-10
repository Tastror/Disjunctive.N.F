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
    input wire [15:0] pc,
    input wire [31:0] write_data,
    output wire [31:0] instruction
);

dist_mem_gen_0 RAM_inst(
    // in
    .clk(clk), .a(pc), .we(write_enable), .d(write_data),
    // out
    .spo(instruction)
);

endmodule

module data_RAM(
    input wire clk,
    input wire we,
    input wire [15:0] data_address,
    input wire [31:0] data,
    output wire [31:0] res
);

dist_mem_gen_0 RAM_data(
    // in
    .clk(clk), .a(data_address), .we(we), .d(data),
    // out
    .spo(res)
);

endmodule
