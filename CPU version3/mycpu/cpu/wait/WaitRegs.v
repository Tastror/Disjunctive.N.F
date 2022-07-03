`timescale 1ns / 1ps


// WaitReg
// Designed by Tastror, 2022.6.24


// Examples
// low ___   high ---   unknown ***


// example 1
//
// input i2      ___---__________________
//
// clock posedge ^__^__^__^__^__^__^__^__
// begie_save    ___---__________________
// addi_save     ________________________
// end_save      ___---__________________
// ready_go      _________---------------
//
// inner s2      ******------------------   // save normal data [after] a begin_save
// output o2     _________---____________   // output [after] a begin_save (if ready_go is one [after] a begin_save)
//                                             if ready_go is zero, output will wait
//
// if ( (end_save == 1) )
//     flag =w= 1;                          // =w= means "wait equal", which will assign at next clock posedge
// else if ( (ready_go == 1) )
//     flag =w= 0;
//
// flag          ______------____________   
// valid         _________---____________   // valid = flag & ready_go


// example 2
//
// input i2      ___---___---____________
//
// clock posedge ^__^__^__^__^__^__^__^__
// begin_save    ------------____________
// addi_save     ________________________
// end_save      ___------------_________
// ready_go      ------------___---------  // remember, it will still be wrong if you do not let the upper know whether you are ready to go
//
// inner s2      ***___---___------------
// output o2     ******---______---______
//
// flag          ______------------______
// valid         ______------___---______


// example 3
//
// input i3      ___---__________________
// input ai3     _________---____________
//
// clock posedge ^__^__^__^__^__^__^__^__
// begin_save    ___---__________________
// addi_save     ______------____________
// end_save      _________---____________
// ready_go      _______________---______
//
// inner s3      ******------------------
// inner as3     *********___------------
// output o3     _______________---______
// output ao3    _______________---______
//
// flag          ____________------______
// valid         _______________---______



// reset > ~enable > delete > begin_save = addi_save > ready_go = begin_save
//   you can make [ addi_save == ready_go == begin_save == 1 ]
//   to let it work as a normal posedge register



module WaitRegs(
    input wire clk,
    input wire reset,
    input wire enable,

    input wire delete,

    input wire begin_save,
    input wire addi_save,
    input wire end_save,
    input wire ready_go,

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

    input wire [32:0] ai321,
    input wire [32:0] ai322,
    input wire [32:0] ai323,
    input wire [32:0] ai324,
    
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

    output wire [32:0] ao321,
    output wire [32:0] ao322,
    output wire [32:0] ao323,
    output wire [32:0] ao324
);

reg flag;

reg
    s1, s2, s3, s4, s5, s6, s7, s8;
reg [1:0]
    s21, s22;
reg [4:0]
    s51, s52;
reg [5:0]
    s61, s62;
reg [7:0]
    s81, s82, s83, s84;
reg [16:0]
    s161, s162, s163, s164;
reg [32:0]
    s321, s322, s323, s324,
    s325, s326, s327, s328,
    s329, s32a, s32b, s32c;
reg [32:0]
    as321, as322, as323, as324;

always @ (posedge clk)
begin
    if (reset) begin
        flag <= 0;
        s1 <= 0; s2 <= 0; s3 <= 0; s4 <= 0;
        s5 <= 0; s6 <= 0; s7 <= 0; s8 <= 0;
        s21 <= 2'd0; s22 <= 2'd0;
        s51 <= 5'd0; s52 <= 5'd0;
        s61 <= 6'd0; s62 <= 6'd0;
        s81 <= 8'd0; s82 <= 8'd0; s83 <= 8'd0; s84 <= 8'd0;
        s161 <= 16'd0; s162 <= 16'd0; s163 <= 16'd0; s164 <= 16'd0;
        s321 <= 32'd0; s322 <= 32'd0; s323 <= 32'd0; s324 <= 32'd0;
        s325 <= 32'd0; s326 <= 32'd0; s327 <= 32'd0; s328 <= 32'd0;
        s329 <= 32'd0; s32a <= 32'd0; s32b <= 32'd0; s32c <= 32'd0;
        as321 <= 32'd0; as322 <= 32'd0; as323 <= 32'd0; as324 <= 32'd0;
    end

    else if (~enable) begin
        ; // do nothing
    end

    else if (delete) begin
        flag <= 0;
        s1 <= 0; s2 <= 0; s3 <= 0; s4 <= 0;
        s5 <= 0; s6 <= 0; s7 <= 0; s8 <= 0;
        s21 <= 2'd0; s22 <= 2'd0;
        s51 <= 5'd0; s52 <= 5'd0;
        s61 <= 6'd0; s62 <= 6'd0;
        s81 <= 8'd0; s82 <= 8'd0; s83 <= 8'd0; s84 <= 8'd0;
        s161 <= 16'd0; s162 <= 16'd0; s163 <= 16'd0; s164 <= 16'd0;
        s321 <= 32'd0; s322 <= 32'd0; s323 <= 32'd0; s324 <= 32'd0;
        s325 <= 32'd0; s326 <= 32'd0; s327 <= 32'd0; s328 <= 32'd0;
        s329 <= 32'd0; s32a <= 32'd0; s32b <= 32'd0; s32c <= 32'd0;
        as321 <= 32'd0; as322 <= 32'd0; as323 <= 32'd0; as324 <= 32'd0;
    end

    else begin

        if (begin_save) begin
            s1 <= i1; s2 <= i2; s3 <= i3; s4 <= i4;
            s5 <= i5; s6 <= i6; s7 <= i7; s8 <= i8;
            s21 <= i21; s22 <= i22;
            s51 <= i51; s52 <= i52;
            s61 <= i61; s62 <= i62;
            s81 <= i81; s82 <= i82; s83 <= i83; s84 <= i84;
            s161 <= i161; s162 <= i162; s163 <= i163; s164 <= i164;
            s321 <= i321; s322 <= i322; s323 <= i323; s324 <= i324;
            s325 <= i325; s326 <= i326; s327 <= i327; s328 <= i328;
            s329 <= i329; s32a <= i32a; s32b <= i32b; s32c <= i32c;
        end

        if (addi_save) begin
            as321 <= ai321;
            as322 <= ai322;
            as323 <= ai323;
            as324 <= ai324;
        end

        if (end_save) begin
            flag <= 1'b1;    
        end

        else if (ready_go) begin
            flag <= 1'b0;
        end
        
    end
end

wire valid;
assign valid = enable & ready_go & flag;

assign o1 = valid ? s1 : 0;
assign o2 = valid ? s2 : 0;
assign o3 = valid ? s3 : 0;
assign o4 = valid ? s4 : 0;
assign o5 = valid ? s5 : 0;
assign o6 = valid ? s6 : 0;
assign o7 = valid ? s7 : 0;
assign o8 = valid ? s8 : 0;
assign o21 = valid ? s21 : 0;
assign o22 = valid ? s22 : 0;
assign o51 = valid ? s51 : 0;
assign o52 = valid ? s52 : 0;
assign o61 = valid ? s61 : 0;
assign o62 = valid ? s62 : 0;
assign o81 = valid ? s81 : 0;
assign o82 = valid ? s82 : 0;
assign o83 = valid ? s83 : 0;
assign o84 = valid ? s84 : 0;
assign o161 = valid ? s161 : 0;
assign o162 = valid ? s162 : 0;
assign o163 = valid ? s163 : 0;
assign o164 = valid ? s164 : 0;
assign o321 = valid ? s321 : 0;
assign o322 = valid ? s322 : 0;
assign o323 = valid ? s323 : 0;
assign o324 = valid ? s324 : 0;
assign o325 = valid ? s325 : 0;
assign o326 = valid ? s326 : 0;
assign o327 = valid ? s327 : 0;
assign o328 = valid ? s328 : 0;
assign o329 = valid ? s329 : 0;
assign o32a = valid ? s32a : 0;
assign o32b = valid ? s32b : 0;
assign o32c = valid ? s32c : 0;

assign ao321 = valid ? as321 : 0;
assign ao322 = valid ? as322 : 0;
assign ao323 = valid ? as323 : 0;
assign ao324 = valid ? as324 : 0;

endmodule
