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