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
    
    if (count == 1) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        // Ö¸Áî1£ºload
        inst_ram_write_data <= 32'h00000001;
        inst_ram_write_address <= PC_INITIAL;
    end
    else if (count == 2) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 3) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        // Ö¸Áî2£ºload
        inst_ram_write_data <= 32'h000F0130;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 4) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 5) begin
        debug <= 1;
        cpu_reset <= 1;
        // Ö¸Áî2£ºload
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00AB0130;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 6) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 7) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00001001;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 8) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 9) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h00010820;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 10) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 11) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 12) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 13) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 14) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 15) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 16) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 17) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 18) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 19) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 20) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 21) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 22) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 23) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 24) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 25) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 26) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 27) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 28) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
    end
    
    else if (count == 29) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 1;
        inst_ram_write_data <= 32'h05421004;
        inst_ram_write_address <= inst_ram_write_address + 32'h4;
    end
    else if (count == 30) begin
        debug <= 1;
        cpu_reset <= 1;
        inst_ram_write_enable <= 0;
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
