// ¼Ä´æÆ÷¶Ñ

module regs(
    //input
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire [4:0] raddr1,
    input wire [4:0] raddr2,
    input wire [4:0] raddr3,
    //output
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    output wire [31:0] rdata3
);

reg [31:0] registers [0:31];

always @ (posedge clk) begin
    if(!rst_n) begin
        registers[0] <= 32'b0;
        registers[1] <= 32'b0;
        registers[2] <= 32'b0;
        registers[3] <= 32'b0;
        registers[4] <= 32'b0;
        registers[5] <= 32'b0;
        registers[6] <= 32'b0;
        registers[7] <= 32'b0;
        registers[8] <= 32'b0;
        registers[9] <= 32'b0;
        registers[10] <= 32'b0;
        registers[11] <= 32'b0;
        registers[12] <= 32'b0;
        registers[13] <= 32'b0;
        registers[14] <= 32'b0;
        registers[15] <= 32'b0;
        registers[16] <= 32'b0;
        registers[17] <= 32'b0;
        registers[18] <= 32'b0;
        registers[19] <= 32'b0;
        registers[20] <= 32'b0;
        registers[21] <= 32'b0;
        registers[22] <= 32'b0;
        registers[23] <= 32'b0;
        registers[24] <= 32'b0;
        registers[25] <= 32'b0;
        registers[26] <= 32'b0;
        registers[27] <= 32'b0;
        registers[28] <= 32'b0;
        registers[29] <= 32'b0;
        registers[30] <= 32'b0;
        registers[31] <= 32'b0;
    end
    else if (we && waddr != 5'h0) begin
        registers[waddr] <= wdata;
    end
end

wire ans1, ans2, ans3;
assign ans1 = (raddr1 == waddr) & we;
assign rdata1 = registers[raddr1] & {32{~ans1}} | wdata & {32{ans1}};
assign ans2 = (raddr2 == waddr) & we;
assign rdata2 = registers[raddr2] & {32{~ans2}} | wdata & {32{ans2}};
assign ans3 = (raddr3 == waddr) & we;
assign rdata3 = registers[raddr3] & {32{~ans3}} | wdata & {32{ans3}};

endmodule