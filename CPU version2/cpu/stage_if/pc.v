// module pc (
//     // output
//     pc_reg,
//     // input
//     rst_n,
//     clk,
//     enable,
//     branch_address,
//     is_branch,
//     is_exception,
//     exception_new_pc,
//     is_debug,
//     debug_new_pc,
//     debug_reset
// );

// parameter PC_INITIAL = 32'hbfc00000;

// // ???????
// input wire rst_n;
// input wire clk;
// input wire enable;

// // 
// input wire[31:0] branch_address;
// input wire is_branch;
// input wire is_exception;
// input wire[31:0] exception_new_pc;
// input wire is_debug;
// input wire[31:0] debug_new_pc;
// input wire debug_reset;

// // 
// reg[31:0] pc_next;
// output reg[31:0] pc_reg;

// // ???????????pc_reg
// always @(*) begin
//     if (!rst_n || debug_reset) begin
//         pc_next <= PC_INITIAL;
//     end
//     else if(enable) begin
//         // ????,??,????,???????4
//         pc_next <= is_debug ? debug_new_pc :
//                          is_exception ? exception_new_pc :
//                          is_branch ? branch_address :
//                          pc_reg + 32'd4;
        
//     end else begin 
//         // ???????
//         pc_next <= pc_reg;
//     end
// end

// // ?????????????pc_reg
// always @(posedge clk) 
//     pc_reg <= pc_next;
    
// endmodule



module pc_in_if(
    input wire reset,
    input wire clk,
    // input
    input wire [31:0] pc_from_mem,
    input wire pc_init_control,
    // output
    output wire [31:0] pc_out,
    output wire [31:0] pc_plus_4
);
parameter PC_INITIAL = 32'hbfc00000;

reg [31:0] pc;
wire [31:0] pc_next;

assign pc_out = pc;
assign pc_plus_4 = pc + 32'd4;
assign pc_next = pc_from_mem & {32{pc_init_control}} | pc_plus_4 & {32{~pc_init_control}};

always @ (posedge clk) begin
    pc <= pc_next & {32{~reset}} | PC_INITIAL & {32{reset}};
end

endmodule



module pc_in_ex(
    // input
    input wire [31:0] pc_in_ex,
    input wire [15:0] imm_in_ex,
    // output
    output wire [31:0] pc_to_mem
);
assign pc_to_mem = pc_in_ex + {imm_in_ex, 2'h0};
endmodule



module pc_in_mem(
    // input
    input wire [31:0] pc_in_mem,
    input wire [31:0] alu_res_in_mem,
    // output
    output wire pc_init_control
);
assign pc_init_control = 0;
endmodule



module pc_in_wb();
endmodule