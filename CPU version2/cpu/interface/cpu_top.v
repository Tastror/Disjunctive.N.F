`timescale 1ns/1ps

// 接口是写死的，顶层模块就只需要这些接口
module cpu_top (
    input wire clk,
    input wire resetn,

    input wire inst_sram_addr_ok,
    input wire inst_sram_data_ok,
    input wire [31:0] inst_sram_rdata,
    output reg inst_sram_req,
    output reg inst_sram_wr,
    output reg [1:0] inst_sram_size,
    output reg [3:0] inst_sram_wstrb,
    output reg [31:0] inst_sram_addr,
    output reg [31:0] inst_sram_wdata,

    input wire data_sram_addr_ok,
    input wire data_sram_data_ok,
    input wire [31:0] data_sram_rdata,
    output reg data_sram_req,
    output reg data_sram_wr,
    output reg data_sram_size,
    output reg [3:0] data_sram_wstrb,
    output reg [31:0] data_sram_addr,   
    output reg [31:0] data_sram_wdata,

    output reg [31:0] debug_wb_pc,
    output reg debug_wb_rf_wen,  
    output reg debug_wb_rf_wnum,
    output reg [31:0] debug_wb_rf_wdata
);

wire [31:0] pc_res;
wire pc_wait_stop_choke;
wire [31:0] if_instruction;

pc pc(
    .clk(clk),
    .rst_n(resetn),
    .wait_stop_choke(pc_wait_stop_choke),
    .pc_res(pc_res)
);

reg [63:0] tick;
reg [31:0] flag;

assign pc_wait_stop_choke = (inst_sram_data_ok == 1'b1 && (flag == 32'h200 || flag == 32'h301)) ? 1'b0 : 1'b1;
assign if_instruction = inst_sram_rdata;

// resetn
// **假设**同时只有�???个取指的请求
always @(posedge clk) begin
    if (!resetn) begin
        inst_sram_req <= 1'b0;
        inst_sram_addr <= 32'b0;
        inst_sram_wr <= 1'b0;
        inst_sram_wdata <= 32'b0;
        inst_sram_wstrb <= 4'b0;
        inst_sram_size <= 2'b0;
        tick <= 64'h0;
        flag <= 32'h0;
        // flag: 0 reset
        // 1 send
        // 2 req is 1
        // h300 req is 1 and see addr_ok be 1 (shake failed)
        // h200 req is 1 but addr_ok not 1 (shake success)
        // 3 ready to get data
        // h301 after shake and inst_sram_data_ok is not 1 (received failed)
        // h201 after shake and inst_sram_data_ok is 1 (received success)
    end

    else begin

        tick <= tick + 1;

        if (flag == 32'h0)
            flag <= 32'h1;

        if (flag == 32'h1) begin
            inst_sram_req <= 1'b1;
            inst_sram_addr <= pc_res;
            inst_sram_size <= 2'd2;
            flag <= 32'h2;
        end

        if (flag == 32'h2 || flag == 32'h300) begin
            flag <= {32'h200} & {32{inst_sram_addr_ok}} | 32'h300 & {32{~inst_sram_addr_ok}};
            inst_sram_req <= 1'b0 & {32{inst_sram_addr_ok}} | 1'b1 & {32{~inst_sram_addr_ok}};
            inst_sram_addr <= 32'b0 & {32{inst_sram_addr_ok}} | pc_res & {32{~inst_sram_addr_ok}};
            inst_sram_size <= 2'b0 & {32{inst_sram_addr_ok}} | 2'd2 & {32{~inst_sram_addr_ok}};
        end

        if (flag == 32'h200 || flag == 32'h301) begin
            inst_sram_req <= 1'b0;
            inst_sram_addr <= 0;
            inst_sram_size <= 0;
            flag <= {32'h201} & {32{inst_sram_data_ok}} | 32'h301 & {32{~inst_sram_data_ok}};
        end

        if (flag == 32'h201) begin
            flag <= 32'h1;
        end

    end
    
end

endmodule