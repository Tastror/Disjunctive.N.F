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
//     normal (begin with capital):
//         IF_xxx, ID_xxx, EX_xxx, ME_xxx, WB_xxx
//
// [input and output rule]
//     normal:
//         module_name(
//             // input
//             .x1(_x1), ,x2(_x2),
//             // output
//             .x3(_x3), ,x4(_x4)
//         );
//     for reg wait:
//         module_name(
//             .clk(clk), .en(1), .rst(0 or reset)
//             // in-out pair
//             .i1(_x1), .o1(_y1),
//             .i2(_x2), .o2(_y2)
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
wire [31:0] IF_pc, IF_pc_plus_4;
wire [31:0] IF_instruction;

wire [31:0] ID_pc_plus_4;
wire [31:0] ID_instruction;
wire [15:0] ID_imm;  // imm and offset are the same
wire [31:0] ID_imm_32;  // ID_imm with sign
wire [5:0] ID_opcode;
wire [5:0] ID_funct;
wire [5:0] ID_rt;
wire [4:0] ID_rs;
wire [4:0] ID_rd;
wire [4:0] ID_sa;  // sa and base are the same
wire [25:0] ID_instIndex;
wire [19:0] ID_code;
wire [2:0] ID_sel;

wire WB_ctl_rf_wen;
wire [4:0] WB_reg_waddr;
wire [31:0] WB_reg_wdata;
wire [4:0] ID_ctl_pcValue_mux; // pcValue: MUX5_32b, [PC+4, aluRes, instIndex, temp, use delaySlot]
wire [31:0] ID_reg_rdata1_rs, ID_reg_rdata2_sa, ID_reg_rdata3_rt;
wire [2:0] ID_ctl_rfAluSrc1_mux; // aluSrc1: MUX3_32b, [rs, sa, PC]
wire [3:0] ID_ctl_rfAluSrc2_mux; // aluSrc1: MUX4_32b, [rt, imm, {HI}, {LO}]
wire [19:0] ID_ctl_alu_mux;
wire ID_ctl_dataRam_en;
wire ID_ctl_dataRam_wen;
wire [2:0] ID_ctl_rfWriteData_mux; // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
wire [2:0] ID_ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire ID_ctl_rf_wen;
// wire ID_ctl_low_wen;  // just use for MTLO, MULT, MULTU to save two 32bits data to low
//                               // when this is enabled, the [Low] and will save data from [aluRes]
// wire ID_ctl_high_wen;  // just use for MTHI, MULT, MULTU to save two 32bits data to high 
//                                // when this is enabled, the [High] and will save data from [aluRes]
// wire ID_ctl_temp_wen;  // JALR, JR

wire [31:0] EX_pc_plus_4;
wire [15:0] EX_imm;
wire [31:0] EX_imm_32;
wire [2:0] EX_ctl_rfAluSrc1_mux; // aluSrc1: MUX3_32b, [rs, sa, PC]
wire [3:0] EX_ctl_rfAluSrc2_mux; // aluSrc1: MUX4_32b, [rt, imm, {HI}, {LO}]
wire [19:0] EX_ctl_alu_mux;
wire [31:0] EX_rs_data, EX_sa_data, EX_rt_data;
wire [31:0] EX_alu_src1, EX_alu_src2;
wire [31:0] EX_alu_res;
wire [31:0] EX_pc_plus_4_plus_4imm;
wire EX_ctl_dataRam_en;
wire EX_ctl_dataRam_wen;
wire [2:0] EX_ctl_rfWriteData_mux; // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
wire [2:0] EX_ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire EX_ctl_rf_wen;
wire [5:0] EX_rt;
wire [4:0] EX_rd;

wire [31:0] ME_pc_plus_4;
wire [31:0] ME_pc_plus_4_plus_4imm;
wire [31:0] ME_alu_res;
wire ME_ctl_dataRam_en;
wire ME_ctl_dataRam_wen;
wire [31:0] ME_dataram_rdata;
wire [31:0] ME_rt_data;
wire [2:0] ME_ctl_rfWriteData_mux; // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
wire [2:0] ME_ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire ME_ctl_rf_wen;
wire [5:0] ME_rt;
wire [4:0] ME_rd;

