`timescale 1ns/1ps

module pc(
    input wire clk,
    input wire rst_n,
    input wire wait_stop_choke,
    output wire [31:0] pc_res
);

parameter PC_INITIAL = 32'hbfc00000;
reg [31:0] next_pc;

assign pc_res = next_pc;

always @(posedge clk) begin
    if (!rst_n)
        next_pc <= PC_INITIAL;
    else begin
        next_pc <= (pc_res + 32'd4) & {32{~wait_stop_choke}} | next_pc & {32{wait_stop_choke}} ;
    end
end

endmodule