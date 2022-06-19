`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/04 21:45:01
// Design Name: 
// Module Name: sim_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module sim_top(input clk);

parameter PC_INITIAL = 32'hbfc00000;
reg [31:0] count = 0;
reg debug = 1;
reg cpu_reset = 1;
reg inst_ram_write_enable = 0;
reg [31:0] inst_ram_write_data = 0;
reg [31:0] inst_ram_write_address = PC_INITIAL;


always @ (posedge clk)  
begin  
    count <= count + 1;
    
    // t0 ~ t7 is 8 ~ 15, t8 is 24, t9 is 25
    // s0 ~ s7 16 ~ 23
    // sp is 29
    
    if (count == 0) begin
        debug <= 1;
        cpu_reset <= 0;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 1) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        // addi t7 zero 0xfaf4
        inst_ram_write_data <= 32'h200FFAF4;
        inst_ram_write_address <= PC_INITIAL;
    end
    
    else if (count == 2) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        // lui t8 0x123
        inst_ram_write_data <= 32'h3C180123;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 3) begin
        debug <= 1;
        cpu_reset <= 1;
        // add t7 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F87820;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
  
    else if (count == 4) begin
        debug <= 1;
        cpu_reset <= 1;
        // sub t7 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F87822;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 5) begin
        debug <= 1;
        cpu_reset <= 1;
        // slt s1 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F8882A;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 6) begin
        debug <= 1;
        cpu_reset <= 1;
        // sltu s2 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F8902B;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 7) begin
        debug <= 1;
        cpu_reset <= 1;
        // div t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F8001A;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 8) begin
        debug <= 1;
        cpu_reset <= 1;
        // mfhi s3
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00009810;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 9) begin
        debug <= 1;
        cpu_reset <= 1;
        // mtlo s3
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h02600013;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 10) begin
        debug <= 1;
        cpu_reset <= 1;
        // mult t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F80018;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 11) begin
        debug <= 1;
        cpu_reset <= 1;
        // mflo s4
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h0000A012;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 12) begin
        debug <= 1;
        cpu_reset <= 1;
        // mthi s4
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h02800011;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 13) begin
        debug <= 1;
        cpu_reset <= 1;
        // and t2 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F85024;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 14) begin
        debug <= 1;
        cpu_reset <= 1;
        // or t3 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F85825;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 15) begin
        debug <= 1;
        cpu_reset <= 1;
        // nor t4 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F86027;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 16) begin
        debug <= 1;
        cpu_reset <= 1;
        // xor t5 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F86826;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 17) begin
        debug <= 1;
        cpu_reset <= 1;
        // sll s5 t7 0x2
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h000FA880;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 18) begin
        debug <= 1;
        cpu_reset <= 1;
        // srl s5 t7 0x2
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h000FA882;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 19) begin
        debug <= 1;
        cpu_reset <= 1;
        // sra s5 t7 0x2
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h000FA883;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 20) begin
        debug <= 1;
        cpu_reset <= 1;
        // sw t7 0x4(t8)
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'hAF0F0004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 21) begin
        debug <= 1;
        cpu_reset <= 1;
        // lw t3 0x4(t8)
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h8F0B0004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 22) begin
        debug <= 1;
        cpu_reset <= 1;
        // addi t1 t1 0x1
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 23) begin
        debug <= 1;
        cpu_reset <= 1;
        // addi t1 t1 0x1
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 24) begin
        debug <= 1;
        cpu_reset <= 1;
        // jal 0x1f (31, inst No.32)
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h0C00001F;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 25) begin
        debug <= 1;
        cpu_reset <= 1;
        // nop
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 26) begin
        debug <= 1;
        cpu_reset <= 1;
        // lui t4 0x100
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h3C0C0100;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 27) begin
        debug <= 1;
        cpu_reset <= 1;
        // blez t4 0x10
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h19800010;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 28) begin
        debug <= 1;
        cpu_reset <= 1;
        // nop
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 29) begin
        debug <= 1;
        cpu_reset <= 1;
        // bgez t4 0x10
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05810010;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 30) begin
        debug <= 1;
        cpu_reset <= 1;
        // nop
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 31) begin
        debug <= 1;
        cpu_reset <= 1;
        // j 0x2f
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h0800002F;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 32) begin
        debug <= 1;
        cpu_reset <= 1;
        // nop
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 33) begin
        debug <= 1;
        cpu_reset <= 1;
        // add t1 t2 t3
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h014B4820;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 34) begin
        debug <= 1;
        cpu_reset <= 1;
        // jr ra
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h03E00008;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 35) begin
        debug <= 1;
        cpu_reset <= 1;
        // nop
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 36) begin
        debug <= 1;
        cpu_reset <= 1;
        // nop
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count < 100)
    begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
        inst_ram_write_data <= 32'h00000000;
    end  
    else if (count >= 100)
    begin
        debug <= 0;
        cpu_reset <= 0;
        inst_ram_write_enable <= 0;
        inst_ram_write_data <= 32'h00000000;
        inst_ram_write_address = PC_INITIAL;
        count <= count;
    end  
end  

CPU CPU1(
    .debug(debug),
    .inst_ram_write_enable(inst_ram_write_enable), .inst_ram_write_data(inst_ram_write_data), .inst_ram_write_address(inst_ram_write_address),
    .reset(cpu_reset), .clk(clk)
);

endmodule