wire [31:0] WB_pc_plus_4;
wire [31:0] WB_pc_plus_8;
wire [31:0] WB_alu_res;
wire [31:0] WB_dataram_rdata;
wire [2:0] WB_ctl_rfWriteData_mux; // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
wire [2:0] WB_ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire [5:0] WB_rt;
wire [4:0] WB_rd;





pc_in_if pc_if_0(
    .reset(reset), .clk(clk),
    // input
    .pc_from_mem(ME_pc_plus_4_plus_4imm), .pc_init_control(ME_pc_control),
    // output
    .pc_out(IF_pc), .pc_plus_4(IF_pc_plus_4)
);

wire [31:0] IF_pc_or_debug;
assign IF_pc_or_debug = inst_ram_write_address & {32{debug}} | IF_pc & {32{~debug}};

instruction_RAM inst_RAM_0(
    // debug in
    .write_enable(inst_ram_write_enable), .write_data(inst_ram_write_data),
    // input
    .clk(clk), .pc(IF_pc_or_debug),
    // output
    .instruction(IF_instruction)
);





WaitRegs IF_ID_wait(
    .clk(clk), .en(1), .rst(0),
    // in-out pair
    .i321(IF_instruction), .o321(ID_instruction),
    .i322(IF_pc_plus_4), .o322(ID_pc_plus_4)
);





id_data id_data_0(
    // input
    .instruction(ID_instruction),
    // output
    .opcode(ID_opcode), .funct(ID_funct), .rs(ID_rs), .rt(ID_rt), .rd(ID_rd),
    .sa(ID_sa), .imm(ID_imm), .instIndex(ID_instIndex), .code(ID_code), .sel(ID_sel)
);

assign ID_imm_32 = {{16{ID_imm[15]}}, ID_imm};

id_control id_control_1(
    // input
    .opcode(ID_opcode), .funct(ID_funct), .rt(ID_rt),
    // output
    .ctl_pcValue_mux(ID_ctl_pcValue_mux),
    .ctl_aluSrc1_mux(ID_ctl_rfAluSrc1_mux), .ctl_aluSrc2_mux(ID_ctl_rfAluSrc2_mux), .ctl_alu_mux(ID_ctl_alu_mux),
    .ctl_dataRam_en(ID_ctl_dataRam_en), .ctl_dataRam_wen(ID_ctl_dataRam_wen),
    .ctl_rfWriteData_mux(ID_ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ID_ctl_rfWriteAddr_mux), .ctl_rf_wen(ID_ctl_rf_wen),
    .ctl_low_wen(ID_ctl_low_wen), .ctl_high_wen(ID_ctl_high_wen), .ctl_temp_wen(ID_ctl_temp_wen)
);

regs regs_0(
    // input
    .clk(clk), .rst(reset),
    .we(WB_ctl_rf_wen), .waddr(WB_reg_waddr), .wdata(WB_reg_wdata),
    .raddr1(ID_rs), .raddr2(ID_sa), .raddr3(ID_rt),
    // output
    .rdata1(ID_reg_rdata1_rs), .rdata2(ID_reg_rdata2_sa), .rdata3(ID_reg_rdata3_rt)
);





WaitRegs ID_EXE_wait(
    .clk(clk), .en(1), .rst(0),
    // in-out pair
    .i1(ID_ctl_dataRam_en), .o1(EX_ctl_dataRam_en),
    .i2(ID_ctl_dataRam_wen), .o2(EX_ctl_dataRam_wen),
    .i3(ID_ctl_rf_wen), .o3(EX_ctl_rf_wen),
    .i51(ID_ctl_rfAluSrc1_mux), .o51(EX_ctl_rfAluSrc1_mux),
    .i52(ID_ctl_rfAluSrc2_mux), .o52(EX_ctl_rfAluSrc2_mux),
    .i61(ID_ctl_rfWriteData_mux), .o61(EX_ctl_rfWriteData_mux),
    .i62(ID_ctl_rfWriteAddr_mux), .o62(EX_ctl_rfWriteAddr_mux),
    .i81(ID_rt), .o81(EX_rt),
    .i82(ID_rd), .o82(EX_rd),
    .i161(ID_imm), .o161(EX_imm),
    .i321(ID_pc_plus_4), .o321(EX_pc_plus_4),
    .i322(ID_reg_rdata1_rs), .o322(EX_rs_data),
    .i323(ID_reg_rdata2_sa), .o323(EX_sa_data),
    .i324(ID_reg_rdata3_rt), .o324(EX_rt_data),
    .i325(ID_imm_32), .o325(EX_imm_32),
    .i326(ID_ctl_alu_mux), .o326(EX_ctl_alu_mux)
);





