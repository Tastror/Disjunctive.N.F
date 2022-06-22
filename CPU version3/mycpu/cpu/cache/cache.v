`timescale 1ns / 1ps

module inst_cache(
    // input (face to all)
    input wire clk,
    input wire reset,

    // input (face to CPU)
    input wire [31:0] PC,

    // output (face to CPU)
    output wire [31:0] instruction,
    output wire pc_wait_stop_choke,

    // output (face to interface)
    output wire interface_enable,
    output wire [31:0] interface_PC,

    // input (face to interface)
    input wire [31:0] this_time_pc,
    input wire [31:0] interface_instruction,
    input wire cache_wait_stop_choke
);

// 256KB inst_data_reg, show less 16 bits
// use pc[17:2] to search
reg [31:0] inst_data_reg [0:65535];
// 128KB name, store {{pc[31:18]}, {pc[1:0]}}
reg [15:0] name [0:65535];
integer i;


always @ (posedge clk) begin
    if (reset) begin
        for (i = 0; i < 65536; i = i + 1) begin
            name[i] <= 16'h0;
        end
    end
    else if (~cache_wait_stop_choke) begin
        name[this_time_pc[17:2]] <= {{this_time_pc[31:18]}, {this_time_pc[1:0]}};
        inst_data_reg[this_time_pc[17:2]] <= instruction;
    end
end

assign interface_PC = PC;
assign interface_enable = (name[PC[17:2]] == {{PC[31:18]}, {PC[1:0]}}) ? 1'b0 : 1'b1;
assign pc_wait_stop_choke = interface_enable ? cache_wait_stop_choke : 1'b0;
assign instruction = interface_enable ? interface_instruction : inst_data_reg[PC[17:2]];

endmodule