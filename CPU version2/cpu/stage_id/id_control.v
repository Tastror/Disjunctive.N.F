// 生成控制信号

module id_control(
    //output
    RegWrite,
    RegDst,
    ALUSrc,
    ALUOp,
    MemRead,
    MemWrite,
    MemToReg,
    //input
    op,
    funct,
    rt
);

input wire [5:0] op;
input [5:0] funct;
input [4:0] rt;

output reg RegWrite;
output reg [1:0] RegDst; 
// 0:ALURes, 1:mem_rdata, 2:PC+8
output reg ALUSrc; 
// 0:rs, 1:sa
output reg [5:0] ALUOp; 
// {
//     0:+,
//     1:-,
//     2:slt,
//     3:sltu,
//     4:and,
//     5:nor,
//     6:or,
//     7:xor异或,
//     8:sll逻辑左移,
//     9:srl逻辑右移,
//     10:sra算术右移,
//     11:lui高位加载,
//     12:llo低位加载,
//     13:multiply,
//     14:bltz,
//     15:blez,
//     16:bgtz,
//     17:bgez,
//     18:beq,
//     19:bneq
// }
output reg MemRead;
output reg MemWrite;
output reg MemToReg;


always @(*)
    case(op)
    // r??
        6'h000000: begin
            // RegWrite
            case(funct)
                6'h04: assign RegWrite = 1'b0;
                default: assign RegWrite = 1'b1;
            endcase
            // RegDst
            case(funct)
                6'h05: assign RegDst = 2'b10;
                default: assign RegDst = 2'b00;
            endcase
            // ALUSrc 如果忽略应该怎么写，暂时写成了X
            case(funct)
                6'b000000,
                6'b000011,
                6'b000010: assign ALUSrc = 1'b1;
                6'b010000,
                6'b010010: assign ALUSrc = 1'bX;
                default: assign ALUSrc = 1'b0;
            endcase
            case (funct)
                6'b100000,
                6'b100001: assign ALUOp = 6'd0;
                6'b100010,
                6'b100011: assign ALUOp = 6'd1;
                6'b101010: assign ALUOp = 6'd2;
                6'b101011: assign ALUOp = 6'd3;
                6'b011000,
                6'b011001: assign ALUOp = 6'd13;
                6'b100100: assign ALUOp = 6'd4;
                6'b100111: assign ALUOp = 6'd5;
                6'b100101: assign ALUOp = 6'd6;
                6'b100110: assign ALUOp = 6'd7;
                6'b000100,
                6'b000100: assign ALUOp = 6'd8;
                6'b000111,
                6'b000011: assign ALUOp = 6'd10;
                6'b000110,
                6'b000010: assign ALUOp = 6'd9;
                6'b010000: assign ALUOp = 6'd11;
                6'b010010: assign ALUOp = 6'd12;
                // 其他四种情况，包括lui, llo，都是简单的操作，进行???的传???
                default: assign ALUOp = 6'bX;
            endcase
            // 只有访存类指令涉及内??
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end 
    // i??
        6'b101000,
        6'b101001,
        6'b101011,
        6'b101010,
        6'b101110: begin
            assign RegWrite = 1'b0;
            assign RegDst = 2'bX;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd0;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b1;
            assign MemToReg = 1'b0;
        end
        6'b100000,
        6'b100100,
        6'b100001,
        6'b100101,
        6'b100011,
        6'b100010,
        6'b100110: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd1;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd0;
            assign MemRead = 1'b1;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b1;
        end
        6'b000100: begin
            assign RegWrite = 1'b0;
            assign RegDst = 2'bX;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd18;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b000101: begin
            assign RegWrite = 1'b0;
            assign RegDst = 2'bX;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd19;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b000001: begin
            assign ALUSrc = 1'b0;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
            case (rt) 
                5'b00001: begin
                    assign RegWrite = 1'b0;
                    assign RegDst = 2'bX;
                    assign ALUOp = 6'd17;
                end
                5'b00000: begin
                    assign RegWrite = 1'b0;
                    assign RegDst = 2'bX;
                    assign ALUOp = 6'd14;
                end
                5'b10000: begin
                    assign RegWrite = 1'b1;
                    assign RegDst = 2'd2;
                    assign ALUOp = 6'd14;
                end
                5'b10001: begin
                    assign RegWrite = 1'b1;
                    assign RegDst = 2'd2;
                    assign ALUOp = 6'd17;
                end
            endcase
        end
        6'b000111: begin
            assign RegWrite = 1'b0;
            assign RegDst = 2'bX;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd16;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b000110: begin
            assign RegWrite = 1'b0;
            assign RegDst = 2'bX;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd15;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001100: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'b0;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd4;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001111: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd0;
            assign ALUSrc = 2'bX;
            assign ALUOp = 6'd8;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001101: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd0;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd6;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001110: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd0;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd7;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001000,
        6'b001001: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd0;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd0;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001010: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd0;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd2;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b001011: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd0;
            assign ALUSrc = 1'b0;
            assign ALUOp = 6'd3;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
    // j??
        6'b000011: begin
            assign RegWrite = 1'b1;
            assign RegDst = 2'd2;
            assign ALUSrc = 1'bX;
            assign ALUOp = 6'bX;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
        6'b000010: begin
            assign RegWrite = 1'b0;
            assign RegDst = 2'bX;
            assign ALUSrc = 1'bX;
            assign ALUOp = 6'bX;
            assign MemRead = 1'b0;
            assign MemWrite = 1'b0;
            assign MemToReg = 1'b0;
        end
    endcase