pc_in_ex pc_ex_0(
    // input
    .pc_in_ex(EX_pc_plus_4), .imm_32_in_ex(EX_imm_32),
    // output
    .pc_to_mem(EX_pc_plus_4_plus_4imm)
);

MUX3_32b MUX3_32b_alusrc1( .oneHot(EX_ctl_rfAluSrc1_mux),
    .in0(EX_rs_data), .in1(EX_sa_data), .in2(EX_pc_plus_4_plus_4imm), .out(EX_alu_src1) );

MUX4_32b MUX4_32b_alusrc2( .oneHot(EX_ctl_rfAluSrc2_mux),
    .in0(EX_rt_data), .in1(EX_imm_32), .in2(32'h0), .in3(32'h0), .out(EX_alu_src2) );

ALU ALU_0(
    // input
    .alu_control(EX_ctl_alu_mux),
    .alu_src1(EX_alu_src1), .alu_src2(EX_alu_src2),
    // output
    .alu_result(EX_alu_res)
);





WaitRegs EXE_MEM_wait(
    .clk(clk), .en(1), .rst(reset),
    // in-out pair
    .i1(EX_ctl_dataRam_en), .o1(ME_ctl_dataRam_en),
    .i2(EX_ctl_dataRam_wen), .o2(ME_ctl_dataRam_wen),
    .i3(EX_ctl_rf_wen), .o3(ME_ctl_rf_wen),
    .i61(EX_ctl_rfWriteData_mux), .o61(ME_ctl_rfWriteData_mux),
    .i62(EX_ctl_rfWriteAddr_mux), .o62(ME_ctl_rfWriteAddr_mux),
    .i81(EX_rt), .o81(ME_rt),
    .i82(EX_rd), .o82(ME_rd),
    .i321(EX_pc_plus_4_plus_4imm), .o321(ME_pc_plus_4_plus_4imm),
    .i322(EX_pc_plus_4), .o322(ME_pc_plus_4),
    .i323(EX_alu_res), .o323(ME_alu_res),
    .i324(EX_rt_data), .o324(ME_rt_data)
);





pc_in_mem pc_in_mem(
    // input
    .pc_in_mem(ME_pc_plus_4_plus_4imm), .alu_res_in_mem(ME_alu_res),
    // output
    .pc_init_control(ME_pc_control)
);

data_RAM data_RAM_0(
    // in
    .clk(clk), .en(ME_ctl_dataRam_en), .we(ME_ctl_dataRam_wen),
    .data_address(ME_alu_res), .data(ME_rt_data),
    // out
    .res(ME_dataram_rdata)
);





WaitRegs MEM_WB_wait(
    .clk(clk), .en(1), .rst(reset),
    // in-out pair
    .i3(ME_ctl_rf_wen), .o3(WB_ctl_rf_wen),
    .i61(ME_ctl_rfWriteData_mux), .o61(WB_ctl_rfWriteData_mux),
    .i62(ME_ctl_rfWriteAddr_mux), .o62(WB_ctl_rfWriteAddr_mux),
    .i81(ME_rt), .o81(WB_rt),
    .i82(ME_rd), .o82(WB_rd),
    .i321(ME_pc_plus_4), .o321(WB_pc_plus_4),
    .i322(ME_dataram_rdata), .o322(WB_dataram_rdata),
    .i323(ME_alu_res), .o323(WB_alu_res)
);





assign WB_pc_plus_8 = WB_pc_plus_4 + 32'd4;

MUX3_32b MUX3_32b_wb_wdata( .oneHot(WB_ctl_rfWriteData_mux),
    .in0(WB_alu_res), .in1(WB_dataram_rdata), .in2(WB_pc_plus_8), .out(WB_reg_wdata) );

MUX3_5b MUX3_5b_wb_waddr( .oneHot(WB_ctl_rfWriteAddr_mux),
    .in0(WB_rd), .in1(WB_rt), .in2(5'd31), .out(WB_reg_waddr) );





endmodule
