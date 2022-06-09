module wb(
    // output
    reg_we,//regåä½¿è?
    reg_data,//è¦åå¥çæ°æ®
    reg_addr,//è¦åå¥çå¯å­å¨å°å?
    // input
    wb_wdata,
    wb_waddr,
    MemToReg
);

output reg reg_we;
output reg [31:0] reg_data;
output reg [31:0] reg_addr;

input wire [31:0] wb_waddr;
input wire [31:0] wb_wdata;
input wire MemToReg;

always @(*) begin
    assign reg_addr = wb_waddr;
    assign reg_data = wb_wdata;
    
    assign reg_we = MemToReg;
end

endmodule