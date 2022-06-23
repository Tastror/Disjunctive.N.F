`timescale 1ns / 1ps


// WaitReg
// Designed by Tastror, 2022.6.24


// Examples
// low ___   high ---   unknown ***


// example 1
//
// input i2      ---___------___---___---
//
// clock posedge ^__^__^__^__^__^__^__^__^__
// pause         ___---__________________
// save          _________---____________
// resume        __________________---___
//
// inner s2      ************---------------
// output o2     ******_______________---___


// example 2
//
// input i21[0]  ---___---______---___---
// input i21[1]  ---______---___---___---
//
// clock posedge ^__^__^__^__^__^__^__^__^__
// pause         ___---(-)_______________
// save          ______(-)---____________
// resume        _______________---(-)___
//
// () means can be ignored
//
// inner s21[0]  *********---_______________
// inner s21[1]  *********___---------------
// output o21[0] ******_____________________
// output o21[1] ******____________---______



// reset > ~enable > delete > save = resume > pause
//   you can make [ save == resume == pause == 1 ]
//   to let it work as a normal posedge register


module WaitRegs(
    input wire clk,
    input wire reset,
    input wire enable,

    input wire delete,

    input wire pause,
    input wire save,
    input wire resume,

    input wire i1,
    input wire i2,
    input wire i3,
    input wire i4,
    input wire i5,
    input wire i6,
    input wire i7,
    input wire i8,
    input wire [1:0] i21,
    input wire [1:0] i22,
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
    input wire [32:0] i328,
    input wire [32:0] i329,
    input wire [32:0] i32a,
    input wire [32:0] i32b,
    input wire [32:0] i32c,
    input wire [32:0] i32d,
    
    output wire o1,
    output wire o2,
    output wire o3,
    output wire o4,
    output wire o5,
    output wire o6,
    output wire o7,
    output wire o8,
    output wire [1:0] o21,
    output wire [1:0] o22,
    output wire [4:0] o51,
    output wire [4:0] o52,
    output wire [5:0] o61,
    output wire [5:0] o62,
    output wire [7:0] o81,
    output wire [7:0] o82,
    output wire [7:0] o83,
    output wire [7:0] o84,
    output wire [16:0] o161,
    output wire [16:0] o162,
    output wire [16:0] o163,
    output wire [16:0] o164,
    output wire [32:0] o321,
    output wire [32:0] o322,
    output wire [32:0] o323,
    output wire [32:0] o324,
    output wire [32:0] o325,
    output wire [32:0] o326,
    output wire [32:0] o327,
    output wire [32:0] o328,
    output wire [32:0] o329,
    output wire [32:0] o32a,
    output wire [32:0] o32b,
    output wire [32:0] o32c,
    output wire [32:0] o32d
);

reg flag;
reg last_pause;
reg last_resume;

reg s1;
reg s2;
reg s3;
reg s4;
reg s5;
reg s6;
reg s7;
reg s8;
reg [1:0] s21;
reg [1:0] s22;
reg [4:0] s51;
reg [4:0] s52;
reg [5:0] s61;
reg [5:0] s62;
reg [7:0] s81;
reg [7:0] s82;
reg [7:0] s83;
reg [7:0] s84;
reg [16:0] s161;
reg [16:0] s162;
reg [16:0] s163;
reg [16:0] s164;
reg [32:0] s321;
reg [32:0] s322;
reg [32:0] s323;
reg [32:0] s324;
reg [32:0] s325;
reg [32:0] s326;
reg [32:0] s327;
reg [32:0] s328;
reg [32:0] s329;
reg [32:0] s32a;
reg [32:0] s32b;
reg [32:0] s32c;
reg [32:0] s32d;

always @ (posedge clk)
begin
    if (reset) begin
        flag <= 0;
        last_pause <= 0;
        last_resume <= 0;
        s1 <= 0;
        s2 <= 0;
        s3 <= 0;
        s4 <= 0;
        s5 <= 0;
        s6 <= 0;
        s7 <= 0;
        s8 <= 0;
        s21 <= 2'd0;
        s22 <= 2'd0;
        s51 <= 5'd0;
        s52 <= 5'd0;
        s61 <= 6'd0;
        s62 <= 6'd0;
        s81 <= 8'd0;
        s82 <= 8'd0;
        s83 <= 8'd0;
        s84 <= 8'd0;
        s161 <= 16'd0;
        s162 <= 16'd0;
        s163 <= 16'd0;
        s164 <= 16'd0;
        s321 <= 32'd0;
        s322 <= 32'd0;
        s323 <= 32'd0;
        s324 <= 32'd0;
        s325 <= 32'd0;
        s326 <= 32'd0;
        s327 <= 32'd0;
        s328 <= 32'd0;
        s329 <= 32'd0;
        s32a <= 32'd0;
        s32b <= 32'd0;
        s32c <= 32'd0;
        s32d <= 32'd0;
    end

    else if (~enable) begin
        ; // do nothing
    end

    else if (delete) begin
        flag <= 0;
        last_pause <= 0;
        last_resume <= 0;
        s1 <= 0;
        s2 <= 0;
        s3 <= 0;
        s4 <= 0;
        s5 <= 0;
        s6 <= 0;
        s7 <= 0;
        s8 <= 0;
        s21 <= 2'd0;
        s22 <= 2'd0;
        s51 <= 5'd0;
        s52 <= 5'd0;
        s61 <= 6'd0;
        s62 <= 6'd0;
        s81 <= 8'd0;
        s82 <= 8'd0;
        s83 <= 8'd0;
        s84 <= 8'd0;
        s161 <= 16'd0;
        s162 <= 16'd0;
        s163 <= 16'd0;
        s164 <= 16'd0;
        s321 <= 32'd0;
        s322 <= 32'd0;
        s323 <= 32'd0;
        s324 <= 32'd0;
        s325 <= 32'd0;
        s326 <= 32'd0;
        s327 <= 32'd0;
        s328 <= 32'd0;
        s329 <= 32'd0;
        s32a <= 32'd0;
        s32b <= 32'd0;
        s32c <= 32'd0;
        s32d <= 32'd0;
    end

    else begin

        last_pause <= pause;
        last_resume <= resume;

        if (save) begin
            s1 <= i1;
            s2 <= i2;
            s3 <= i3;
            s4 <= i4;
            s5 <= i5;
            s6 <= i6;
            s7 <= i7;
            s8 <= i8;
            s21 <= i21;
            s22 <= i22;
            s51 <= i51;
            s52 <= i52;
            s61 <= i61;
            s62 <= i62;
            s81 <= i81;
            s82 <= i82;
            s83 <= i83;
            s84 <= i84;
            s161 <= i161;
            s162 <= i162;
            s163 <= i163;
            s164 <= i164;
            s321 <= i321;
            s322 <= i322;
            s323 <= i323;
            s324 <= i324;
            s325 <= i325;
            s326 <= i326;
            s327 <= i327;
            s328 <= i328;
            s329 <= i329;
            s32a <= i32a;
            s32b <= i32b;
            s32c <= i32c;
            s32d <= i32d;
        end

        if (pause) begin
            flag <= 1'b1;
        end

        else if (flag == 1'b1 && last_resume) begin
            flag <= 1'b0;
        end
        
    end
end

assign o1 = enable & last_resume & flag ? s1 : 0;
assign o2 = enable & last_resume & flag ? s2 : 0;
assign o3 = enable & last_resume & flag ? s3 : 0;
assign o4 = enable & last_resume & flag ? s4 : 0;
assign o5 = enable & last_resume & flag ? s5 : 0;
assign o6 = enable & last_resume & flag ? s6 : 0;
assign o7 = enable & last_resume & flag ? s7 : 0;
assign o8 = enable & last_resume & flag ? s8 : 0;
assign o21 = enable & last_resume & flag ? s21 : 0;
assign o22 = enable & last_resume & flag ? s22 : 0;
assign o51 = enable & last_resume & flag ? s51 : 0;
assign o52 = enable & last_resume & flag ? s52 : 0;
assign o61 = enable & last_resume & flag ? s61 : 0;
assign o62 = enable & last_resume & flag ? s62 : 0;
assign o81 = enable & last_resume & flag ? s81 : 0;
assign o82 = enable & last_resume & flag ? s82 : 0;
assign o83 = enable & last_resume & flag ? s83 : 0;
assign o84 = enable & last_resume & flag ? s84 : 0;
assign o161 = enable & last_resume & flag ? s161 : 0;
assign o162 = enable & last_resume & flag ? s162 : 0;
assign o163 = enable & last_resume & flag ? s163 : 0;
assign o164 = enable & last_resume & flag ? s164 : 0;
assign o321 = enable & last_resume & flag ? s321 : 0;
assign o322 = enable & last_resume & flag ? s322 : 0;
assign o323 = enable & last_resume & flag ? s323 : 0;
assign o324 = enable & last_resume & flag ? s324 : 0;
assign o325 = enable & last_resume & flag ? s325 : 0;
assign o326 = enable & last_resume & flag ? s326 : 0;
assign o327 = enable & last_resume & flag ? s327 : 0;
assign o328 = enable & last_resume & flag ? s328 : 0;
assign o329 = enable & last_resume & flag ? s329 : 0;
assign o32a = enable & last_resume & flag ? s32a : 0;
assign o32b = enable & last_resume & flag ? s32b : 0;
assign o32c = enable & last_resume & flag ? s32c : 0;
assign o32d = enable & last_resume & flag ? s32d : 0;

endmodule
