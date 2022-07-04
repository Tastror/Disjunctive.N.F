`timescale 1ns / 1ps



module cp0(
    // input
    input wire clk,
    input wire rst,
    input wire enable,
    // input (face to normal CPU)
    input wire [31:0] pc,
    input wire read,
    input wire write,
    input wire eret,
    input wire exception,
    input wire [2:0] sel,
    input wire [4:0] rd,
    input wire [31:0] rt_data,
    input wire [4:0] cp0_exception_code,
    // input (face to TLB)
    input wire [3:0] wen,
    input wire [31:0] EntryHi_wdata,
    input wire [31:0] EntryLo0_wdata,
    input wire [31:0] EntryLo1_wdata,
    input wire [31:0] IndexReg_wdata,
    // output (face to normal CPU)
    output wire [31:0] CP0_rdata,
    output wire T1,
    output wire reset_other,
    output wire [31:0] recover_pc,
    // output (face to TLB)
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
    

// Normal CPU

reg [31:0]
    IndexReg, EntryLo0, EntryLo1, BadVAddr,
    Count, EntryHi, Compare, Status, Cause,
    EPC, ConfigReg, ConfigReg1;

reg flag;

assign T1 = Cause[30];
assign recover_pc = EPC;


// TLB

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



always @ (posedge clk) begin

    if (rst) begin
        flag <= 0;
        IndexReg <= 32'h0;
        EntryLo0 <= 32'h0;
        EntryLo1 <= 32'h0;
        BadVAddr <= 32'h0;
        Count <= 32'h0;
        EntryHi <= 32'h0;
        Compare <= 32'h0;
        Status <= 32'b00000000_01000000_00000000_00000000;
        Cause <= 32'h0;
        EPC <= 32'h0;
        ConfigReg <= 32'h0;
        ConfigReg1 <= 32'h0;
    end

    else if (~enable) begin
        // pass
    end

    else begin

        if (|pc) begin
            if (flag <= 0) begin
                flag <= 1;
            end
            if (flag <= 1) begin
                Count <= Count + 32'b1;
                flag <= 0;
            end
        end

        if (write) begin
            if (rd == 5'd0 && sel == 3'd0)
                IndexReg[30:0] <= rt_data[30:0];
            else if (rd == 5'd2 && sel == 3'd0)
                EntryLo0[25:0] <= rt_data[25:0];
            else if (rd == 5'd3 && sel == 3'd0)
                EntryLo1[25:0] <= rt_data[25:0];
            else if (rd == 5'd8 && sel == 3'd0)
                ; // BadVAddr not enable to write
            else if (rd == 5'd9 && sel == 3'd0) 
                Count <= rt_data;
            else if (rd == 5'd10 && sel == 3'd0) begin
                EntryHi[31:13] <= rt_data[31:13];
                EntryHi[7:0] <= rt_data[7:0];
            end
            else if (rd == 5'd11 && sel == 3'd0) begin
                Cause[30] <= 1'b0;
                Compare <= rt_data;
            end
            else if (rd == 5'd12 && sel == 3'd0) begin
                Status[15:8] <= rt_data[15:8];
                Status[1:0] <= rt_data[1:0];
            end
            else if (rd == 5'd13 && sel == 3'd0) begin
                Cause[9:8] <= rt_data[9:8];
            end
            else if (rd == 5'd14 && sel == 3'd0)
                EPC <= rt_data;
            else if (rd == 5'd16 && sel == 3'd0)
                ConfigReg[2:0] <= rt_data[2:0];
            else if (rd == 5'd16 && sel == 3'd1)
                ; // ConfigReg1 not enable to write
        end

        if (wen[3])
            EntryHi <= EntryHi_wdata;
        if (wen[2])
            EntryLo0 <= EntryLo0_wdata;
        if (wen[1])
            EntryLo1 <= EntryLo1_wdata;
        if (wen[0])
            IndexReg <= IndexReg_wdata;

        if (~(write && rd == 5'd11 && sel == 3'd0)) begin
            Cause[30] = (Count == Compare);
        end

        if (eret) begin
            IndexReg[31] <= 0;
            EntryLo0[30:26] <= 0;
            EntryLo1[30:26] <= 0;
            EntryHi[12:8] <= 0;
            Status[31:23] <= 0;
            Status[22] <= 1'b1;
            Status[27:16] <= 0;
            Status[7:0] <= 0;
            Cause <= 0;
            ConfigReg[31] <= 1'b1;
            ConfigReg[30:8] <= 0;
            ConfigReg[7] <= 1'b1;
            ConfigReg[6:2] <= 0;
            ConfigReg[1] <= 1'b1;
            ConfigReg[0] <= 0;
            ConfigReg1[31] <= 1'b1;
            ConfigReg1[21:19] <= 3'h4;
            ConfigReg1[12:10] <= 3'h4;
            ConfigReg[6:0] <= 0;
        end

        if (exception) begin
            Cause[6:2] = cp0_exception_code[4:0];
            if (Status[1] == 1'b0) begin
                EPC <= pc;
                Status[1] <= 1'b1;
            end
        end

    end
end

assign use_IndexReg = (rd == 5'd0 & sel == 3'd0) & read;
assign use_EntryLo0 = (rd == 5'd2 & sel == 3'd0) & read;
assign use_EntryLo1 = (rd == 5'd3 & sel == 3'd0) & read;
assign use_BadVAddr = (rd == 5'd8 & sel == 3'd0) & read;
assign use_Count = (rd == 5'd9 & sel == 3'd0) & read;
assign use_EntryHi = (rd == 5'd10 & sel == 3'd0) & read;
assign use_Compare = (rd == 5'd11 & sel == 3'd0) & read;
assign use_Status = (rd == 5'd12 & sel == 3'd0) & read;
assign use_Cause = (rd == 5'd13 & sel == 3'd0) & read;
assign use_EPC = (rd == 5'd14 & sel == 3'd0) & read;
assign use_ConfigReg = (rd == 5'd16 & sel == 3'd0) & read;
assign use_ConfigReg1 = (rd == 5'd16 & sel == 3'd1) & read;

assign CP0_rdata =
    {32{use_IndexReg}} & IndexReg |
    {32{use_EntryLo0}} & EntryLo0 |
    {32{use_EntryLo1}} & EntryLo1 |
    {32{use_BadVAddr}} & BadVAddr |
    {32{use_Count}} & Count |
    {32{use_EntryHi}} & EntryHi |
    {32{use_Compare}} & Compare |
    {32{use_Status}} & Status |
    {32{use_Cause}} & Cause |
    {32{use_EPC}} & EPC |
    {32{use_ConfigReg}} & ConfigReg |
    {32{use_ConfigReg1}} & ConfigReg1
;

endmodule