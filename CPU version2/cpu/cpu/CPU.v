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


wire [31:0] IF_pc, IF_pc_plus_4;
wire [31:0] IF_instruction;


wire [31:0] ID_pc_plus_4;
wire [31:0] ID_instruction;
wire [15:0] ID_imm;  // imm and offset are the same
wire [31:0] ID_imm_32, ID_sa_32;  // ID_imm & ID_sa with sign
wire [5:0] ID_opcode;
wire [5:0] ID_funct;
wire [4:0] ID_rt;
wire [4:0] ID_rs;
wire [4:0] ID_rd;
wire [4:0] ID_sa;  // sa and base are the same
wire [25:0] ID_index;
wire [15:0] ID_code;
wire [2:0] ID_sel;
wire ID_ctl_pc_first_mux;
wire [3:0] ID_ctl_pc_second_mux; // [first, index, rs_data, break]
wire [31:0] ID_reg_rdata1_rs, ID_reg_rdata2_rt;
wire [31:0] ID_high_rdata, ID_low_rdata;
wire [1:0] ID_ctl_rfAluSrc1_mux; // aluSrc1: MUX2_32b, [rs_data, sa]
wire [2:0] ID_ctl_rfAluSrc2_mux; // aluSrc1: MUX3_32b, [rt_data, imm_32, 0]
wire [13:0] ID_ctl_alu_mux;
wire ID_ctl_alu_op2;
wire ID_ctl_dataRam_en;
wire ID_ctl_dataRam_wen;
wire [3:0] ID_ctl_alures_merge_mux; // alures_merge: MUX4_32b, [alu_res, PC+8, HI_rdata, LO_rdata]
wire [1:0] ID_ctl_rfWriteData_mux; // rfInData: MUX2_32b, [alures_merge, ramdata]
wire [2:0] ID_ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire ID_ctl_rf_wen;
wire ID_ctl_low_wen;
wire ID_ctl_high_wen;
wire [1:0] ID_ctl_low_mux;  // [alu_res, rs_data]
wire [1:0] ID_ctl_high_mux;  // [alu_res_high, rs_data]


wire [31:0] EX_pc_plus_4;
wire [31:0] EX_pc_plus_8;
wire [25:0] EX_index;
wire [31:0] EX_imm_32, EX_sa_32;
wire [4:0] EX_rs, EX_rt, EX_rd, EX_sa;
wire [31:0] EX_rs_data_old, EX_rt_data_old;
wire [31:0] EX_rs_data, EX_rt_data;
wire [31:0] EX_high_rdata_old, EX_low_rdata_old;
wire [31:0] EX_high_rdata, EX_low_rdata;
wire EX_ctl_pc_first_mux;
wire [3:0] EX_ctl_pc_second_mux;
wire [1:0] EX_ctl_rfAluSrc1_mux; // aluSrc1: MUX2_32b, [rs_data, sa]
wire [2:0] EX_ctl_rfAluSrc2_mux; // aluSrc1: MUX3_32b, [rt_data, imm_32, 0]
wire [13:0] EX_ctl_alu_mux;
wire EX_ctl_alu_op2;
wire [31:0] EX_alu_src1, EX_alu_src2;
wire [31:0] EX_alu_res, EX_alu_res_high;
wire EX_alu_zero;
wire [31:0] EX_pc_plus_4_plus_4imm;
wire EX_ctl_dataRam_en;
wire EX_ctl_dataRam_wen;
wire [31:0] EX_alures_merge;
wire [3:0] EX_ctl_alures_merge_mux; // alures_merge: MUX4_32b, [alu_res, PC+8, HI_rdata, LO_rdata]
wire [1:0] EX_ctl_rfWriteData_mux; // rfInData: MUX2_32b, [alures_merge, ramdata]
wire [2:0] EX_ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire [4:0] EX_reg_waddr;
wire EX_ctl_rf_wen;
wire EX_ctl_low_wen;
wire EX_ctl_high_wen;
wire [1:0] EX_ctl_low_mux;  // [alu_res, rs_data]
wire [1:0] EX_ctl_high_mux;  // [alu_res_high, rs_data]
wire [31:0] EX_low_wdata, EX_high_wdata;


