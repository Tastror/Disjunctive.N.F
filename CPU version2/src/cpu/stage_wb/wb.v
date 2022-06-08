module wb(
    // output
    reg_we,//reg写使能
    reg_data,//要写入的数据
    reg_addr,//要写入的寄存器地址
    // input
    wb_wdata,
    wb_waddr,
    MemToReg
);

wire reg_we;
wire [31:0] reg_data;
wire [31:0] reg_addr;

wire [31:0] wb_waddr;
wire [31:0] wb_wdata;

assign reg_addr = wb_waddr;
assign reg_data = wb_wdata;

assign reg_we = MemToReg;

endmodule