`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Disjunctive.N.F
// Engineer: Tastror
// 
// Create Date: 2022/05/03 21:43:40
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// ! important !
//
// [name rule]
//     environment (begin with little case):
//         clk, reset, debug, io_show, ...
//     usually (begin with capital):
//         IF_xxx, ID_xxx, EX_xxx, ME_xxx, WB_xxx
//     for variables that changes rapidly:
//         IFb_xxx (IF begin xxx), IFe_xxx (IF end xxx)
//         IDb_xxx (ID begin xxx), IDe_xxx (ID end xxx)
//         ...
//
// [input and output rule]
//     usually:
//         module_name(
//             // input
//             .x1(_x1), ,x2(_x2),
//             // output
//             .x3(_x3), ,x4(_x4)
//         );
//     for reg wait:
//         module_name(
//             .clk(clk),
//             // in-out pair
//             .i1(_x1), ,o1(_y1),
//             .i2(_x2), ,o2(_y2)
//         );
//
// ! important !

module CPU(
    // debug in
    input wire debug,
    input wire inst_ram_write_enable,
    input wire [31:0] inst_ram_write_data,
    input wire [31:0] inst_ram_write_address,
    // normal in
    input wire reset,
    input wire clk,
    // out
    output wire io_show
);

wire ME_pc_control;
wire [31:0] IFe_pc, IFe_pc_plus_4, ID_pc, EXb_pc, EXe_pc, ME_pc;
wire [31:0] IF_instruction, ID_instruction;
wire [15:0] ID_imm, EX_imm;  // imm and offset are the same
wire [5:0] ID_opcode;
wire [5:0] ID_funct;
wire [5:0] ID_rt;
wire [4:0] ID_rs;
wire [4:0] ID_rd;
wire [4:0] ID_sa;  // sa and base are the same
wire [25:0] ID_instIndex;
wire [19:0] ID_code;
wire [2:0] ID_sel;

// wire [4:0] ctl_pcValue_mux; // pcValue: MUX5_32b, [PC+4, aluRes, instIndex, temp, use delaySlot]
// wire ctl_instRam_en;
// wire ctl_instRam_wen;
// wire [2:0] ctl_aluSrc1_mux; // aluSrc1: MUX3_32b, [rs, sa, PC]
// wire [3:0] ctl_aluSrc2_mux; // aluSrc1: MUX4_32b, [rt, imm, {HI}, {LO}]
// wire [8:0] ctl_alu_mux;
// wire ctl_dataRam_en;
// wire ctl_dataRam_wen;
// wire [2:0] ctl_rfWriteData_mux; // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
// wire [2:0] ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
// wire ctl_rf_wen;
// wire ctl_low_wen;  // just use for MTLO, MULT, MULTU to save two 32bits data to low
//                               // when this is enabled, the [Low] and will save data from [aluRes]
// wire ctl_high_wen;  // just use for MTHI, MULT, MULTU to save two 32bits data to high 
//                                // when this is enabled, the [High] and will save data from [aluRes]
// wire ctl_temp_wen;  // JALR, JR

pc_in_if pc_if_0(
    .reset(reset), .clk(clk),
    // input
    .pc_from_mem(ME_pc), .pc_init_control(ME_pc_control),
    // output
    .pc_out(IFe_pc), .pc_plus_4(IFe_pc_plus_4)
);

wire [31:0] IF_pc_or_debug;
assign IF_pc_or_debug = inst_ram_write_address & {32{debug}} | IFe_pc & {32{~debug}};

instruction_RAM inst_RAM_0(
    // debug in
    .write_enable(inst_ram_write_enable), .write_data(inst_ram_write_data),
    // input
    .clk(clk), .pc(IF_pc_or_debug),
    // output
    .instruction(IF_instruction)
);

WaitRegs IF_ID_wait(
    .clk(clk),
    // in-out pair
    .i321(IF_instruction), .o321(ID_instruction),
    .i322(IFe_pc_plus_4), .o322(ID_pc)
);

ID_data id_data_0(
    // in
    .instruction(ID_instruction),
    // out
    .opcode(ID_opcode), .funct(ID_funct), .rs(ID_rs), .rt(ID_rt), .rd(ID_rd),
    .sa(ID_sa), .imm(ID_imm), .instIndex(ID_instIndex), .code(ID_code), .sel(ID_sel)
);

// ID_control ID_control_1(
//     // in
//     .opcode(opcode), .funct(funct), .rt(rt),
//     // out
//     .ctl_pcValue_mux(ctl_pcValue_mux),
//     .ctl_instRam_en(ctl_instRam_en), .ctl_instRam_wen(ctl_instRam_wen),
//     .ctl_aluSrc1_mux(ctl_aluSrc1_mux), .ctl_aluSrc2_mux(ctl_aluSrc2_mux), .ctl_alu_mux(ctl_alu_mux),
//     .ctl_dataRam_en(ctl_dataRam_en), .ctl_dataRam_wen(ctl_dataRam_wen),
//     .ctl_rfWriteData_mux(ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ctl_rfWriteAddr_mux),
//     .ctl_rf_wen(ctl_rf_wen),
//     .ctl_low_wen(ctl_low_wen), .ctl_high_wen(ctl_high_wen), .ctl_temp_wen(ctl_temp_wen)
// );

WaitRegs ID_EXE_wait(
    .clk(clk),
    // in-out pair
    .i161(ID_imm), .o161(EX_imm),
    .i321(ID_pc), .o321(EXb_pc)
);

pc_in_ex pc_ex_0(
    // input
    .pc_in_ex(EXb_pc), .imm_in_ex(EX_imm),
    // output
    .pc_to_mem(EXe_pc)
);

WaitRegs EXE_MEM_wait(
    .clk(clk),
    // in-out pair
    .i321(EXe_pc), .o321(ME_pc)
);

pc_in_mem pc_in_mem(
    // input
    .pc_in_mem(ME_pc), .alu_res_in_mem(32'h0),
    // output
    .pc_init_control(ME_pc_control)
);

// data_RAM data_RAM_0(
//     // in
//     .clk(clk), .we(x1), .data_address(x162), .data(x321),
//     // out
//     .res(y322)
// );

WaitRegs MEM_WB_wait(
    .clk(clk)
);

endmodule
