`timescale 1ns / 1ps

module data_ram_interface(
    // global input
    input wire clk,
    input wire reset,
    input wire enable,

    // input data (face to CACHE)
    input wire write_enable,
    input wire [2:0] read_size,
    input wire [2:0] write_size,
    input wire [31:0] data_interface_raddr,
    input wire [31:0] data_interface_waddr,
    input wire [31:0] data_interface_wdata,
    input wire data_interface_call_begin,

    // output data (face to CACHE)
    output reg data_interface_return_ready,
    output reg [31:0] data_interface_rdata,

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
    output reg RREADY,

    // write address (face to AXI)
    output reg [3:0] AWID,
    output reg [31:0] AWADDR,
    output reg [7:0] AWLEN,
    output reg [2:0] AWSIZE,
    output reg [1:0] AWBURST,
    output reg [1:0] AWLOCK,
    output reg [3:0] AWCACHE,
    output reg [2:0] AWPROT,
    output reg AWVALID,
    input wire AWREADY,

    // write data (face to AXI)
    output reg [3:0] WID,
    output reg [31:0] WDATA,
    output reg [3:0] WSTRB,
    output reg WLAST,
    output reg WVALID,
    input wire WREADY,

    // write response (face to AXI)
    input wire [3:0] BID,
    input wire [1:0] BRESP,
    input wire BVALID,
    output reg BREADY
);


reg [31:0] flag;

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

        AWID <= 4'h0;
        AWADDR <= 32'h0;
        AWLEN <= 8'h0;
        AWSIZE <= 3'h0;
        AWBURST <= 2'h0;
        AWLOCK <= 2'h0;
        AWCACHE <= 4'h0;
        AWPROT <= 3'h0;
        AWVALID <= 1'h0;

        WID <= 4'h0;
        WDATA <= 32'h0;
        WSTRB <= 4'h0;
        WLAST <= 1'h0;
        WVALID <= 1'h0;

        BREADY <= 1'h0;

        data_interface_return_ready <= 1'b0;
        data_interface_rdata <= 32'b0;

        // flag:
        // 0 after reset, and is ready to read / write
        
        // 1 (== h301) is reading first time
        // h301 and ARREADY is not 1 (shake failed)
        // h201 (== h302) and ARREADY is 1 (shake success). send address success
        // h302 after shake and RVALID is not 1 (received failed)
        // h202 (== reset) after shake and RVALID is 1 (received success). receiving read data success

        // 3 (== h303) is send writing address first time
        // h303 and AWREADY is 1 (shake failed)
        // h203 (== h304) and AWREADY is not 1 (shake success). send writing address success
        // h304 and WREADY is not 1 (shake failed)
        // h204 (== h305) and WREADY is 1 (shake success). send writing data success
        // h305 after shake and BVALID is not 1 (received failed)
        // h205 (== reset) after shake and BVALID is 1 (received success). all end
    end

    else if (~enable) begin
        // do nothing
    end

    else begin

        // read

        if (flag == 32'h0 && ~write_enable && data_interface_call_begin) begin
            flag <= 32'h1;
            ARID <= 4'h1;
            ARADDR <= data_interface_raddr;
            ARSIZE <= read_size;
            ARBURST <= 2'h1;
            ARVALID <= 1'h1;
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
        end

        if ((flag == 32'h201 || flag == 32'h302) && (~RVALID || RID != 4'h1)) begin
            flag <= 32'h302;
        end

        if ((flag == 32'h201 || flag == 32'h302) && RVALID && RID == 4'h1) begin
            flag <= 32'h202;
            data_interface_return_ready <= 1'b1;
            data_interface_rdata <= RDATA;
            RREADY <= 1'h1;
        end

        if (flag == 32'h202) begin
            flag <= 32'h0;
            data_interface_return_ready <= 1'b0;
            data_interface_rdata <= 32'h0;
            RREADY <= 0;
        end


        // write

        if (flag == 32'h0 && write_enable && data_interface_call_begin) begin
            flag <= 32'h3;
            AWID <= 4'h1;
            AWADDR <= data_interface_waddr;
            AWSIZE <= write_size;
            AWBURST <= 2'h1;
            AWVALID <= 1'h1;
        end

        if ((flag == 32'h3 || flag == 32'h303) && ~AWREADY) begin
            flag <= 32'h303;
        end

        if ((flag == 32'h3 || flag == 32'h303) && AWREADY) begin
            flag <= 32'h203;
            AWID <= 4'h0;
            AWADDR <= 0;
            AWSIZE <= 0;
            AWBURST <= 2'h0;
            AWVALID <= 1'h0;
            WID <= 4'h1;
            WDATA <= data_interface_wdata;
            WSTRB <= 4'b1111;
            WLAST <= 1'h1;
            WVALID <= 1'h1;
        end

        if ((flag == 32'h203 || flag == 32'h304) && ~WREADY) begin
            flag <= 32'h304;
        end

        if ((flag == 32'h203 || flag == 32'h304) && WREADY) begin
            flag <= 32'h204;
            WID <= 4'h0;
            WDATA <= 32'h0;
            WSTRB <= 4'h0;
            WLAST <= 1'h0;
            WVALID <= 1'h0;
            data_interface_return_ready <= 1'b1;
        end

        if (flag == 32'h204) begin
            flag <= 32'h0;
            data_interface_return_ready <= 1'b0;
        end

        // if ((flag == 32'h204 || flag == 32'h305) && ~BVALID) begin
        //     flag <= 32'h305;
        // end

        // if ((flag == 32'h204 || flag == 32'h305) && BVALID) begin
        //     flag <= 32'h205;
        //     data_interface_return_ready <= 1'b1;
        //     BREADY <= 1;
        // end

        // if (flag == 32'h205) begin
        //     flag <= 32'h0;
        //     data_interface_return_ready <= 1'b0;
        //     BREADY <= 0;
        // end

    end
    
end

endmodule