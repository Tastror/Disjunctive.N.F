`timescale 1ns / 1ps

module MUX3_5b(
    input wire [4:0] in0,
    input wire [4:0] in1,
    input wire [4:0] in2,
    input wire [2:0] oneHot,
    output wire [4:0] out
);
assign out = (in0 & {5{oneHot[0]}}) | (in1 & {5{oneHot[1]}}) | (in2 & {5{oneHot[2]}});
endmodule

module MUX5_5b(
    input wire [4:0] in0,
    input wire [4:0] in1,
    input wire [4:0] in2,
    input wire [4:0] in3,
    input wire [4:0] in4,
    input wire [4:0] oneHot,
    output wire [4:0] out
);
assign out = (in0 & {5{oneHot[0]}}) | (in1 & {5{oneHot[1]}}) | (in2 & {5{oneHot[2]}}) | (in3 & {5{oneHot[3]}}) | (in4 & {5{oneHot[4]}});
endmodule

module MUX2_32b(
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [1:0] oneHot,
    output wire [31:0] out
);
assign out = (in0 & {32{oneHot[0]}}) | (in1 & {32{oneHot[1]}});
endmodule

module MUX3_32b(
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [2:0] oneHot,
    output wire [31:0] out
);
assign out = (in0 & {32{oneHot[0]}}) | (in1 & {32{oneHot[1]}}) | (in2 & {32{oneHot[2]}});
endmodule

module MUX4_32b(
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
    input wire [3:0] oneHot,
    output wire [31:0] out
);
assign out = (in0 & {32{oneHot[0]}}) | (in1 & {32{oneHot[1]}}) | (in2 & {32{oneHot[2]}}) | (in3 & {32{oneHot[3]}});
endmodule

module MUX5_32b(
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
    input wire [31:0] in4,
    input wire [4:0] oneHot,
    output wire [31:0] out
);
assign out = (in0 & {32{oneHot[0]}}) | (in1 & {32{oneHot[1]}}) | (in2 & {32{oneHot[2]}}) | (in3 & {32{oneHot[3]}}) | (in4 & {32{oneHot[4]}});
endmodule