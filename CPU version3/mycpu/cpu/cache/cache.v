`timescale 1ns / 1ps



module inst_cache(
    // global input
    input wire clk,
    input wire reset,
    input wire enable,

    // input (face to CPU)
    input wire cache_call_begin,
    input wire dont_use_next,
    input wire [31:0] pc,

    // output (face to CPU)
    output reg cache_return_ready,
    output reg [31:0] cache_return_instruction,

    // output (face to interface)
    output reg inst_interface_call_begin,
    output reg [31:0] inst_interface_addr,

    // input (face to interface)
    input wire inst_interface_return_ready,
    input wire [31:0] inst_interface_rdata
);



// 64KB instruction_reg, store instrution
reg [31:0] instruction_reg [0:16383];
// 64KB name, **map key is 14 bit**, store pc
reg [31:0] name [0:16383];
integer i;



wire judge_name;
assign judge_name = (name[pc[15:2]] == pc);
reg [31:0] temp_pc_reg;
reg [3:0] flag;
// 3'h0 ready
// 3'h1 use self
// 3'h2 call inst_interface
// 3'h3 call inst_interface end



always @ (posedge clk) begin

    if (reset) begin

        for (i = 0; i < 16384; i = i + 1) begin
            name[i] <= 32'h0;
        end

        cache_return_ready <= 1'b0;
        cache_return_instruction <= 32'h0;
        inst_interface_call_begin <= 1'b0;
        inst_interface_addr <= 32'h0;
        flag <= 4'h0;
        
    end

    else if (~enable) begin
        ; // do nothing
    end

    else begin

        // donot use next

        if (cache_call_begin && flag == 4'h0 && dont_use_next) begin
            flag <= 4'h1;
            cache_return_ready <= 1'b1;
            cache_return_instruction <= 32'h0;
        end

        // use self

        if (cache_call_begin && flag == 4'h0 && judge_name && ~dont_use_next) begin
            flag <= 4'h1;
            cache_return_ready <= 1'b1;
            cache_return_instruction <= instruction_reg[pc[15:2]];
        end

        if (flag == 4'h1) begin
            flag <= 4'h0;
            cache_return_ready <= 1'b0;
            cache_return_instruction <= 32'h0;
        end

        // call inst_interface

        if (cache_call_begin && flag == 4'h0 && ~judge_name && ~dont_use_next) begin
            flag <= 4'h2;
            inst_interface_call_begin <= 1'b1;
            if (pc >= 32'ha000_0000 && pc <= 32'hbfff_ffff) begin
                inst_interface_addr <= pc - 32'ha000_0000;
                temp_pc_reg <= pc - 32'ha000_0000;
            end
            else if (pc >= 32'h8000_0000 && pc <= 32'h9fff_ffff) begin
                inst_interface_addr <= pc - 32'h8000_0000;
                temp_pc_reg <= pc - 32'h8000_0000;
            end
        end

        if (flag == 4'h2 && ~inst_interface_return_ready) begin
            inst_interface_call_begin <= 1'b0;
            inst_interface_addr <= 32'h0;
        end

        if (flag == 4'h2 && inst_interface_return_ready) begin
            flag <= 4'h3;
            inst_interface_call_begin <= 1'b0;
            inst_interface_addr <= 32'h0;
            cache_return_ready <= 1'b1;
            cache_return_instruction <= inst_interface_rdata;
            name[temp_pc_reg[15:2]] <= temp_pc_reg;
            instruction_reg[pc[15:2]] <= inst_interface_rdata;
        end

        if (flag == 4'h3) begin
            flag <= 4'h0;
            cache_return_ready <= 1'b0;
            cache_return_instruction <= 32'h0;
        end

    end
    
end

endmodule



module data_cache(
    // global input
    input wire clk,
    input wire reset,
    input wire enable,

    // input (face to CPU)
    input wire wen,
    input wire [2:0] size,
    input wire [31:0] addr,
    input wire [31:0] data,
    input wire cache_call_begin,
    input wire zero_extend,
    
    // output (face to CPU)
    output wire cache_return_ready,
    output wire [31:0] cache_return_rdata,

    // output data (face to interface)
    output reg data_interface_enable,
    output reg write_enable,
    output reg [2:0] read_size,
    output reg [2:0] write_size,
    output reg [31:0] data_interface_raddr,
    output reg [31:0] data_interface_waddr,
    output reg [31:0] data_interface_wdata,
    output reg data_interface_call_begin,

    // input data (face to interface)
    input wire data_interface_return_ready,
    input wire [31:0] data_interface_rdata 
);

// lb, lh, lw
wire [7:0] pre_byte;
wire [15:0] pre_halfword;
assign pre_byte = data_interface_raddr[1:0] == 2'b00 ?
                    data_interface_rdata[7:0] : (
                        data_interface_raddr[1:0] == 2'b01 ?
                        data_interface_rdata[15:8] : (
                            data_interface_raddr[1:0] == 2'b10 ?
                            data_interface_rdata[23:16] :
                            data_interface_rdata[31:24]
                        )
                    );
assign pre_halfword = data_interface_raddr[1] ? data_interface_rdata[31:16] : data_interface_rdata[15:0];
assign cache_return_rdata = tmp_size[0] ? (
                                tmp_zero_extend ?
                                {24'h0, pre_byte} :
                                {{24{pre_byte[7]}}, pre_byte}
                            ) : (
                                tmp_size[1] ? (
                                    tmp_zero_extend ?
                                    {16'h0, pre_halfword} :
                                    {{16{pre_halfword[15]}}, pre_halfword}
                                ) :
                                data_interface_rdata
                            );
assign cache_return_ready = data_interface_return_ready;

reg [3:0] flag, test;
reg [2:0] tmp_size;
reg tmp_zero_extend;

always @ (posedge clk) begin
    if (reset) begin
        test <= 0;
        flag <= 0;
        data_interface_enable <= 0;
        write_enable <= 0;
        read_size <= 0;
        write_size <= 0;
        tmp_size <= 0;
        tmp_zero_extend <= 0;
        data_interface_raddr <= 0;
        data_interface_waddr <= 0;
        data_interface_wdata <= 0;
        data_interface_call_begin <= 0;
    end

    else begin
        if (flag == 0 && enable && ~wen) begin
            flag <= 1;
            data_interface_enable <= 1;
            read_size <= size;
            tmp_size <= size;
            tmp_zero_extend <= zero_extend;
            if (addr >= 32'h8000_0000 && addr <= 32'h9fff_ffff) begin
                data_interface_raddr <= addr - 32'h8000_0000;
            end
            else if (addr >= 32'ha000_0000 && addr <= 32'hbfff_ffff) begin
                data_interface_raddr <= addr - 32'ha000_0000;
            end
            // data_interface_raddr <= {addr[31:14], addr[13:6], 6'b0};
            data_interface_call_begin <= 1;
        end

        if (flag == 0 && enable && wen) begin
            flag <= 1;
            data_interface_enable <= 1;
            write_enable <= 1;
            write_size <= size;
            tmp_size <= size;
            if (addr >= 32'h8000_0000 && addr <= 32'h9fff_ffff)
                data_interface_waddr <= addr - 32'h8000_0000;
            if (addr >= 32'ha000_0000 && addr <= 32'hbfff_ffff)
                data_interface_waddr <= addr - 32'ha000_0000;
            // data_interface_waddr <= {addr[31:14], addr[13:6], 6'b0};
            if (size[0]) begin
                if (addr[1:0] == 2'b00)
                    data_interface_wdata <= {24'h0, data[7:0]};
                else if (addr[1:0] == 2'b01)
                    data_interface_wdata <= {16'h0, data[7:0], 8'h0};
                else if (addr[1:0] == 2'b10)
                    data_interface_wdata <= {8'h0, data[7:0], 16'h0};
                else if (addr[1:0] == 2'b11)
                    data_interface_wdata <= {data[7:0], 24'h0};
            end 
            else if (size[1]) begin
               if (addr[1] == 1'b0)
                    data_interface_wdata <= {16'h0, data[15:0]};
                else if (addr[1] == 1'b1)
                    data_interface_wdata <= {data[15:0], 16'h0};
            end
            else begin
                data_interface_wdata <= data;
            end
            data_interface_call_begin <= 1;
        end

        if (flag == 1) begin
            flag <= 2;
            data_interface_call_begin <= 0;
        end

        if (flag == 2 && data_interface_return_ready) begin
            flag <= 0;
            data_interface_enable <= 0;
            write_enable <= 0;
            read_size <= 0;
            write_size <= 0;
            tmp_size <= 0;
            tmp_zero_extend <= 0;
            data_interface_raddr <= 0;
            data_interface_waddr <= 0;
            data_interface_wdata <= 0;
        end
    end
end

endmodule