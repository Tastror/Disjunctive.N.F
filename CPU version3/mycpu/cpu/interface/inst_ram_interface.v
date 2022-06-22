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
reg [31:0] this_time_pc_reg;

assign this_time_pc = this_time_pc_reg;
assign interface_instruction = RDATA;
assign cache_wait_stop_choke = (flag == 32'h200 || flag == 32'h301) && RVALID ? 1'b0 : 1'b1;


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
        ARVALID <= 0;
        RREADY <= 0;
        // flag:
        // 0 reset and ready to send
        // 1 is sending first time
        // flag is 2 or h300, and ARREADY is 1 (shake failed)
        // flag is 2 or h300, and ARREADY is not 1 (shake success). receiving first time
        // h301 after shake and RVALID is not 1 (received failed)
        // h201 after shake and RVALID is 1 (received success), and is sending first time
    end

    else if (~enable) begin
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
            RREADY <= 1'h0;
        end

        if (flag == 32'h1) begin
            flag <= 32'h2;
            ARID <= 4'h0;
            ARADDR <= interface_PC;
            this_time_pc_reg <= interface_PC;
            ARSIZE <= 3'h4;
            ARBURST <= 2'h1;
            ARVALID <= 1'h1;
            RREADY <= 1'h0;
        end

        if ((flag == 32'h2 || flag == 32'h300) && ~ARREADY) begin
            flag <= 32'h300;
        end

        if ((flag == 32'h2 || flag == 32'h300) && ARREADY) begin
            flag <= 32'h200;
            ARID <= 4'h0;
            ARADDR <= 32'h0;
            ARSIZE <= 3'h0;
            ARBURST <= 2'h0;
            ARVALID <= 1'h0;
            RREADY <= 1'h0;
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