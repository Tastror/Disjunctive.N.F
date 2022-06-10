`timescale 1ns / 1ps



module WaitRegs(
    input wire clk,
    input wire en,
    input wire rst,

    input wire i1,
    input wire i2,
    input wire i3,
    input wire i4,
    input wire i5,
    input wire i6,
    input wire i7,
    input wire i8,
    input wire [4:0] i51,
    input wire [4:0] i52,
    input wire [5:0] i61,
    input wire [5:0] i62,
    input wire [7:0] i81,
    input wire [7:0] i82,
    input wire [7:0] i83,
    input wire [7:0] i84,
    input wire [16:0] i161,
    input wire [16:0] i162,
    input wire [16:0] i163,
    input wire [16:0] i164,
    input wire [32:0] i321,
    input wire [32:0] i322,
    input wire [32:0] i323,
    input wire [32:0] i324,
    input wire [32:0] i325,
    input wire [32:0] i326,
    input wire [32:0] i327,
    
    output reg o1,
    output reg o2,
    output reg o3,
    output reg o4,
    output reg o5,
    output reg o6,
    output reg o7,
    output reg o8,
    output reg [4:0] o51,
    output reg [4:0] o52,
    output reg [5:0] o61,
    output reg [5:0] o62,
    output reg [7:0] o81,
    output reg [7:0] o82,
    output reg [7:0] o83,
    output reg [7:0] o84,
    output reg [16:0] o161,
    output reg [16:0] o162,
    output reg [16:0] o163,
    output reg [16:0] o164,
    output reg [32:0] o321,
    output reg [32:0] o322,
    output reg [32:0] o323,
    output reg [32:0] o324,
    output reg [32:0] o325,
    output reg [32:0] o326,
    output reg [32:0] o327
);

always @ (posedge clk)
begin
    if (rst) begin
        o1 <= 0;
        o2 <= 0;
        o3 <= 0;
        o4 <= 0;
        o5 <= 0;
        o6 <= 0;
        o7 <= 0;
        o8 <= 0;
        o51 <= 5'd0;
        o52 <= 5'd0;
        o61 <= 6'd0;
        o62 <= 6'd0;
        o81 <= 8'd0;
        o82 <= 8'd0;
        o83 <= 8'd0;
        o84 <= 8'd0;
        o161 <= 16'd0;
        o162 <= 16'd0;
        o163 <= 16'd0;
        o164 <= 16'd0;
        o321 <= 32'd0;
        o322 <= 32'd0;
        o323 <= 32'd0;
        o324 <= 32'd0;
        o325 <= 32'd0;
        o326 <= 32'd0;
        o327 <= 32'd0;
    end else if (en) begin
        o1 <= i1;
        o2 <= i2;
        o3 <= i3;
        o4 <= i4;
        o5 <= i5;
        o6 <= i6;
        o7 <= i7;
        o8 <= i8;
        o51 <= i51;
        o52 <= i52;
        o61 <= i61;
        o62 <= i62;
        o81 <= i81;
        o82 <= i82;
        o83 <= i83;
        o84 <= i84;
        o161 <= i161;
        o162 <= i162;
        o163 <= i163;
        o164 <= i164;
        o321 <= i321;
        o322 <= i322;
        o323 <= i323;
        o324 <= i324;
        o325 <= i325;
        o326 <= i326;
        o327 <= i327;
    end
end

endmodule
