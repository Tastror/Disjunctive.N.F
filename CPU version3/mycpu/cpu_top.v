`timescale 1ns/1ps

module mycpu_top (
    input wire ext_int, //init
    input wire aclk,
    input wire aresetn,
    // read request pipe, start with 'ar'
    input wire arready,
    output wire [3:0] arid,
    output wire [31:0] araddr,
    output wire [7:0] arlen, //stay "0"
    output wire [2:0] arsize,
    output wire [1:0] arburst, //stay "2'b01"
    output wire [1:0] arlock, //stay "0"
    output wire [3:0] arcache, //stay "0"
    output wire [2:0] arprot, //stay "0"
    output wire arvalid,
    // read response pipe, start with 'r'
    input wire [3:0] rid,
    input wire [31:0] rdata,
    input wire [1:0] rresp, //ignore
    input wire rlast, //ignore
    input wire rvalid,
    output wire rready,
    // write request pipe, start with 'aw'
    input wire awready,
    output wire [3:0] awid,
    output wire [31:0] awaddr,
    output wire [7:0] awlen, //stay "0"
    output wire [2:0] awsize,
    output wire [1:0] awburst, //stay "0"
    output wire [1:0] awlock, //stay "0"
    output wire [3:0] awcache, //stay "0"
    output wire [2:0] awprot,
    output wire awvalid,
    // write data pipe, start with "w"
    input wire [3:0] wid, // stay "1"
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    input wire wlast, //stay "1"
    input wire wvalid,
    output wire wready,
    // write response pipe, start with "b"
    input wire [3:0] bid, //ignore
    input wire [1:0] bresp, //ignore
    input wire bvalid,
    output wire bready,

    // debug interface
    output wire [31:0] debug_wb_pc,
    output wire [3:0] debug_wb_rf_wen,
    output wire [4:0] debug_wb_rf_wnum,
    output wire [31:0] debug_wb_rf_wdata
);

CPU CPU_0(
    // basic
    .ACLK(aclk),
    .ARESTn(aresetn),
    // write address
    .AWID(awid),
    .AWADDR(awaddr),
    .AWLEN(awlen),
    .AWSIZE(awsize),
    .AWBURST(awburst),
    .AWLOCK(awlock),
    .AWCACHE(awcache),
    .AWPROT(awprot),
    .AWVALID(awvalid),
    .AWREADY(awready),
    // write data
    .WID(wid),
    .WDATA(wdata),
    .WSTRB(wstrb),
    .WLAST(wlast),
    .WVALID(wvalid),
    .WREADY(wready),
    // write response
    .BID(bid),
    .BRESP(bresp),
    .BVALID(bvalid),
    .BREADY(bready),
    // read address
    .ARID(arid),
    .ARADDR(araddr),
    .ARLEN(arlen),
    .ARSIZE(arsize),
    .ARBURST(arburst),
    .ARLOCK(arlock),
    .ARCACHE(arcache),
    .ARPROT(arprot),
    .ARVALID(arvalid),
    .ARREADY(arready),
    // read response
    .RID(rid),
    .RDATA(rdata),
    .RRESP(rresp),
    .RLAST(rlast),
    .RVALID(rvalid),
    .RREADY(rready),

    .debug_wb_pc(debug_wb_pc),
    .debug_wb_rf_wen(debug_wb_rf_wen),
    .debug_wb_rf_wnum(debug_wb_rf_wnum),
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

endmodule