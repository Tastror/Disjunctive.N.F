`timescale 1ns / 1ps

module inst_ram_interface(
    // global input
    input wire clk,
    input wire reset,
    input wire enable,

    // input data (face to CACHE)
    input wire inst_interface_call_begin,
    input wire [31:0] inst_interface_addr,

    // output data (face to CACHE)
    output reg inst_interface_return_ready,
    output reg [31:0] inst_interface_rdata,

    // read address (face to AXI)
    output reg [3:0] ARID,
    output reg [31:0] ARADDR,
    output reg [7:0] ARLEN,
    output reg [2:0] ARSIZE,
    output reg [1:0] ARBURST,
    output reg [1:0] ARLOCK,
    output reg [3:0] ARCACHE,
    output reg [2:0] ARPROT,
    output reg ARVALID,
    input wire ARREADY,

    // read response (face to AXI)
    input wire [3:0] RID,
    input wire [31:0] RDATA,
    input wire [1:0] RRESP,
    input wire RLAST,
    input wire RVALID,
    output reg RREADY
);

reg [31:0] flag;
// flag:
// 0 after reset
// 1 (== h301) is reading first time
// h301 and ARREADY is not 1 (shake failed)
// h201 (== h302) and ARREADY is 1 (shake success). send address success
// h302 after shake and RVALID is not 1 (received failed)
// h202 (== reset) after shake and RVALID is 1 (received success). receiving read data success

always @(posedge clk) begin

    if (reset) begin
        flag <= 32'h0;
        ARID <= 4'h0;
        ARADDR <= 32'h0;
        ARLEN <= 8'h0;
        ARSIZE <= 3'h0;
        ARBURST <= 2'h0;
        ARLOCK <= 2'h0;
        ARCACHE <= 4'h0;
        ARPROT <= 3'h0;
        ARVALID <= 1'h0;
        RREADY <= 1'h0;
        inst_interface_return_ready <= 1'b0;
        inst_interface_rdata <= 32'h0;
    end

    else if (~enable) begin
        // do nothing
    end

    else begin

        // read

        if (flag == 32'h0 && inst_interface_call_begin) begin
            flag <= 32'h1;
            ARID <= 4'h0;
            ARADDR <= inst_interface_addr;
            ARSIZE <= 3'h4;
            ARBURST <= 2'h1;
            ARVALID <= 1'h1;
            RREADY <= 1'h0;
        end

        if ((flag == 32'h1 || flag == 32'h301) && ~ARREADY) begin
            flag <= 32'h301;
        end

        if ((flag == 32'h1 || flag == 32'h301) && ARREADY) begin
            flag <= 32'h201;
            ARID <= 4'h0;
            ARADDR <= 32'h0;
            ARSIZE <= 3'h0;
            ARBURST <= 2'h0;
            ARVALID <= 1'h0;
            RREADY <= 1'h0;
        end

        if ((flag == 32'h201 || flag == 32'h302) && (~RVALID || RID != 4'h0)) begin
            flag <= 32'h302;
        end

        if ((flag == 32'h201 || flag == 32'h302) && RVALID && RID == 4'h0) begin
            flag <= 32'h202;
            inst_interface_return_ready <= 1'h1;
            inst_interface_rdata <= RDATA;
            RREADY <= 1'h1;
        end

        if (flag == 32'h202) begin
            flag <= 32'h0;
            inst_interface_return_ready <= 1'h0;
            inst_interface_rdata <= 32'h0;
            RREADY <= 1'h0;
        end

    end
    
end

endmodule