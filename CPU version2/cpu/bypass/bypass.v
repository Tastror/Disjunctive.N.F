`timescale 1ns / 1ps



module bypass(
    // input

    input wire [4:0] used_addr,
    input wire [4:0] ME_reg_waddr,
    input wire [4:0] WB_reg_waddr,

    input wire [31:0] old_data,
    input wire [31:0] ME_alures_merge,
    input wire [31:0] WB_reg_wdata,

    // output
    
    output wire [31:0] changed_data
);

wire [2:0] bypass_mux;
wire use_it = |used_addr;  // addr is not 00000
assign bypass_mux[1] = use_it & (used_addr == ME_reg_waddr);
assign bypass_mux[2] = use_it & ~bypass_mux[1] & (used_addr == WB_reg_waddr);
assign bypass_mux[0] = ~bypass_mux[1] & ~bypass_mux[2];

MUX3_32b MUX3_32b_bypass_change_alusrc1( .oneHot(bypass_mux),
    .in0(old_data), .in1(ME_alures_merge), .in2(WB_reg_wdata), .out(changed_data) );

endmodule



module bypass_low_high(
    // input
    input wire ME_wen, WB_wen,
    input wire [31:0] old_data,
    input wire [31:0] ME_data,
    input wire [31:0] WB_data,
    // output
    output wire [31:0] new_data
);

wire [2:0] bypass_mux;
assign bypass_mux[1] = (ME_wen);
assign bypass_mux[2] = ~bypass_mux[1] & (WB_wen);
assign bypass_mux[0] = ~bypass_mux[1] & ~bypass_mux[2];

MUX3_32b MUX3_32b_bypass_change_alusrc1( .oneHot(bypass_mux),
    .in0(old_data), .in1(ME_data), .in2(WB_data), .out(new_data) );

endmodule