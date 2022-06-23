`timescale 1ns / 1ps



module choke(
    // input
    input wire I_am_reading_reg,
    input wire he_is_reading_ram,
    input wire [4:0] used_addr,
    input wire [4:0] EX_addr,
    // output
    output wire IFID_ready,
    output wire IDEXE_delete
);

wire activate;
assign activate = I_am_reading_reg & he_is_reading_ram & (used_addr == EX_addr) & |used_addr;
assign IFID_ready = ~activate;
assign IDEXE_delete = activate;

endmodule



module choke_jr(
    // input
    input wire I_am_reading,
    input wire [4:0] used_addr,
    input wire [4:0] EX_addr,
    input wire [4:0] ME_addr,
    // output
    output wire IFID_ready,
    output wire IDEXE_delete
);

wire activate;
assign activate = I_am_reading & ((used_addr == EX_addr) | (used_addr == ME_addr)) & |used_addr;
assign IFID_ready = ~activate;
assign IDEXE_delete = activate;

endmodule



module choke_chosen(
    // input
    input wire chosen_return_ready,
    input wire chosen_choke,
    // output
    output wire IFID_ready,
    output wire IDEXE_delete
);

wire activate;
assign activate = chosen_choke & chosen_return_ready;
assign IFID_ready = ~activate;
assign IDEXE_delete = activate;

endmodule