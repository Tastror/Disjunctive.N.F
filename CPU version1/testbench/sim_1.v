`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/04 21:45:01
// Design Name: 
// Module Name: sim_1
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


module sim_1();

reg [5:0] opcode;
reg [5:0] funct;
reg [5:0] rt;

wire [4:0] ctl_pcValue_mux;
    
wire ctl_instRam_en;
wire ctl_instRam_wen;
    
wire [2:0] ctl_aluSrc1_mux;
wire [3:0] ctl_aluSrc2_mux;
wire [8:0] ctl_alu_mux;

wire ctl_dataRam_en;
wire ctl_dataRam_wen;
    
wire [2:0] ctl_rfWriteData_mux;
wire [2:0] ctl_rfWriteAddr_mux;

wire ctl_rf_wen;

wire ctl_low_wen;
wire ctl_high_wen;
wire ctl_temp_wen;

CPU CPU1(
    .opcode(opcode), .funct(funct), .rt(rt),
    .ctl_pcValue_mux(ctl_pcValue_mux),
    .ctl_instRam_en(ctl_instRam_en), .ctl_instRam_wen(ctl_instRam_wen),
    .ctl_aluSrc1_mux(ctl_aluSrc1_mux), .ctl_aluSrc2_mux(ctl_aluSrc2_mux), .ctl_alu_mux(ctl_alu_mux),
    .ctl_dataRam_en(ctl_dataRam_en), .ctl_dataRam_wen(ctl_dataRam_wen),
    .ctl_rfWriteData_mux(ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ctl_rfWriteAddr_mux),
    .ctl_rf_wen(ctl_rf_wen),
    .ctl_low_wen(ctl_low_wen), .ctl_high_wen(ctl_high_wen), .ctl_temp_wen(ctl_temp_wen)
);

initial begin
$display("Hello");
opcode = 6'b0;
funct  = 6'b0;
rt     = 6'b0;
 
    begin
        repeat (64) begin
            # 20 funct = funct + 1;
        end
        
        opcode = opcode + 1;
        repeat (64) begin
            # 20 rt = rt + 1;
        end

        repeat (23) begin
            # 20 opcode = opcode + 1;
        end
        
        repeat (64) begin
            # 20 funct = funct + 1;
        end
        
        repeat (40) begin
            # 20 opcode = opcode + 1;
        end
    end
end

endmodule
