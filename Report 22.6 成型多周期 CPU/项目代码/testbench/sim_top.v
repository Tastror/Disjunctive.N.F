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
        // instruction 1: addi t7 zero 0xaf4
        inst_ram_write_data <= 32'h200F0AF4;
        inst_ram_write_address <= PC_INITIAL;
    end
    
    else if (count == 2) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        // instruction 2: addi t8 zero 0x8
        inst_ram_write_data <= 32'h20180008;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end

    else if (count == 3) begin
        debug <= 1;
        cpu_reset <= 1;
        // instruction 3: add t7 t7 t8
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h01F87820;
        inst_ram_write_address <= inst_ram_write_address + 32'h10;
    end
  
    else if (count == 4) begin
        debug <= 1;
        cpu_reset <= 1;
        // instruction 4: sw t7 0x4(t8)
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'hAF0F0004;
        inst_ram_write_address <= inst_ram_write_address + 32'h10;
    end
    
    else if (count == 5) begin
        debug <= 1;
        cpu_reset <= 1;
        // instruction 5: lw t3 0x4(t8)
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h8F0B0004;
        inst_ram_write_address <= inst_ram_write_address + 32'h10;
    end
    
    else if (count == 6) begin
        debug <= 1;
        cpu_reset <= 1;
        // addi t7 t7 0x1
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 7) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 8) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 9) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 10) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 11) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 12) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 13) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 14) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 15) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 16) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h21290001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    
    else if (count == 95) begin
        debug <= 1;
        cpu_reset <= 1;
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
