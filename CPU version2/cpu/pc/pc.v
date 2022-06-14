`timescale 1ns / 1ps



module pc_if_first(
    // input
    input wire ME_clt_pc_first_mux,
    input wire ME_pc_first_mux,
    input wire [31:0] IF_last_pc,
    input wire [31:0] ME_pc,
    // output
    output wire [31:0] pc_plus_4_or_mem
);

wire temp;
assign temp = ME_clt_pc_first_mux & ME_pc_first_mux;
assign pc_plus_4_or_mem = ME_pc & {32{temp}} | (IF_last_pc + 32'd4) & {32{~temp}};

endmodule



module pc_if_second_reg(

    input wire reset,
    input wire clk,

    // input
    input wire [3:0] EX_ctl_pc_second_mux,

    input wire [31:0] pc_plus_4_or_mem,
    input wire [31:0] ME_imm_32,
    input wire [31:0] ME_rs_data,
    
    // output
    output wire [31:0] IF_pc_out,
    output wire [31:0] IF_pc_plus_4
);

parameter PC_INITIAL = 32'hbfc00000;
parameter PC_BREAK = 32'hbfc00380;

reg [31:0] pc;
wire [31:0] pc_next;

assign IF_pc_out = pc;
assign IF_pc_plus_4 = pc + 32'd4;
assign pc_next =
    pc_plus_4_or_mem & {32{EX_ctl_pc_second_mux[0]}} |
    {{pc[31:28]}, {ME_imm_32[15:0]}, {2'b00}} & {32{EX_ctl_pc_second_mux[1]}} |
    ME_rs_data & {32{EX_ctl_pc_second_mux[2]}} |
    PC_BREAK & {32{EX_ctl_pc_second_mux[3]}};

always @ (posedge clk) begin
    pc <= pc_next & {32{~reset}} | PC_INITIAL & {32{reset}};
end

endmodule



module pc_ex(
    // input
    input wire [31:0] pc_in_ex,
    input wire [31:0] imm_32_in_ex,
    // output
    output wire [31:0] pc_to_mem
);
assign pc_to_mem = pc_in_ex + {imm_32_in_ex[29:0], 2'h0};
endmodule



module pc_mem(
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