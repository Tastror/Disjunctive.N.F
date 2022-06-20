`timescale 1ns / 1ps

module inst_cache(
    // input
    input wire clk,
    input wire reset,
    input wire inst_sram_addr_ok,
    input wire inst_sram_data_ok,
    input wire [31:0] inst_sram_rdata,
    input wire [31:0] pc,

    // output
    output wire inst_sram_req,
    output wire inst_sram_wr,
    output wire [1:0] inst_sram_size,
    output wire [3:0] inst_sram_wstrb,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata,
    output wire pc_wait_stop_choke,
    output wire [31:0] IF_instruction
);

// 256KB inst_data_reg, show less 16 bits
// use pc[17:2] to search
reg [31:0] inst_data_reg [0:65535];
// 128KB name, store {{pc[31:18]}, {pc[1:0]}}
reg [15:0] name [0:65535];

reg [31:0] this_time_pc;

wire [31:0] temp_IF_instruction;
wire temp_pc_wait_stop_choke;

inst_ram_interface inst_ram_interface_1(
    // input
    .reset(reset), .clk(clk),
    .pc(pc),
    .inst_sram_addr_ok(inst_sram_addr_ok), .inst_sram_data_ok(inst_sram_data_ok), .inst_sram_rdata(inst_sram_rdata),
    // output (to SRAM)
    .inst_sram_req(inst_sram_req), .inst_sram_wr(inst_sram_wr), .inst_sram_size(inst_sram_size),
    .inst_sram_wstrb(inst_sram_wstrb), .inst_sram_addr(inst_sram_addr), .inst_sram_wdata(inst_sram_wdata),
    // output (to CPU)
    .pc_wait_stop_choke(temp_pc_wait_stop_choke), .IF_instruction(temp_IF_instruction), .this_time_pc(this_time_pc)
);

always @ (posedge clk) begin
    if (reset) begin
        name[0:65535] <= 0;
    end
    else if (inst_sram_data_ok) begin
        name[this_time_pc[17:2]] <= {{this_time_pc[31:18]}, {this_time_pc[1:0]}};
        inst_data_reg[this_time_pc[17:2]] <= temp_IF_instruction;
    end
end

assign pc_wait_stop_choke = (name[pc[17:2]] == {{pc[31:18]}, {pc[1:0]}}) ? 1'b0 : temp_pc_wait_stop_choke;
assign IF_instruction = (name[pc[17:2]] == {{pc[31:16]}, {pc[1:0]}}) ? inst_data_reg[pc[17:2]] : temp_IF_instruction;

endmodule