`timescale 1ns / 1ps

module inst_ram_interface(
    // input (face to all)
    input wire clk,
    input wire reset,

    // input data (face to CACHE)
    input wire enable,
    input wire [31:0] interface_PC,

    // output data (face to CACHE)
    output wire [31:0] this_time_pc,
    output wire [31:0] interface_instruction,
    output wire cache_wait_stop_choke,

    // read address (face to AXI)
    output wire [3:0] ARID,
    output wire [31:0] ARADDR,
    output wire [7:0] ARLEN,
    output wire [2:0] ARSIZE,
    output wire [1:0] ARBURST,
    output wire [1:0] ARLOCK,
    output wire [3:0] ARCACHE,
    output wire [2:0] ARPROT,
    output wire ARVALID,
    input wire ARREADY,

    // read response (face to AXI)
    input wire [3:0] RID,
    input wire [31:0] RDATA,
    input wire [1:0] RRESP,
    input wire RLAST,
    input wire RVALID,
    output wire RREADY
);


reg [31:0] flag;
reg [31:0] this_time_pc_reg;


assign this_time_pc = this_time_pc_reg;
assign interface_instruction = RDATA;
assign cache_wait_stop_choke = (RVALID && (flag == 32'h200 || flag == 32'h301)) ? 1'b0 : 1'b1;


always @(posedge clk) begin

    if (reset) begin
        ARID <= 4'h0;
        ARADDR <= 32'h0;
        ARLEN <= 8'h0;
        ARSIZE <= 3'h0;
        ARBURST <= 2'h0;
        ARLOCK <= 2'h0;
        ARCACHE <= 4'h0;
        ARPROT <= 3'h0;
        ARVALID <= 0;
        RREADY <= 0;
        // flag:
        // 0 reset and ready to send
        // 1 is sending first time
        // h300 req is 1 and see addr_ok be 1 (shake failed)
        // h200 req is 1 but addr_ok not 1 (shake success), and is receiving first time
        // h301 after shake and inst_sram_data_ok is not 1 (received failed)
        // h201 after shake and inst_sram_data_ok is 1 (received success), and is sending first time
    end

    else if (~enbale) begin
        // do nothing
    end

    else begin

        if (flag == 32'h0) begin
            flag <= 32'h1;
            ARID <= 4'h0;
            ARADDR <= interface_PC;
            this_time_pc_reg <= interface_PC;
            ARSIZE <= 3'h4;
            ARBURST <= 2'h1;
            ARVALID <= 1'h1;
        end

        if ((flag == 32'h1 || flag == 32'h300) && ~ARREADY) begin
            flag <= 32'h300;
        end

        if ((flag == 32'h1 || flag == 32'h300) && ARREADY) begin
            flag <= 32'h200;
            ARID <= 4'h0;
            ARADDR <= 32'h0;
            ARSIZE <= 3'h0;
            ARBURST <= 2'h0;
            ARVALID <= 1'h0;
        end

        if ((flag == 32'h200 || flag == 32'h301) && ~RVALID) begin
            flag <= 32'h301;
        end

        if ((flag == 32'h200 || flag == 32'h301) && RVALID) begin
            flag <= 32'h201;
            RREADY <= 1'h1;
        end

        if (flag == 32'h201) begin
            flag <= 32'h1;
            RREADY <= 1'h0;
        end

    end
    
end

endmodule