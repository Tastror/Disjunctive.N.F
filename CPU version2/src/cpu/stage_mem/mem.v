// 该模块与RAMs模块连线，具体操作在RAMs中执行，读到的结果由RAMs返回给WB
// 就是说，RAMs的输入端口由mem控制，输出端口连到WB
// mem相当于是RAM的控制单元，完全组合逻辑

module mem(
    //output
    ram_re,//ram读使能
    ram_we,//ram写使能
    ram_address,//ram读或写的地址
    ram_data,//要写入的data
    //input
    MemRead,
    MemWrite,
    mem_wdata,//要写入的data
    mem_address//地址
);

wire ram_re;
wire ram_we;
wire [31:0] ram_address;
wire [31:0] ram_data;

wire MemRead;
wire MemWrite;
wire mem_wdata;
wire mem_address;

assign ram_address = mem_address;
assign ram_data = mem_wdata;

assign ram_re = MemRead;
assign ram_we = MemWrite;

endmodule