`timescale 1ns / 1ps



module choke(
    // input
    input wire I_am_reading_reg,
    input wire he_is_reading_ram,
    input wire [4:0] used_addr,
    input wire [4:0] EX_addr,
    // output
    output wire IFID_wait_stop,
    output wire IDEXE_reset
);

assign activate = I_am_reading_reg & he_is_reading_ram & (used_addr == EX_addr) & |used_addr;
assign IFID_wait_stop = activate;
assign IDEXE_reset = activate;

endmodule



module choke_jr(
    // input
    input wire I_am_reading,
    input wire [4:0] used_addr,
    input wire [4:0] EX_addr,
    input wire [4:0] ME_addr,
    // output
    output wire IFID_wait_stop,
    output wire IDEXE_reset
);

assign activate = I_am_reading & ((used_addr == EX_addr) | (used_addr == ME_addr)) & |used_addr;
assign IFID_wait_stop = activate;
assign IDEXE_reset = activate;

endmodule



module choke_chosen(
    // input
    input wire clk,
    input wire chosen_choke,
    // output
    output wire IFID_wait_stop,
    output wire IDEXE_reset
);

reg k;

always @ (posedge clk) begin
    k <= IFID_wait_stop;
end

assign IFID_wait_stop = chosen_choke & (k ^ chosen_choke);
assign IDEXE_reset = chosen_choke & (k ^ chosen_choke);

endmodule