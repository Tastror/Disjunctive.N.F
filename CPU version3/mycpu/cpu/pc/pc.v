`timescale 1ns / 1ps



module pc_if_reg(
    // global input
    input wire clk,
    input wire reset,
    input wire enable,

    // input
    input wire pc_call_begin,
    input wire pc_next_update_begin,
    input wire [1:0] EX_ctl_pc_first_mux,
    input wire [4:0] ID_ctl_pc_second_mux,
    input wire [31:0] EX_pc_plus_4_plus_4imm,
    input wire [25:0] ID_index,
    input wire [31:0] ID_may_choke_rs_data,
    input wire [31:0] pc_recover,

    // output
    output wire [31:0] IF_pc_out,
    output wire [31:0] IF_pc_plus_4,
    output wire pc_instruction_ready,
    output wire [31:0] return_instruction,

    // output (face to cache)
    output reg cache_call_begin,
    output reg dont_use_next,

    // input (face to cache)
    input wire cache_return_ready,
    input wire [31:0] cache_return_instruction,

    // input (face to mem)
    input wire mem_return_ready,
    input wire ex_lw_may_choke,
    input wire mem_lw_return_ready
);

parameter PC_INITIAL = 32'hbfc00000;
parameter PC_BREAK = 32'hbfc00380;

reg [31:0] pc_next;
reg [31:0] pc;
reg [3:0] flag1, flag2;
reg flag3, ready_flag;
reg [31:0] buff_instruction;
reg [4:0] tmp_ID_ctl_pc_second_mux;
reg [1:0] tmp_EX_ctl_pc_first_mux;
reg tmp_first_mux_done, tmp_second_mux_done, tmp_update_done;

wire [4:0] all_ID_ctl_pc_second_mux;
wire [1:0] all_EX_ctl_pc_first_mux;
wire first_mux_done, second_mux_done, update_done;

assign update_done = tmp_update_done | pc_next_update_begin;
assign first_mux_done = tmp_first_mux_done | |EX_ctl_pc_first_mux;
assign second_mux_done = tmp_second_mux_done | |ID_ctl_pc_second_mux;
assign all_EX_ctl_pc_first_mux = EX_ctl_pc_first_mux;
assign all_ID_ctl_pc_second_mux = ID_ctl_pc_second_mux;


assign IF_pc_out = pc;
assign IF_pc_plus_4 = pc + 32'h4;
assign pc_instruction_ready = (cache_return_ready | ready_flag) & mem_return_ready;
assign return_instruction = cache_return_instruction | buff_instruction;

always @ (posedge clk) begin

    if (reset) begin
        pc_next <= PC_INITIAL;
        pc <= 32'h0;
        flag1 <= 4'h0;
        flag2 <= 4'h0;
        ready_flag <= 4'h0;
        buff_instruction <= 4'h0;
        cache_call_begin <= 1'b0;
        dont_use_next <= 1'b0;
        tmp_EX_ctl_pc_first_mux <= 0;
        tmp_ID_ctl_pc_second_mux <= 0;
        tmp_first_mux_done <= 0;
        tmp_second_mux_done <= 0;
        tmp_update_done <= 0;
    end

    else if (~enable) begin
        ; // nothing
    end

    else begin

        // after reset
        if (flag1 == 4'h0 && pc_call_begin) begin
            flag1 <= 4'h5;
            flag2 <= 4'h5;
            flag3 <= 0;
            pc <= pc_next;
            cache_call_begin <= 1'b1;
        end

        // not after reset and normal, sw
        if (flag1 == 4'h4 && flag2 == 4'h4 && ~flag3 && pc_call_begin && ~ex_lw_may_choke) begin
            flag1 <= 4'h5;
            cache_call_begin <= 1'b1;
        end

        // not after reset and lw
        if (flag1 == 4'h4 && flag2 == 4'h4 && pc_call_begin && ex_lw_may_choke) begin
            flag3 <= 1;
        end

        // lw begin
        if (flag1 == 4'h4 && flag2 == 4'h4 && pc_call_begin && flag3 && mem_lw_return_ready) begin
            flag3 <= 0;
            flag1 <= 4'h5;
            cache_call_begin <= 1'b1;
        end
            

        if (flag1 == 4'h5) begin
            cache_call_begin <= 1'b0;
            dont_use_next <= 1'b0;
        end

        if (flag1 == 4'h5 && cache_return_ready && mem_return_ready) begin
            pc <= pc_next;
            flag1 <= 4'h4;
            flag2 <= 4'h5;
        end

        if (flag1 == 4'h5 && cache_return_ready && ~mem_return_ready) begin
            flag1 <= 4'h6;
            ready_flag <= 4'h1;
            buff_instruction <= cache_return_instruction;
        end

        if (flag1 == 4'h6 && mem_return_ready) begin
            pc <= pc_next;
            flag1 <= 4'h4;
            flag2 <= 4'h5;
            ready_flag <= 4'h0;
            buff_instruction <= 0;
        end

        if (flag2 == 4'h5 && pc_next_update_begin) begin
            tmp_update_done <= 1;
        end

        if (flag2 == 4'h5 && |EX_ctl_pc_first_mux) begin
            tmp_EX_ctl_pc_first_mux <= EX_ctl_pc_first_mux;
            tmp_first_mux_done <= 1;
        end

        if (flag2 == 4'h5 && |ID_ctl_pc_second_mux) begin
            tmp_ID_ctl_pc_second_mux <= ID_ctl_pc_second_mux;
            tmp_second_mux_done <= 1;
        end

        if (flag2 == 4'h5 && update_done && first_mux_done && second_mux_done) begin
            flag2 <= 4'h4;
            if (all_ID_ctl_pc_second_mux[0]) begin
                if (all_EX_ctl_pc_first_mux[0])
                    pc_next <= IF_pc_plus_4;
                else if (all_EX_ctl_pc_first_mux[1])
                    pc_next <= EX_pc_plus_4_plus_4imm;
                else
                    ; // wrong here
            end
            else if (all_ID_ctl_pc_second_mux[1])
                pc_next <= {{IF_pc_plus_4[31:28]}, {ID_index[25:0]}, {2'b00}};
            else if (all_ID_ctl_pc_second_mux[2])
                pc_next <= ID_may_choke_rs_data;
            else if (all_ID_ctl_pc_second_mux[3]) begin
                pc_next <= PC_BREAK;
                dont_use_next <= 1'b1;
            end
            else if (all_ID_ctl_pc_second_mux[4]) begin
                pc_next <= pc_recover;
                dont_use_next <= 1'b1;
            end
            else
                ; // wrong here
            
            tmp_EX_ctl_pc_first_mux <= 0;
            tmp_ID_ctl_pc_second_mux <= 0;
            tmp_first_mux_done <= 0;
            tmp_second_mux_done <= 0;
            tmp_update_done <= 0;
        end

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
