`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Disjunctive.N.F 
// Engineer: Tastror
// 
// Create Date: 2022/05/03 21:43:40
// Design Name: 
// Module Name: ID_control
// Project Name: W
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


// in version 1, we dissmiss expection

module ID_control(
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
    // offset and inst_index are all directly assigned outside
);



// PC + 4
assign ctl_pcValue_mux[0] = ~|ctl_pcValue_mux[4:1];
// aluRes
assign ctl_pcValue_mux[1] = (
    (~opcode[5] & (&opcode[4:3]) & funct[0])  // 011xxx, 000001
);
// instIndex
assign ctl_pcValue_mux[2] = (
    (~opcode[5] & (&opcode[4:3]) & funct[1])  // 011xxx, 000010
);
//temp
assign ctl_pcValue_mux[3] = (
    (~opcode[5] & (&opcode[4:3]) & funct[2])  // 011xxx, 000100
);
// use delaySlot
assign ctl_pcValue_mux[4] = (
    (~|opcode[5:3] & |opcode[2:0]) |  // 000(xxx) has 1 in (xxx)
    (~|opcode[5:0] & (~|funct[5:4] & funct[3] & ~|funct[2:1]))  // JALR, JR
);



// rs
assign ctl_aluSrc1_mux[0] = ~|ctl_aluSrc1_mux[2:1];
// sa
assign ctl_aluSrc1_mux[1] = (
    (~|opcode[5:0] & ~|funct[5:2])  // 000000, 0000xx  SLL, SRA, SRL
);
// PC
assign ctl_aluSrc1_mux[2] = (
    (~opcode[5] & &opcode[4:3])  // all 011xxx
);



// rt
assign ctl_aluSrc2_mux[0] = (
    (~|opcode[5:0] & ~(~funct[5] & funct[4] & ~|funct[3:2] & ~funct[0])) |  // all 000000 except 0100x0
    (~|opcode[5:3] & opcode[2] & ~opcode[1])  // 00010x  BEQ, BNE
);
// imm
assign ctl_aluSrc2_mux[1] = (
    opcode[5] |  // all 1xxxxx
    (~opcode[5] & opcode[3])  // all 0x1xxx
);
// {HI}
assign ctl_aluSrc2_mux[2] = (
    (~|opcode[5:0] & (~funct[5] & funct[4] & ~|funct[3:0]))  // MFHI
);
// {LO}
assign ctl_aluSrc2_mux[3] = (
    (~|opcode[5:0] & (~funct[5] & funct[4] & ~|funct[3:2] & funct[1] & ~funct[0]))  // MFLO
);



// aluRes
assign ctl_rfWriteData_mux[0] = (
    (~|opcode[5:0] & ~(~|funct[5:4] & funct[3] & ~|funct[2:1])) |  // all 000000 except JR, JALR
    (~|opcode[5:4] & opcode[3])  // 001xxx
);
// DataRamReadData
assign ctl_rfWriteData_mux[1] = (
    (opcode[5] & ~opcode[4] & ~opcode[3])  // 100xxx
);
// PC + 8
assign ctl_rfWriteData_mux[2] = (
    (~|opcode[5:1] & opcode[0] & rt[5]) |  // 000001, rt[5] = 1
    (~|opcode[5:0] & ~|funct[5:4] & ~|funct[2:1] & funct[3] & funct[0]) |  // 000000, funct = 001001
    (~|opcode[5:2] & &opcode[1:0])  // 000011
);



// rd
assign ctl_rfWriteAddr_mux[0] = (
    (~|opcode[5:0] & ~(~funct[5] & funct[4] & (funct[3] | funct[0])))  // 000000, expect Multi series(funct = 01a00b, there must be at least one 1 in ab)
);
// rt
assign ctl_rfWriteAddr_mux[1] = (
    (opcode[5] & ~|opcode[4:3]) | // 100xxx
    (~|opcode[5:4] & opcode[3]) // 001xxx
);
// 31
assign ctl_rfWriteAddr_mux[2] = (
    (~|opcode[5:1] & opcode[0] & rt[5]) | // 000001, rt = 1xxxxx
    (~|opcode[5:2] & &opcode[1:0])  // JAL(000011)
);
// {LO}
assign ctl_rfWriteAddr_mux[3] = (
    (~|opcode[5:0] & (~funct[5] & funct[4] & (funct[3] | &funct[1:0])))  // 000000,  Multi series(funct = 01a00b, there must be at least one 1 in ab), expect MTHI(010001)
);



endmodule
