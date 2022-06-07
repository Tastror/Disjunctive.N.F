module pc (
    // output
    pc_reg,
    // input
    rst_n,
    clk,
    enable,
    branch_address,
    is_branch,
    is_exception,
    exception_new_pc,
    is_debug,
    debug_new_pc,
    debug_reset
);

parameter PC_INITIAL = 32'hbfc00000;

// 控制信号
input wire rst_n;
input wire clk;
input wire enable;

// 
input wire[31:0] branch_address;
input wire is_branch;
input wire is_exception;
input wire[31:0] exception_new_pc;
input wire is_debug;
input wire[31:0] debug_new_pc;
input wire debug_reset;

// 
reg[31:0] pc_next;
output reg[31:0] pc_reg;

// 连线，不写入pc_reg
always @(*) begin
    if (!rst_n || debug_reset) begin
        pc_next <= PC_INITIAL;
    end
    else if(enable) begin
        // 测试,异常,旁路,正常加4
        assign pc_next = is_debug ? debug_new_pc :
                         is_exception ? exception_new_pc :
                         is_branch ? branch_address :
                         pc_reg + 32'd4;
        
    end else begin 
        // 保持不变
        pc_next <= pc_reg;
    end
end

// 数据总线，写入pc_reg
always @(posedge clk) 
    pc_reg <= pc_next;
    
endmodule