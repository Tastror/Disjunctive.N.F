`timescale 1ns / 1ps

module inst_ram_interface(

    // input
    input wire clk,
    input wire reset,
    input wire inst_sram_addr_ok,
    input wire inst_sram_data_ok,
    input wire [31:0] inst_sram_rdata,
    input wire [31:0] pc,

    // output
    output reg inst_sram_req,
    output reg inst_sram_wr,
    output reg [1:0] inst_sram_size,
    output reg [3:0] inst_sram_wstrb,
    output reg [31:0] inst_sram_addr,
    output reg [31:0] inst_sram_wdata,
    output wire pc_wait_stop_choke,
    output wire [31:0] IF_instruction,
    output wire [31:0] this_time_pc
);

reg [63:0] tick;
reg [31:0] flag;
reg [31:0] this_time_pc;

assign pc_wait_stop_choke = (inst_sram_data_ok && (flag == 32'h200 || flag == 32'h301)) ? 1'b0 : 1'b1;
assign IF_instruction = inst_sram_rdata;

always @(posedge clk) begin
    if (reset) begin
        inst_sram_req <= 1'b0;
        inst_sram_addr <= 32'b0;
        inst_sram_wr <= 1'b0;
        inst_sram_wdata <= 32'b0;
        inst_sram_wstrb <= 4'b0;
        inst_sram_size <= 2'b0;
        tick <= 64'h0;
        flag <= 32'h0;
        this_time_pc <= 32'h0;
        // flag:
        // 0 reset and ready to send
        // 1 is sending first time
        // h300 req is 1 and see addr_ok be 1 (shake failed)
        // h200 req is 1 but addr_ok not 1 (shake success), and is receiving first time
        // h301 after shake and inst_sram_data_ok is not 1 (received failed)
        // h201 after shake and inst_sram_data_ok is 1 (received success), and is sending first time
    end

    else begin

        tick <= tick + 1;

        if (flag == 32'h0) begin
            inst_sram_req <= 1'b1;
            inst_sram_addr <= pc;
            this_time_pc <= pc;
            inst_sram_size <= 2'd2;
            flag <= 32'h1;
        end

        if ((flag == 32'h1 || flag == 32'h300) && ~inst_sram_addr_ok) begin
            flag <= 32'h300;
            inst_sram_req <= 1'b1;
            inst_sram_addr <= pc;
            this_time_pc <= pc;
            inst_sram_size <= 2'd2;
        end

        if ((flag == 32'h1 || flag == 32'h300) && inst_sram_addr_ok) begin
            flag <= 32'h200;
            inst_sram_req <= 1'b0;
            inst_sram_addr <= 32'b0;
            inst_sram_size <= 2'b0;
        end

        if ((flag == 32'h200 || flag == 32'h301) && ~inst_sram_data_ok) begin
            inst_sram_req <= 1'b0;
            inst_sram_addr <= 32'b0;
            inst_sram_size <= 2'b0;
            flag <= 32'h301;
        end

        if ((flag == 32'h200 || flag == 32'h301) && inst_sram_data_ok) begin
            inst_sram_req <= 1'b0;
            inst_sram_addr <= 32'b0;
            inst_sram_size <= 2'b0;
            flag <= 32'h201;
        end

        if (flag == 32'h201) begin
            flag <= 32'h1;
        end

    end
    
end

endmodule