wire [31:0] ME_pc_plus_4;
wire [31:0] ME_pc_plus_4_plus_4imm;
wire [25:0] ME_index;
wire [31:0] ME_alu_res, ME_alu_res_high;
wire ME_alu_zero;
wire ME_ctl_dataRam_en;
wire ME_ctl_dataRam_wen;
wire [31:0] ME_dataram_rdata;
wire [31:0] ME_rs_data, ME_rt_data;
wire [31:0] ME_alures_merge;
wire [1:0] ME_ctl_rfWriteData_mux; // rfInData: MUX2_32b, [alures_merge, ramdata]
wire [4:0] ME_reg_waddr;
wire ME_ctl_rf_wen;
wire ME_ctl_pc_first_mux;
wire ME_pc_control;
wire ME_ctl_low_wen;
wire ME_ctl_high_wen;
wire [31:0] ME_low_wdata, ME_high_wdata;


wire [31:0] WB_dataram_rdata;
wire [31:0] WB_alures_merge;
wire [1:0] WB_ctl_rfWriteData_mux; // rfInData: MUX2_32b, [alures_merge, ramdata]
wire WB_ctl_rf_wen;
wire [4:0] WB_reg_waddr;
wire [31:0] WB_reg_wdata;
wire WB_ctl_low_wen;
wire WB_ctl_high_wen;
wire [31:0] WB_low_wdata, WB_high_wdata;




/***** Welcome to IF *****/

wire [31:0] IF_temp;

pc_if_first pc_if_first_0(
    // input
    .ME_pc_first_mux(ME_pc_control),
    .IF_last_pc(IF_pc), .ME_pc(ME_pc_plus_4_plus_4imm),
    // output
    .pc_plus_4_or_mem(IF_temp)
);

