`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Disjunctive.N.F
// Engineer: Tastror
// 
// Create Date: 2022/05/03 21:43:40
// Design Name: 
// Module Name: RF
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


module RF(
    input wire[4:0] rfReadAddr1,
    input wire[4:0] rfReadAddr2,
    input wire[4:0] rfWriteAddr,
    input wire[31:0] rfWriteData,
    input wire rf_wen,
    input wire rf_en,
    output reg [31:0] rfReadData1,
    output reg [31:0] rfReadData2
);
endmodule
