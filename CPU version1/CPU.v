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


module CPU(
    input wire clk,
    output wire IO_show
);

reg x1, x2, x3;
reg [15:0] x161, x162, x163;
reg [31:0] x321, x322, x323, x324;
wire [15:0] y161, y162;
wire [32:0] y321, y322;

wire [31:0] IF_instruction;
wire [31:0] ID_instruction;
wire [5:0] opcode;
wire [5:0] funct;
wire [5:0] rt;
wire [4:0] rs;
wire [4:0] rd;
wire [4:0] sa;  // sa and base are the same
wire [15:0] ID_imm;  // imm and offset are the same
wire [15:0] EXE_imm;  // imm and offset are the same
wire [25:0] instIndex;
wire [19:0] code;
wire [2:0] sel;

wire [4:0] ctl_pcValue_mux; // pcValue: MUX5_32b, [PC+4, aluRes, instIndex, temp, use delaySlot]
wire ctl_instRam_en;
wire ctl_instRam_wen;
wire [2:0] ctl_aluSrc1_mux; // aluSrc1: MUX3_32b, [rs, sa, PC]
wire [3:0] ctl_aluSrc2_mux; // aluSrc1: MUX4_32b, [rt, imm, {HI}, {LO}]
wire [8:0] ctl_alu_mux;
wire ctl_dataRam_en;
wire ctl_dataRam_wen;
wire [2:0] ctl_rfWriteData_mux; // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
wire [2:0] ctl_rfWriteAddr_mux; // rfInAddr: MUX3_5b, [rd, rt, 31]
wire ctl_rf_wen;
wire ctl_low_wen;  // just use for MTLO, MULT, MULTU to save two 32bits data to low
                              // when this is enabled, the [Low] and will save data from [aluRes]
wire ctl_high_wen;  // just use for MTHI, MULT, MULTU to save two 32bits data to high 
                               // when this is enabled, the [High] and will save data from [aluRes]
wire ctl_temp_wen;  // JALR, JR
    
    
instruction_RAM inst_RAM_0(
    // in
    .clk(clk), .pc(x161),
    // out
    .instruction(IF_instruction)
);

WaitRegs IF_ID_wait(
    .clk(clk),
    .i321(IF_instruction),
    .o321(ID_instruction)
);

ID_data id_data_0(
    // in
    .instruction(ID_instruction),
    // out
    .opcode(opcode), .funct(funct), .rs(rs), .rt(rt), .rd(rd),
    .sa(sa), .imm(ID_imm), .instIndex(instIndex), .code(code), .sel(sel)
);

ID_control ID_control_1(
    // in
    .opcode(opcode), .funct(funct), .rt(rt),
    // out
    .ctl_pcValue_mux(ctl_pcValue_mux),
    .ctl_instRam_en(ctl_instRam_en), .ctl_instRam_wen(ctl_instRam_wen),
    .ctl_aluSrc1_mux(ctl_aluSrc1_mux), .ctl_aluSrc2_mux(ctl_aluSrc2_mux), .ctl_alu_mux(ctl_alu_mux),
    .ctl_dataRam_en(ctl_dataRam_en), .ctl_dataRam_wen(ctl_dataRam_wen),
    .ctl_rfWriteData_mux(ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ctl_rfWriteAddr_mux),
    .ctl_rf_wen(ctl_rf_wen),
    .ctl_low_wen(ctl_low_wen), .ctl_high_wen(ctl_high_wen), .ctl_temp_wen(ctl_temp_wen)
);

WaitRegs ID_EXE_wait(
    .clk(clk),
    .i161(ID_imm),
    .o161(EXE_imm)
);

WaitRegs EXE_MEM_wait(
    .clk(clk)
);

data_RAM data_RAM_0(
    // in
    .clk(clk), .we(x1), .data_address(x162), .data(x321),
    // out
    .res(y322)
);

WaitRegs MEM_WB_wait(
    .clk(clk)
);

WaitRegs WB_IF_wait(
    .clk(clk)
);

endmodule
