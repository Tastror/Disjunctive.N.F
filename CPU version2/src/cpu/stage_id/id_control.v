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

input [5:0] op;
input [5:0] funct;
input [4:0] rt;

output RegWrite;
output [1:0] RegDst; 
// 0:ALURes, 1:mem_rdata, 2:PC+8
output ALUSrc; 
// 0:rs, 1:sa
output [4:0] ALUOp; 
// {
//     0:+,
//     1:-,
//     2:slt,
//     3:sltu,
//     4:与,
//     5:或非,
//     6:or或,
//     7:xor异或,
//     8:sll逻辑左移,
//     9:srl逻辑右移,
//     10:sra算术右移,
//     11:lui高位加载,
//     12:llo低位加载,
//     13:乘,
//     14:bltz,
//     15:blez,
//     16:bgtz,
//     17:bgez,
//     18:beq,
//     19:bneq
// }
output MemRead;
output MemWrite;
output MemToReg;


case (op)
// r型
    6'h000000: begin
        // RegWrite
        case (funct)
            6'h04: assign RegWrite = 1'b0;
            default: assign RegWrite = 1'b1;
        endcase
        // RegDst
        case (funct)
            6'h05: assign RegDst = 2'b10;
            default: assign RegDst = 2'b00;
        endcase
        // ALUSrc 如果忽略应该怎么写，暂时写成了X
        case (funct)
            6'b000000,
            6'b000011,
            6'b000010: assign ALUSrc = 1'b1;
            6'b010000,
            6'b010010: assign ALUSrc = X;
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
            // 其他四种情况，包括lui, llo，都是简单的操作，进行值的传递
            default: assign ALUOp = X;
        endcase
        // 只有访存类指令涉及内存
        assign MemRead = 1'b0;
        assign MemWrite = 1'b0;
        assign MemToReg = 1'b0;
    end 
// i型
    6'b101000,
    6'b101001,
    6'b101011,
    6'b101010,
    6'b101110: begin
        assign RegWrite = 1'b0;
        assign RegDst = X;
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
        assign RegDst = X;
        assign ALUSrc = 1'b0;
        assign ALUOp = 6'd18;
        assign MemRead = 1'b0;
        assign MemWrite = 1'b0;
        assign MemToReg = 1'b0;
    end
    6'b000101: begin
        assign RegWrite = 1'b0;
        assign RegDst = X;
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
                assign RegDst = X;
                assign ALUOp = 6'd17;
            end
            5'b00000: begin
                assign RegWrite = 1'b0;
                assign RegDst = X;
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
        assign RegDst = X;
        assign ALUSrc = 1'b0;
        assign ALUOp = 6'd16;
        assign MemRead = 1'b0;
        assign MemWrite = 1'b0;
        assign MemToReg = 1'b0;
    end
    6'b000110: begin
        assign RegWrite = 1'b0;
        assign RegDst = X;
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
        assign ALUSrc = X;
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
// j型
    6'b000011: begin
        assign RegWrite = 1'b1;
        assign RegDst = 2'd2;
        assign ALUSrc = X;
        assign ALUOp = X;
        assign MemRead = 1'b0;
        assign MemWrite = 1'b0;
        assign MemToReg = 1'b0;
    end
    6'b000010: begin
        assign RegWrite = 1'b0;
        assign RegDst = X;
        assign ALUSrc = X;
        assign ALUOp = X;
        assign MemRead = 1'b0;
        assign MemWrite = 1'b0;
        assign MemToReg = 1'b0;
    end
endcase

endmodule