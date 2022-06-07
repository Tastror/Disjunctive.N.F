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
    input wire [5:0] opcode,
    input wire [5:0] funct,
    input wire [5:0] rt,

    output wire [4:0] ctl_pcValue_mux, // pcValue: MUX5_32b, [PC+4, aluRes, instIndex, temp, use delaySlot]
    
    output wire ctl_instRam_en,
    output wire ctl_instRam_wen,
    
    output wire [2:0] ctl_aluSrc1_mux, // aluSrc1: MUX3_32b, [rs, sa, PC]
    output wire [3:0] ctl_aluSrc2_mux, // aluSrc1: MUX4_32b, [rt, imm, {HI}, {LO}]
    output wire [8:0] ctl_alu_mux,
    
    output wire ctl_dataRam_en,
    output wire ctl_dataRam_wen,
    
    output wire [2:0] ctl_rfWriteData_mux, // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
    output wire [3:0] ctl_rfWriteAddr_mux, // rfInAddr: MUX4_5b, [rd, rt, 31, {LO}]
    output wire ctl_rfWriteHigh_en,  // just use for MTHI, MULT, MULTU to save two 32bits data to low and high 
                                     // when this is enabled, the rfWriteAddrHigh and rfWriteAddrData will work
    output wire ctl_rf_wen
);

asfasfsaf

RAM RAM1();

RAM RAM1();

ID_control ID_control_1(
    .opcode(opcode), .funct(funct), .rt(rt),
    .ctl_pcValue_mux(ctl_pcValue_mux),
    .ctl_instRam_en(ctl_instRam_en), .ctl_instRam_wen(ctl_instRam_wen),
    .ctl_aluSrc1_mux(ctl_aluSrc1_mux), .ctl_aluSrc2_mux(ctl_aluSrc2_mux), .ctl_alu_mux(ctl_alu_mux),
    .ctl_dataRam_en(ctl_dataRam_en), .ctl_dataRam_wen(ctl_dataRam_wen),
    .ctl_rfWriteData_mux(ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ctl_rfWriteAddr_mux), .ctl_rfWriteHigh_en(ctl_rfWriteHigh_en), .ctl_rf_wen(ctl_rf_wen)
);

endmodule
