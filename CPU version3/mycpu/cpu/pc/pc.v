`timescale 1ns / 1ps



module pc_if_reg(

    input wire reset,
    input wire clk,
    input wire wait_stop,

    // input
    input wire EX_ctl_pc_first_mux,
    input wire [3:0] ID_ctl_pc_second_mux,

    input wire [31:0] EX_pc_plus_4_plus_4imm,
    input wire [25:0] ID_index,
    input wire [31:0] ID_may_choke_rs_data,
    
    input wire need_EX_choke,

    // output
    output wire [31:0] IF_pc_out,
    output wire [31:0] IF_pc_plus_4
);

parameter PC_INITIAL = 32'hbfc00000;
parameter PC_BREAK = 32'hbfc00380;

reg [1:0] update_pc_next;
reg [31:0] pc_next;
reg [31:0] pc;

assign IF_pc_out = pc;
assign IF_pc_plus_4 = pc + 32'h4;

always @ (posedge clk) begin
    if (reset) begin
        pc_next <= PC_INITIAL;
        update_pc_next <= 2;
    end
end

always @ (posedge clk) begin
    if (reset)
        ; // nothing
    else if (update_pc_next == 2'h2)
        ; // nothing
    else if (update_pc_next == 2'h1) begin
        if (need_EX_choke)
            update_pc_next <= 2'h0;
        else begin
            update_pc_next <= 2'h2;
            if (ID_ctl_pc_second_mux[1])
                pc_next = {{IF_pc_plus_4[31:28]}, {ID_index[25:0]}, {2'b00}};
            else if (ID_ctl_pc_second_mux[2])
                pc_next = ID_may_choke_rs_data;
            else if (ID_ctl_pc_second_mux[3])
                pc_next = PC_BREAK;
            else
                if (EX_ctl_pc_first_mux)
                    pc_next = EX_pc_plus_4_plus_4imm;
                else
                    pc_next = IF_pc_plus_4;
        end
    end
    else begin
        update_pc_next <= 2'h2;
        if (ID_ctl_pc_second_mux[1])
            pc_next = {{IF_pc_plus_4[31:28]}, {ID_index[25:0]}, {2'b00}};
        else if (ID_ctl_pc_second_mux[2])
            pc_next = ID_may_choke_rs_data;
        else if (ID_ctl_pc_second_mux[3])
            pc_next = PC_BREAK;
        else
            if (EX_ctl_pc_first_mux)
                pc_next = EX_pc_plus_4_plus_4imm;
            else
                pc_next = IF_pc_plus_4;
    end
    
end

always @ (posedge clk) begin
    if (reset | wait_stop)
        ; // nothing
    else begin
        pc <= pc_next;
        update_pc_next <= 1;
    end
end

endmodule



module pc_ex(
    // input
    input wire [31:0] pc_in_ex,
    input wire [31:0] imm_32_in_ex,
    // output
    output wire [31:0] pc_to_mem
);
assign pc_to_mem = pc_in_ex + {imm_32_in_ex[29:0], 2'h0};
endmodule