pc_if_second_reg pc_if_second_reg_0(
    .reset(reset), .clk(clk),
    // input
    .EX_ctl_pc_second_mux(EX_ctl_pc_second_mux),
    .pc_plus_4_or_mem(IF_temp), .ME_index(ME_index), .ME_rs_data(ME_rs_data),
    // output
    .IF_pc_out(IF_pc), .IF_pc_plus_4(IF_pc_plus_4)
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





/***** Welcome to ID *****/

id_data id_data_0(
    // input
    .instruction(ID_instruction),
    // output
    .opcode(ID_opcode), .funct(ID_funct), .rs(ID_rs), .rt(ID_rt), .rd(ID_rd),
    .sa(ID_sa), .imm(ID_imm), .instIndex(ID_index), .code(ID_code), .sel(ID_sel)
);

assign ID_imm_32 = {{16{ID_imm[15]}}, ID_imm};  // signed
assign ID_sa_32 = {{27{1'b0}}, ID_sa};  // no sign

id_control id_control_0(
    // input
    .opcode(ID_opcode), .rs(ID_rs), .rt(ID_rt), .rd(ID_rd), .sa(ID_sa), .funct(ID_funct),
    // output
    .ctl_pc_first_mux(ID_ctl_pc_first_mux), .ctl_pc_second_mux(ID_ctl_pc_second_mux),
    .ctl_aluSrc1_mux(ID_ctl_rfAluSrc1_mux), .ctl_aluSrc2_mux(ID_ctl_rfAluSrc2_mux),
    .ctl_alu_mux(ID_ctl_alu_mux), .ctl_alu_op2(ID_ctl_alu_op2),
    .ctl_alures_merge_mux(ID_ctl_alures_merge_mux),
    .ctl_dataRam_en(ID_ctl_dataRam_en), .ctl_dataRam_wen(ID_ctl_dataRam_wen),
    .ctl_rfWriteData_mux(ID_ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ID_ctl_rfWriteAddr_mux), .ctl_rf_wen(ID_ctl_rf_wen),
    .ctl_low_wen(ID_ctl_low_wen), .ctl_high_wen(ID_ctl_high_wen), .ctl_low_mux(ID_ctl_low_mux), .ctl_high_mux(ID_ctl_high_mux)
);

regs regs_0(
    // input
    .clk(clk), .rst(reset),
    .we(WB_ctl_rf_wen), .waddr(WB_reg_waddr), .wdata(WB_reg_wdata),
    .raddr1(ID_rs), .raddr2(ID_rt),
    // output
    .rdata1(ID_reg_rdata1_rs), .rdata2(ID_reg_rdata2_rt)
);

low_high_reg low_high_reg_0(
    //input
    .clk(clk), .rst(reset),
    .low_we(WB_ctl_low_wen), .high_we(WB_ctl_high_wen),
    .low_wdata(WB_low_wdata), .high_wdata(WB_high_wdata),
    //output
    .low_rdata(ID_low_rdata), .high_rdata(ID_high_rdata)
);




WaitRegs ID_EXE_wait(
    .clk(clk), .en(1), .rst(0),
    // in-out pair
    .i1(ID_ctl_dataRam_en), .o1(EX_ctl_dataRam_en),
    .i2(ID_ctl_dataRam_wen), .o2(EX_ctl_dataRam_wen),
    .i3(ID_ctl_rf_wen), .o3(EX_ctl_rf_wen),
    .i4(ID_ctl_alu_op2), .o4(EX_ctl_alu_op2),
    .i5(ID_ctl_pc_first_mux), .o5(EX_ctl_pc_first_mux),
    .i6(ID_ctl_low_wen), .o6(EX_ctl_low_wen),
    .i7(ID_ctl_high_wen), .o7(EX_ctl_high_wen),
    .i21(ID_ctl_low_mux), .o21(EX_ctl_low_mux),
    .i22(ID_ctl_high_mux), .o22(EX_ctl_high_mux),
    .i51(ID_ctl_rfAluSrc1_mux), .o51(EX_ctl_rfAluSrc1_mux),
    .i52(ID_ctl_rfAluSrc2_mux), .o52(EX_ctl_rfAluSrc2_mux),
    .i61(ID_ctl_rfWriteData_mux), .o61(EX_ctl_rfWriteData_mux),
    .i62(ID_ctl_rfWriteAddr_mux), .o62(EX_ctl_rfWriteAddr_mux),
    .i81(ID_rt), .o81(EX_rt),
    .i82(ID_rd), .o82(EX_rd),
    .i83(ID_rs), .o83(EX_rs),
    .i84(ID_sa), .o84(EX_sa),
    .i161(ID_ctl_pc_second_mux), .o161(EX_ctl_pc_second_mux),
    .i162(ID_ctl_alures_merge_mux), .o162(EX_ctl_alures_merge_mux),
    .i321(ID_pc_plus_4), .o321(EX_pc_plus_4),
    .i322(ID_reg_rdata1_rs), .o322(EX_rs_data_old),
    .i323(ID_reg_rdata2_rt), .o323(EX_rt_data_old),
    .i324(ID_imm_32), .o324(EX_imm_32),
    .i325(ID_sa_32), .o325(EX_sa_32),
    .i326(ID_ctl_alu_mux), .o326(EX_ctl_alu_mux),
    .i327(ID_index), .o327(EX_index),
    .i328(ID_low_rdata), .o328(EX_low_rdata_old),
    .i329(ID_high_rdata), .o329(EX_high_rdata_old)
);





/***** Welcome to EXE *****/

pc_ex pc_ex_0(
    // input
    .pc_in_ex(EX_pc_plus_4), .imm_32_in_ex(EX_imm_32),
    // output
    .pc_to_mem(EX_pc_plus_4_plus_4imm)
);

bypass bypass_rs(
    // input
    .used_addr(EX_rs), .ME_reg_waddr(ME_reg_waddr), .WB_reg_waddr(WB_reg_waddr),
    .old_data(EX_rs_data_old), .ME_alures_merge(ME_alures_merge), .WB_reg_wdata(WB_reg_wdata),
    // output
    .changed_data(EX_rs_data)
);

bypass bypass_rt(
    // input
    .used_addr(EX_rt), .ME_reg_waddr(ME_reg_waddr), .WB_reg_waddr(WB_reg_waddr),
    .old_data(EX_rt_data_old), .ME_alures_merge(ME_alures_merge), .WB_reg_wdata(WB_reg_wdata),
    // output
    .changed_data(EX_rt_data)
);

bypass_low_high bypass_low(
    // input
    .ME_wen(ME_ctl_low_wen), .WB_wen(WB_ctl_low_wen),
    .old_data(EX_low_rdata_old), .ME_data(ME_low_wdata), .WB_data(WB_low_wdata),
    // output
    .new_data(EX_low_rdata)
);

bypass_low_high bypass_high(
    // input
    .ME_wen(ME_ctl_high_wen), .WB_wen(WB_ctl_high_wen),
    .old_data(EX_high_rdata_old), .ME_data(ME_high_wdata), .WB_data(WB_high_wdata),
    // output
    .new_data(EX_high_rdata)
);

MUX2_32b MUX2_32b_alusrc1( .oneHot(EX_ctl_rfAluSrc1_mux),
    .in0(EX_rs_data), .in1(EX_sa_32), .out(EX_alu_src1) );

MUX3_32b MUX3_32b_alusrc2( .oneHot(EX_ctl_rfAluSrc2_mux),
    .in0(EX_rt_data), .in1(EX_imm_32), .in2(32'h0), .out(EX_alu_src2) );

ALU ALU_0(
    // input
    .alu_control(EX_ctl_alu_mux), .alu_op2(EX_ctl_alu_op2),
    .alu_src1(EX_alu_src1), .alu_src2(EX_alu_src2),
    // output
    .alu_result(EX_alu_res), .alu_result_high(EX_alu_res_high), .alu_zero(EX_alu_zero)
);

assign EX_pc_plus_8 = EX_pc_plus_4 + 32'd4;

MUX4_32b MUX4_32b_alures_merge(.oneHot(EX_ctl_alures_merge_mux),
    .in0(EX_alu_res), .in1(EX_pc_plus_8), .in2(EX_high_rdata), .in3(EX_low_rdata), .out(EX_alures_merge) );

// this is usually written in write-back, but considered the bypass, we lift it here
MUX3_5b MUX3_5b_ex_waddr( .oneHot(EX_ctl_rfWriteAddr_mux),
    .in0(EX_rd), .in1(EX_rt), .in2(5'd31), .out(EX_reg_waddr) );

MUX2_32b MUX2_32b_low( .oneHot(EX_ctl_low_mux),
    .in0(EX_alu_res), .in1(EX_rs_data), .out(EX_low_wdata) );

MUX2_32b MUX2_32b_high( .oneHot(EX_ctl_high_mux),
    .in0(EX_alu_res_high), .in1(EX_rs_data), .out(EX_high_wdata) );





WaitRegs EXE_MEM_wait(
    .clk(clk), .en(1), .rst(reset),
    // in-out pair
    .i1(EX_ctl_dataRam_en), .o1(ME_ctl_dataRam_en),
    .i2(EX_ctl_dataRam_wen), .o2(ME_ctl_dataRam_wen),
    .i3(EX_ctl_rf_wen), .o3(ME_ctl_rf_wen),
    .i4(EX_ctl_pc_first_mux), .o4(ME_ctl_pc_first_mux),
    .i5(EX_alu_zero), .o5(ME_alu_zero),
    .i6(EX_ctl_low_wen), .o6(ME_ctl_low_wen),
    .i7(EX_ctl_high_wen), .o7(ME_ctl_high_wen),
    .i61(EX_ctl_rfWriteData_mux), .o61(ME_ctl_rfWriteData_mux),
    .i81(EX_reg_waddr), .o81(ME_reg_waddr),
    .i321(EX_pc_plus_4_plus_4imm), .o321(ME_pc_plus_4_plus_4imm),
    .i322(EX_pc_plus_4), .o322(ME_pc_plus_4),
    .i323(EX_alu_res), .o323(ME_alu_res),
    .i324(EX_alu_res_high), .o324(ME_alu_res_high),
    .i325(EX_rt_data), .o325(ME_rt_data),
    .i326(EX_rs_data), .o326(ME_rs_data),
    .i327(EX_index), .o327(ME_index),
    .i328(EX_low_wdata), .o328(ME_low_wdata),
    .i329(EX_high_wdata), .o329(ME_high_wdata),
    .i32a(EX_alures_merge), .o32a(ME_alures_merge)
);





/***** Welcome to MEM *****/

assign ME_pc_control = (ME_alu_res[0]) & ME_ctl_pc_first_mux;

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
    .i4(ME_ctl_low_wen), .o4(WB_ctl_low_wen),
    .i5(ME_ctl_high_wen), .o5(WB_ctl_high_wen),
    .i61(ME_ctl_rfWriteData_mux), .o61(WB_ctl_rfWriteData_mux),
    .i81(ME_reg_waddr), .o81(WB_reg_waddr),
    .i322(ME_dataram_rdata), .o322(WB_dataram_rdata),
    .i323(ME_alures_merge), .o323(WB_alures_merge),
    .i324(ME_low_wdata), .o324(WB_low_wdata),
    .i325(ME_high_wdata), .o325(WB_high_wdata)
);





/***** Welcome to WB *****/

// rfInData: MUX2_32b, [alures_merge, ramdata]
MUX2_32b MUX2_32b_wb_wdata( .oneHot(WB_ctl_rfWriteData_mux),
    .in0(WB_alures_merge), .in1(WB_dataram_rdata), .out(WB_reg_wdata) );





endmodule