endmodule


module ID_control(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    input wire [5:0] rt,

    output wire [4:0] ctl_pcValue_mux, // pcValue: MUX5_32b, [PC+4, aluRes, instIndex, temp, useDelaySlot]
    
    output wire [2:0] ctl_aluSrc1_mux, // aluSrc1: MUX3_32b, [rs, sa, PC]
    output wire [3:0] ctl_aluSrc2_mux, // aluSrc1: MUX4_32b, [rt, imm, {HI}, {LO}]
    output wire [8:0] ctl_alu_mux,
    
    output wire ctl_dataRam_en,
    output wire ctl_dataRam_wen,
    
    output wire [2:0] ctl_rfWriteData_mux, // rfInData: MUX3_32b, [aluRes, DataRamReadData, PC+8]
    output wire [2:0] ctl_rfWriteAddr_mux, // rfInAddr: MUX3_5b, [rd, rt, 31]

    output wire ctl_rf_wen,

    output wire ctl_low_wen,  // just use for MTLO, MULT, MULTU to save two 32bits data to low
                              // when this is enabled, the [Low] and will save data from [aluRes]
    output wire ctl_high_wen,  // just use for MTHI, MULT, MULTU to save two 32bits data to high 
                               // when this is enabled, the [High] and will save data from [aluRes]
    output wire ctl_temp_wen  // JALR, JR

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


// assign ctl_instRam_en = ~(
//     (~|opcode[5:3] & |opcode[2:0]) |  // 000(xxx) has 1 in (xxx)
//     (~|opcode[5:0] & (~|funct[5:4] & funct[3] & ~|funct[2:1]))  // JALR, JR
// );


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


assign ctl_dataRam_en = (
    opcode[5]
);

assign ctl_dataRam_wen = (
    opcode[5] & opcode[3]
);


// rd
assign ctl_rfWriteAddr_mux[0] = (
    (~|opcode[5:0] & ~((~funct[5] & funct[4]) & (funct[3] | funct[0])))  // 000000, expect Multi series(funct = 01a00b, there must be at least one 1 in ab)
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


assign ctl_low_wen = (
    (~|opcode[5:0] & ((~funct[5] & funct[4]) & (funct[3] | &funct[1:0])))  // 000000,  funct = 011xxx or 01xx11 (only 010011)
);

assign ctl_high_wen = (
    (~|opcode[5:0] & ((~funct[5] & funct[4]) & (funct[3] | (~|funct[3:1] & funct[0]))))  // 00000, funct = 011xxx or 010001
);

assign ctl_temp_wen = (
    (~|opcode[5:0] & (~|funct[5:4] & funct[3] & ~|funct[2:1]))  // JALR, JR
);

assign ctl_rf_wen = (
    (opcode[5] & ~|opcode[4:3]) |  // 100xxx
    (~|opcode[5:4] & opcode[3]) |  // 001xxx
    (~|opcode[5:0] & ~(~|funct[5:4] & funct[3] & ~|funct[2:0])) |  // 000000 except JR
    (~|opcode[5:1] & opcode[0] & funct[5]) |  // BLTZAL, BGEZAL
    (~|opcode[5:2] & &opcode[1:0]) // JAL
);


endmodule
