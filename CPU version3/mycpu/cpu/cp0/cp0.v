`timescale 1ns / 1ps



module cp0(
    //input
    input wire clk,
    input wire rst,
    input wire enable,
    input wire [3:0] wen,
    input wire [31:0] EntryHi_wdata,
    input wire [31:0] EntryLo0_wdata,
    input wire [31:0] EntryLo1_wdata,
    input wire [31:0] IndexReg_wdata,
    //output
    output wire [18:0] VPN2,
    output wire [7:0] ASID,
    output wire [19:0] PFN0,
    output wire [19:0] PFN1,
    output wire [2:0] C0,
    output wire [2:0] C1,
    output wire D0,
    output wire D1,
    output wire V0,
    output wire V1,
    output wire G0,
    output wire G1,
    output wire [30:0] Index
);

always @ (posedge clk) begin
    if (rst) begin
        EntryHi <= 32'h0;
        EntryLo0 <= 32'h0;
        EntryLo1 <= 32'h0;
        IndexReg <= 32'h0;
    end
    else if (~enable) begin
        // pass
    end
    else begin
        if (wen[3])
            EntryHi <= EntryHi_wdata;
        if (wen[2])
            EntryLo0 <= EntryLo0_wdata;
        if (wen[1])
            EntryLo1 <= EntryLo1_wdata;
        if (wen[0])
            IndexReg <= IndexReg_wdata;
    end
end

reg [31:0] EntryHi, EntryLo0, EntryLo1, IndexReg;
wire [18:0] VPN2;
wire [7:0] ASID;
wire [19:0] PFN0, PFN1;
wire [2:0] C0, C1;
wire D0, D1, V0, V1, G0, G1, P;
wire [30:0] Index;

assign VPN2 = EntryHi[31:13];
assign ASID = EntryHi[7:0];
assign PFN0 = EntryLo0[25:6];
assign PFN1 = EntryLo1[25:6];
assign C0 = EntryLo0[5:3];
assign C1 = EntryLo1[5:3];
assign D0 = EntryLo0[2];
assign D1 = EntryLo1[2];
assign V0 = EntryLo0[1];
assign V1 = EntryLo1[1];
assign G0 = EntryLo0[0];
assign G1 = EntryLo1[0];
assign Index = IndexReg[30:0];


endmodule