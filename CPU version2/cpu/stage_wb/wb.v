`timescale 1ns / 1ps

// module wb(
//     // output
//     reg_we,//reg写使�?
//     reg_data,//要写入的数据
//     reg_addr,//要写入的寄存器地�?
//     // input
//     wb_wdata,
//     wb_waddr,
//     MemToReg
// );

// output reg reg_we;
// output reg [31:0] reg_data;
// output reg [31:0] reg_addr;

// input wire [31:0] wb_waddr;
// input wire [31:0] wb_wdata;
// input wire MemToReg;

// always @(*) begin
//     assign reg_addr = wb_waddr;
//     assign reg_data = wb_wdata;
    
//     assign reg_we = MemToReg;
// end

// endmodule