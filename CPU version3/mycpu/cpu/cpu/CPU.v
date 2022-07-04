`timescale 1ns / 1ps



//////////////////////////////////////////////////////////////////////////////////
// Company: Disjunctive.N.F
// Engineer: Tastror
// 
// Create Date: 2022/05/03 21:43:40
// Design Name: 
// Module Name: CPU
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



// ! important !
//
// [name rule]
//     environment (begin with little case):
//         clk, reset, debug, io_show, ...
//     normal (begin with capital):
//         IF_xxx, ID_xxx, EX_xxx, ME_xxx, WB_xxx
//
// [input and output rule]
//     normal:
//         module_name(
//             // input
//             .x1(_x1), ,x2(_x2),
//             // output
//             .x3(_x3), ,x4(_x4)
//         );
//     for reg wait:
//         module_name(
//             .clk(clk), .en(1), .rst(0 or reset)
//             // in-out pair
//             .i1(_x1), .o1(_y1),
//             .i2(_x2), .o2(_y2)
//         );
//
// ! important !



module CPU(

    // face to AXI

    // basic
    input wire ACLK,
    input wire ARESTn,

    // write address
    output wire [3:0] AWID,
    output wire [31:0] AWADDR,
    output wire [7:0] AWLEN,
    output wire [2:0] AWSIZE,
    output wire [1:0] AWBURST,
    output wire [1:0] AWLOCK,
    output wire [3:0] AWCACHE,
    output wire [2:0] AWPROT,
    // output wire [31:0] AWQOS,
    // output wire [31:0] AWREGION,
    // output wire [31:0] AWUSER,
    output wire AWVALID,
    output wire AWREADY,

    // write data
    output wire [3:0] WID,
    output wire [31:0] WDATA,
    output wire [3:0] WSTRB,
    output wire WLAST,
    // output wire [31:0] WUSER,
    output wire WVALID,
    input wire WREADY,  // slave

    // write response
    input wire [3:0] BID,  // slave
    input wire [1:0] BRESP,  // slave
    // input wire [31:0] BUSER,  // slave
    input wire BVALID,  // slave
    output wire BREADY,

    // read address
    output wire [3:0] ARID,
    output wire [31:0] ARADDR,
    output wire [7:0] ARLEN,
    output wire [2:0] ARSIZE,
    output wire [1:0] ARBURST,
    output wire [1:0] ARLOCK,
    output wire [3:0] ARCACHE,
    output wire [2:0] ARPROT,
    // output wire [31:0] ARQOS,
    // output wire [31:0] ARREGION,
    // output wire [31:0] ARUSER,
    output wire ARVALID,
    input wire ARREADY,  // slave

    // read response
    input wire [3:0] RID,  // slave
    input wire [31:0] RDATA,  // slave
    input wire [1:0] RRESP,  // slave
    input wire RLAST,  // slave
    // input wire [31:0] RUSER,  // slave
    input wire RVALID,  // slave
    output wire RREADY,

    // // outher
    // input wire [31:0] CSYSREQ,
    // input wire [31:0] CSYSACK,
    // input wire [31:0] CACTIVE,

    // debug trace
    output reg [31:0] debug_wb_pc,
    output reg [3:0] debug_wb_rf_wen,
    output reg [4:0] debug_wb_rf_wnum,
    output reg [31:0] debug_wb_rf_wdata
);



// global
wire clk;
assign clk = ACLK;
wire reset;
assign reset = ~ARESTn;


wire [3:0] I_ARID, D_ARID;
wire [31:0] I_ARADDR, D_ARADDR;
wire [7:0] I_ARLEN, D_ARLEN;
wire [2:0] I_ARSIZE, D_ARSIZE;
wire [1:0] I_ARBURST, D_ARBURST;
wire [1:0] I_ARLOCK, D_ARLOCK;
wire [3:0] I_ARCACHE, D_ARCACHE;
wire [2:0] I_ARPROT, D_ARPROT;
wire I_ARVALID, D_ARVALID;
wire I_RREADY, D_RREADY;


// IF
wire [31:0] IF_pc;
wire [31:0] IF_pc_after_mmu;
wire [31:0] IF_pc_plus_4;
wire [31:0] IF_cache_instruction, IF_instruction;
wire IF_pc_instruction_ready;
wire IF_cache_call_begin;
wire IF_dont_use_next;
wire IF_cache_return_ready;
wire IF_inst_interface_call_begin;
wire IF_inst_interface_return_ready;
wire [31:0] IF_inst_interface_addr;
wire [31:0] IF_inst_interface_rdata;



// ID
    // pc
wire [31:0] ID_pc;
wire [31:0] ID_pc_plus_4;
    // self used things
wire [31:0] ID_instruction;
wire [15:0] ID_imm;  // imm and offset are the same
wire [31:0] ID_imm_32, ID_sa_32;  // ID_imm & ID_sa with sign
wire [5:0] ID_opcode;
wire [5:0] ID_funct;
wire [4:0] ID_rt;
wire [4:0] ID_rs;
wire [4:0] ID_rd;
wire [4:0] ID_sa;  // sa and base are the same
wire [25:0] ID_index;
wire [15:0] ID_code;
wire [2:0] ID_sel;
    // things that will transport to next place
wire [1:0] ID_ctl_pc_first_mux;
wire [4:0] ID_ctl_pc_second_mux; // MUX5_32b, [first, index, rs_data, break, recover]
wire [31:0] ID_reg_rdata_rs, ID_reg_rdata_rt;
wire [31:0] ID_may_choke_rs_data;
wire [31:0] ID_high_rdata, ID_low_rdata;
wire [1:0] ID_ctl_rfAluSrc1_mux; // MUX2_32b, [rs_data, sa]
wire [2:0] ID_ctl_rfAluSrc2_mux; // MUX3_32b, [rt_data, imm_32, 0]
wire [13:0] ID_ctl_alu_mux;
wire ID_ctl_alu_op2;
wire [4:0] ID_ctl_alures_merge_mux; // MUX5_32b, [alu_res, PC+8, HI_rdata, LO_rdata, CP0_data]
wire ID_ctl_dataRam_en;
wire ID_ctl_dataRam_wen;
wire ID_ctl_rf_wen;
wire ID_ctl_low_wen;
wire ID_ctl_high_wen;
wire [1:0] ID_ctl_rfWriteData_mux; // MUX2_32b, [alures_merge, ramdata]
wire [2:0] ID_ctl_rfWriteAddr_mux; // MUX3_5b, [rd, rt, 31]
wire [1:0] ID_ctl_low_mux;  // MUX2_32b, [alu_res, rs_data]
wire [1:0] ID_ctl_high_mux;  // MUX2_32b, [alu_res_high, rs_data]
wire ID_ctl_imm_zero_extend;
wire IFID_ready_rs, IFID_ready_rt, IFID_ready_jr, IFID_ready_chosen;
wire IFID_ready_all;
wire IDEXE_delete_rs, IDEXE_delete_rt, IDEXE_delete_jr, IDEXE_delete_chosen;
wire IDEXE_delete_all;
wire ID_ctl_jr_choke, ID_ctl_chosen_choke;
wire [2:0] ID_ctl_data_size;
wire ID_ctl_data_zero_extend;
wire ID_ctl_eret, ID_ctl_cp0_read, ID_ctl_cp0_write;
wire ID_ctl_exception;
wire [4:0] ID_ctl_cp0_exception_code;

// cp0 of ID
wire [18:0] ID_VPN2;
wire [7:0] ID_ASID;
wire [19:0] ID_PFN0;
wire [19:0] ID_PFN1;
wire [2:0] ID_C0;
wire [2:0] ID_C1;
wire ID_D0;
wire ID_D1;
wire ID_V0;
wire ID_V1;
wire ID_G0;
wire ID_G1;
wire [30:0] ID_Index;


// EX
    // pc
wire [31:0] EX_pc;
wire [31:0] EX_pc_plus_4;
wire [31:0] EX_pc_plus_8;
wire [31:0] EX_pc_plus_4_plus_4imm;
    // self used things
wire [25:0] EX_index;
wire [2:0] EX_sel;
wire [31:0] EX_imm_32, EX_sa_32;
wire [4:0] EX_rs, EX_rt, EX_rd, EX_sa;
wire [31:0] EX_rs_data_old, EX_rt_data_old;
wire [31:0] EX_rs_data, EX_rt_data;
wire [31:0] EX_high_rdata_old, EX_low_rdata_old;
wire [31:0] EX_high_rdata, EX_low_rdata;
wire [1:0] EX_ctl_rfAluSrc1_mux; // MUX2_32b, [rs_data, sa]
wire [31:0] EX_alu_src1;
wire [2:0] EX_ctl_rfAluSrc2_mux; // MUX3_32b, [rt_data, imm_32, 0]
wire [31:0] EX_alu_src2;
wire [13:0] EX_ctl_alu_mux;
wire EX_ctl_alu_op2;
wire [31:0] EX_alu_res, EX_alu_res_high;
wire EX_alu_zero;
wire [4:0] EX_ctl_alures_merge_mux; // MUX5_32b, [alu_res, PC+8, HI_rdata, LO_rdata, CP0_data]
wire [31:0] EX_alures_merge;
wire [2:0] EX_ctl_rfWriteAddr_mux; // MUX3_5b, [rd, rt, 31]
wire [4:0] EX_reg_waddr;
wire [1:0] EX_ctl_low_mux;  // MUX2_32b, [alu_res, rs_data]
wire [31:0] EX_low_wdata;
wire [1:0] EX_ctl_high_mux;  // MUX2_32b, [alu_res_high, rs_data]
wire [31:0] EX_high_wdata;
wire [1:0] EX_ctl_pc_first_mux_old;
wire [1:0] EX_ctl_pc_first_mux;
wire EX_ctl_dataRam_en;
wire EX_ctl_dataRam_wen;
    // things that will transport to next place
wire EX_ctl_rf_wen;
wire EX_ctl_low_wen;
wire EX_ctl_high_wen;
wire [1:0] EX_ctl_rfWriteData_mux; // MUX2_32b, [alures_merge, ramdata]
wire [2:0] EX_ctl_data_size;
wire EX_ctl_data_zero_extend;
wire EX_ctl_eret;
wire EX_ctl_cp0_read;
wire EX_ctl_cp0_write;
wire EX_ctl_exception;
wire [31:0] EX_CP0_rdata;
wire EX_T1;
wire [31:0] EX_recover_pc;
wire [4:0] EX_ctl_cp0_exception_code;



// ME
    // pc
wire [31:0] ME_pc;
wire [31:0] ME_pc_plus_4;
wire [31:0] ME_pc_plus_4_plus_4imm;
    // self used things
wire [25:0] ME_index;
wire [31:0] ME_alu_res, ME_alu_res_high;
wire [31:0] ME_rs_data, ME_rt_data;
wire ME_alu_zero;
wire ME_ctl_dataRam_en;
wire ME_ctl_dataRam_wen;
wire [31:0] ME_dram_waddr;
wire [31:0] ME_dram_waddr_after_mmu;
wire [31:0] ME_dram_wdata;
wire [31:0] ME_dataram_rdata;
wire ME_data_cache_return_ready;
wire ME_data_interface_enable;
wire ME_write_enable;
wire [2:0] ME_read_size;
wire [2:0] ME_write_size;
wire [31:0] ME_data_interface_raddr;
wire [31:0] ME_data_interface_waddr;
wire [31:0] ME_data_interface_wdata;
wire ME_data_interface_call_begin;
wire ME_data_interface_return_ready;
wire [31:0] ME_data_interface_rdata;
    // things that will transport to next place
wire [31:0] ME_alures_merge;
wire ME_ctl_rf_wen;
wire ME_ctl_low_wen;
wire ME_ctl_high_wen;
wire [1:0] ME_ctl_rfWriteData_mux; // MUX2_32b, [alures_merge, ramdata]
wire [4:0] ME_reg_waddr;
wire [31:0] ME_low_wdata, ME_high_wdata;
wire ME_mem_return_ready;
wire ME_mem_lw_return_ready;
wire [2:0] ME_ctl_data_size;
wire ME_ctl_data_zero_extend;



// WB
    // pc
wire [31:0] WB_pc;
    // self used things
wire [1:0] WB_ctl_rfWriteData_mux; // MUX2_32b, [alures_merge, ramdata]
wire [31:0] WB_alures_merge;
wire [31:0] WB_dataram_rdata;
wire [31:0] WB_reg_wdata;
    // things that will transport to next place
wire WB_ctl_rf_wen;
wire [4:0] WB_reg_waddr;
wire WB_ctl_low_wen;
wire WB_ctl_high_wen;
wire [31:0] WB_low_wdata;
wire [31:0] WB_high_wdata;





/***** debug *****/

always @ (posedge clk) begin
    if (WB_ctl_rf_wen) begin
        debug_wb_pc <= WB_pc;
        debug_wb_rf_wen <= 4'b1;
        debug_wb_rf_wnum <= WB_reg_waddr;
        debug_wb_rf_wdata <= WB_reg_wdata;
    end
    else begin
        debug_wb_pc <= 32'b0;
        debug_wb_rf_wen <= 4'b0;
        debug_wb_rf_wnum <= 5'b0;
        debug_wb_rf_wdata <= 32'b0;
    end
end





// /***** mmu top *****/
// mmu_top mmu_top_0(/*autoport*/
//     // input
//     .rst_n(ARESTn), .clk(clk),
//     .data_address_i(ME_dram_waddr),
//     .inst_address_i(IF_pc),
//     .data_en(ME_ctl_dataRam_wen),
//     .inst_en(1),
//     .inst_mmu_begin(),
//     .data_mmu_begin(),
//     .user_mode(0),
//     .tlb_config(0),
//     .tlbwi(0),
//     .tlbp(0),
//     .asid(ID_ASID),
//     .cp0_kseg0_uncached(0),
//     // output
//     .data_address_o(ME_dram_waddr_after_mmu),
//     .inst_address_o(IF_pc_after_mmu),
//     .inst_mmu_end(),
//     .data_mmu_end()
//     // ,
//     // .data_uncached(),
//     // .inst_uncached(),
//     // .data_exp_miss(),
//     // .inst_exp_miss(),
//     // .data_exp_illegal(),
//     // .inst_exp_illegal(),
//     // .data_exp_dirty(),
//     // .data_exp_invalid(),
//     // .inst_exp_invalid(),
//     // .tlbp_result()
// );




/***** Welcome to IF *****/

pc_if_reg pc_if_reg_0(
    // global input
    .clk(clk), .reset(reset), .enable(1),
    // input
    .pc_call_begin(1),
    .pc_next_update_begin(IFID_ready_chosen),
    .EX_ctl_pc_first_mux(EX_ctl_pc_first_mux), .ID_ctl_pc_second_mux(ID_ctl_pc_second_mux),
    .EX_pc_plus_4_plus_4imm(EX_pc_plus_4_plus_4imm), .ID_index(ID_index), .ID_may_choke_rs_data(ID_may_choke_rs_data),
    .pc_recover(EX_recover_pc),
    // output
    .IF_pc_out(IF_pc), .IF_pc_plus_4(IF_pc_plus_4),
    .pc_instruction_ready(IF_pc_instruction_ready),
    .return_instruction(IF_instruction),
    // output (face to cache)
    .cache_call_begin(IF_cache_call_begin),
    .dont_use_next(IF_dont_use_next),
    // input (face to cache)
    .cache_return_ready(IF_cache_return_ready),
    .cache_return_instruction(IF_cache_instruction),
    // input (face to mem)
    .mem_return_ready(ME_mem_return_ready),
    .ex_lw_may_choke(~EX_ctl_dataRam_wen & EX_ctl_dataRam_en),
    .mem_lw_return_ready(ME_mem_lw_return_ready)
);

inst_cache inst_cache_0(
    // global input
    .clk(clk), .reset(reset), .enable(1),
    // input (face to CPU)
    .cache_call_begin(IF_cache_call_begin),
    .dont_use_next(IF_dont_use_next),
    // .pc(IF_pc_after_mmu),
    .pc(IF_pc),
    // output (face to CPU)
    .cache_return_ready(IF_cache_return_ready),
    .cache_return_instruction(IF_cache_instruction),
    // output (face to interface)
    .inst_interface_call_begin(IF_inst_interface_call_begin),
    .inst_interface_addr(IF_inst_interface_addr),
    // input (face to interface)
    .inst_interface_return_ready(IF_inst_interface_return_ready),
    .inst_interface_rdata(IF_inst_interface_rdata)
);

inst_ram_interface inst_ram_interface_0(
    // global input
    .clk(clk), .reset(reset), .enable(1),
    // input data (face to CACHE)
    .inst_interface_call_begin(IF_inst_interface_call_begin),
    .inst_interface_addr(IF_inst_interface_addr),
    // output data (face to CACHE)
    .inst_interface_return_ready(IF_inst_interface_return_ready),
    .inst_interface_rdata(IF_inst_interface_rdata),
    // read address (face to AXI)
    .ARID(I_ARID), .ARADDR(I_ARADDR),
    .ARLEN(I_ARLEN), .ARSIZE(I_ARSIZE),
    .ARBURST(I_ARBURST), .ARLOCK(I_ARLOCK),
    .ARCACHE(I_ARCACHE), .ARPROT(I_ARPROT),
    .ARVALID(I_ARVALID), .ARREADY(ARREADY),
    // read response (face to AXI)
    .RID(RID), .RDATA(RDATA),
    .RRESP(RRESP), .RLAST(RLAST),
    .RVALID(RVALID), .RREADY(I_RREADY)
);





WaitRegs IF_ID_wait(
    .clk(clk), .reset(reset), .enable(1),
    .delete(0),
    .begin_save(IF_pc_instruction_ready),
    .addi_save(0),
    .end_save(IFID_ready_all & IF_pc_instruction_ready),
    .ready_go(1),
    // in-out pair
    .i321(IF_instruction), .o321(ID_instruction),
    .i322(IF_pc_plus_4), .o322(ID_pc_plus_4),
    .i323(IF_pc), .o323(ID_pc)
);





/***** Welcome to ID *****/

id_data id_data_0(
    // input
    .instruction(ID_instruction),
    // output
    .opcode(ID_opcode), .funct(ID_funct), .rs(ID_rs), .rt(ID_rt), .rd(ID_rd),
    .sa(ID_sa), .imm(ID_imm), .instIndex(ID_index), .code(ID_code), .sel(ID_sel)
);

wire [15:0] ID_imm_real_pre;
assign ID_imm_real_pre =
    {16{ID_ctl_imm_zero_extend}} & 16'h0 |
    ~{16{ID_ctl_imm_zero_extend}} & {16{ID_imm[15]}};
assign ID_imm_32 = {ID_imm_real_pre, ID_imm};  // signed or unsigend
assign ID_sa_32 = {{27{1'b0}}, ID_sa};  // no sign

id_control id_control_0(
    // input
    .opcode(ID_opcode), .rs(ID_rs), .rt(ID_rt), .rd(ID_rd), .sa(ID_sa), .funct(ID_funct),
    // output
    .ctl_pc_first_mux(ID_ctl_pc_first_mux), .ctl_pc_second_mux(ID_ctl_pc_second_mux),
    .ctl_aluSrc1_mux(ID_ctl_rfAluSrc1_mux), .ctl_aluSrc2_mux(ID_ctl_rfAluSrc2_mux),
    .ctl_alu_mux(ID_ctl_alu_mux), .ctl_alu_op2(ID_ctl_alu_op2),
    .ctl_alures_merge_mux(ID_ctl_alures_merge_mux),
    .ctl_dataRam_en(ID_ctl_dataRam_en), .ctl_dataRam_wen(ID_ctl_dataRam_wen),
    .ctl_rfWriteData_mux(ID_ctl_rfWriteData_mux), .ctl_rfWriteAddr_mux(ID_ctl_rfWriteAddr_mux), .ctl_rf_wen(ID_ctl_rf_wen),
    .ctl_low_wen(ID_ctl_low_wen), .ctl_high_wen(ID_ctl_high_wen), .ctl_low_mux(ID_ctl_low_mux), .ctl_high_mux(ID_ctl_high_mux),
    .ctl_imm_zero_extend(ID_ctl_imm_zero_extend),
    .ctl_jr_choke(ID_ctl_jr_choke), .ctl_chosen_choke(ID_ctl_chosen_choke),
    .ctl_data_size(ID_ctl_data_size), .ctl_data_zero_extend(ID_ctl_data_zero_extend),
    .ctl_eret(ID_ctl_eret), .ctl_cp0_read(ID_ctl_cp0_read), .ctl_cp0_write(ID_ctl_cp0_write),
    .ctl_exception(ID_ctl_exception),
    .ctl_cp0_exception_code(ID_ctl_cp0_exception_code)
);

regs regs_0(
    // input
    .clk(clk), .rst(reset),
    .we(WB_ctl_rf_wen), .waddr(WB_reg_waddr), .wdata(WB_reg_wdata),
    .raddr1(ID_rs), .raddr2(ID_rt),
    // output
    .rdata1(ID_reg_rdata_rs), .rdata2(ID_reg_rdata_rt)
);

low_high_reg low_high_reg_0(
    //input
    .clk(clk), .rst(reset),
    .low_we(WB_ctl_low_wen), .high_we(WB_ctl_high_wen),
    .low_wdata(WB_low_wdata), .high_wdata(WB_high_wdata),
    //output
    .low_rdata(ID_low_rdata), .high_rdata(ID_high_rdata)
);

choke choke_rs(
    // input
    .I_am_reading_reg(ID_ctl_rfAluSrc1_mux[0]),
    .he_is_reading_ram(EX_ctl_dataRam_en),
    .used_addr(ID_rs),
    .EX_addr(EX_reg_waddr),
    // output
    .IFID_ready(IFID_ready_rs),
    .IDEXE_delete(IDEXE_delete_rs)
);

choke choke_rt(
    // input
    .I_am_reading_reg(ID_ctl_rfAluSrc2_mux[0]),
    .he_is_reading_ram(EX_ctl_dataRam_en),
    .used_addr(ID_rt),
    .EX_addr(EX_reg_waddr),
    // output
    .IFID_ready(IFID_ready_rt),
    .IDEXE_delete(IDEXE_delete_rt)
);

choke_jr choke_jr(
    // input
    .I_am_reading(ID_ctl_jr_choke),
    .used_addr(ID_rs),
    .EX_addr(EX_reg_waddr),
    .ME_addr(ME_reg_waddr),
    // output
    .IFID_ready(IFID_ready_jr),
    .IDEXE_delete(IDEXE_delete_jr)
);

choke_chosen choke_chosen(
    // input
    .chosen_return_ready(1),
    .chosen_choke(ID_ctl_chosen_choke),
    // output
    .IFID_ready(IFID_ready_chosen),
    .IDEXE_delete(IDEXE_delete_chosen)
);

assign IFID_ready_all = IFID_ready_rs & IFID_ready_rt & IFID_ready_jr & IFID_ready_chosen;
assign IDEXE_delete_all = IDEXE_delete_rs | IDEXE_delete_rt | IDEXE_delete_jr;
assign ID_may_choke_rs_data =
    ID_reg_rdata_rs & {32{IFID_ready_jr}} | EX_rs_data & {32{~IFID_ready_jr}};





WaitRegs ID_EXE_wait(
    .clk(clk), .reset(reset), .enable(1),
    .delete(IDEXE_delete_all),
    .begin_save(1),
    .addi_save(0),
    .end_save(1),
    .ready_go(1),
    // in-out pair
    .i1(ID_ctl_dataRam_en), .o1(EX_ctl_dataRam_en),
    .i2(ID_ctl_dataRam_wen), .o2(EX_ctl_dataRam_wen),
    .i3(ID_ctl_rf_wen), .o3(EX_ctl_rf_wen),
    .i4(ID_ctl_alu_op2), .o4(EX_ctl_alu_op2),
    .i6(ID_ctl_low_wen), .o6(EX_ctl_low_wen),
    .i7(ID_ctl_high_wen), .o7(EX_ctl_high_wen),
    .i8(ID_ctl_data_zero_extend), .o8(EX_ctl_data_zero_extend),
    .i21(ID_ctl_low_mux), .o21(EX_ctl_low_mux),
    .i22(ID_ctl_high_mux), .o22(EX_ctl_high_mux),
    .i31(ID_ctl_data_size), .o31(EX_ctl_data_size),
    .i51(ID_ctl_rfAluSrc1_mux), .o51(EX_ctl_rfAluSrc1_mux),
    .i52(ID_ctl_rfAluSrc2_mux), .o52(EX_ctl_rfAluSrc2_mux),
    .i61(ID_ctl_rfWriteData_mux), .o61(EX_ctl_rfWriteData_mux),
    .i62(ID_ctl_rfWriteAddr_mux), .o62(EX_ctl_rfWriteAddr_mux),
    .i81(ID_rt), .o81(EX_rt),
    .i82(ID_rd), .o82(EX_rd),
    .i83(ID_rs), .o83(EX_rs),
    .i84(ID_sa), .o84(EX_sa),
    .i161(ID_ctl_pc_first_mux), .o161(EX_ctl_pc_first_mux_old),
    .i162(ID_ctl_alures_merge_mux), .o162(EX_ctl_alures_merge_mux),
    .i321(ID_pc_plus_4), .o321(EX_pc_plus_4),
    .i322(ID_reg_rdata_rs), .o322(EX_rs_data_old),
    .i323(ID_reg_rdata_rt), .o323(EX_rt_data_old),
    .i324(ID_imm_32), .o324(EX_imm_32),
    .i325(ID_sa_32), .o325(EX_sa_32),
    .i326(ID_ctl_alu_mux), .o326(EX_ctl_alu_mux),
    .i327(ID_index), .o327(EX_index),
    .i328(ID_low_rdata), .o328(EX_low_rdata_old),
    .i329(ID_high_rdata), .o329(EX_high_rdata_old),
    .i32a(ID_pc), .o32a(EX_pc),
    .i32b({ID_ctl_exception, ID_ctl_cp0_exception_code, ID_sel, ID_ctl_eret, ID_ctl_cp0_read, ID_ctl_cp0_write}),
    .o32b({EX_ctl_exception, EX_ctl_cp0_exception_code, EX_sel, EX_ctl_eret, EX_ctl_cp0_read, EX_ctl_cp0_write})
);





/***** Welcome to EXE *****/

pc_ex pc_ex_0(
    // input
    .pc_in_ex(EX_pc_plus_4), .imm_32_in_ex(EX_imm_32),
    // output
    .pc_to_mem(EX_pc_plus_4_plus_4imm)
);

bypass bypass_rs(
    // input
    .used_addr(EX_rs), .ME_reg_waddr(ME_reg_waddr), .WB_reg_waddr(WB_reg_waddr),
    .old_data(EX_rs_data_old), .ME_alures_merge(ME_alures_merge), .WB_reg_wdata(WB_reg_wdata),
    // output
    .changed_data(EX_rs_data)
);

bypass bypass_rt(
    // input
    .used_addr(EX_rt), .ME_reg_waddr(ME_reg_waddr), .WB_reg_waddr(WB_reg_waddr),
    .old_data(EX_rt_data_old), .ME_alures_merge(ME_alures_merge), .WB_reg_wdata(WB_reg_wdata),
    // output
    .changed_data(EX_rt_data)
);

bypass_low_high bypass_low(
    // input
    .ME_wen(ME_ctl_low_wen), .WB_wen(WB_ctl_low_wen),
    .old_data(EX_low_rdata_old), .ME_data(ME_low_wdata), .WB_data(WB_low_wdata),
    // output
    .new_data(EX_low_rdata)
);

bypass_low_high bypass_high(
    // input
    .ME_wen(ME_ctl_high_wen), .WB_wen(WB_ctl_high_wen),
    .old_data(EX_high_rdata_old), .ME_data(ME_high_wdata), .WB_data(WB_high_wdata),
    // output
    .new_data(EX_high_rdata)
);

MUX2_32b MUX2_32b_alusrc1( .oneHot(EX_ctl_rfAluSrc1_mux),
    .in0(EX_rs_data), .in1(EX_sa_32), .out(EX_alu_src1) );

MUX3_32b MUX3_32b_alusrc2( .oneHot(EX_ctl_rfAluSrc2_mux),
    .in0(EX_rt_data), .in1(EX_imm_32), .in2(32'h0), .out(EX_alu_src2) );

ALU ALU_0(
    // input
    .alu_control(EX_ctl_alu_mux), .alu_op2(EX_ctl_alu_op2),
    .alu_src1(EX_alu_src1), .alu_src2(EX_alu_src2),
    // output
    .alu_result(EX_alu_res), .alu_result_high(EX_alu_res_high), .alu_zero(EX_alu_zero)
);

assign EX_pc_plus_8 = EX_pc_plus_4 + 32'd4;

// this is usually written in write-back, but considered the bypass, we lift it here
MUX3_5b MUX3_5b_ex_waddr( .oneHot(EX_ctl_rfWriteAddr_mux),
    .in0(EX_rd), .in1(EX_rt), .in2(5'd31), .out(EX_reg_waddr) );

MUX2_32b MUX2_32b_low( .oneHot(EX_ctl_low_mux),
    .in0(EX_alu_res), .in1(EX_rs_data), .out(EX_low_wdata) );

MUX2_32b MUX2_32b_high( .oneHot(EX_ctl_high_mux),
    .in0(EX_alu_res_high), .in1(EX_rs_data), .out(EX_high_wdata) );

assign EX_ctl_pc_first_mux[0] = ~EX_alu_res[0] | EX_ctl_pc_first_mux_old[0];
assign EX_ctl_pc_first_mux[1] = EX_alu_res[0] & EX_ctl_pc_first_mux_old[1];

cp0 cp0_reg_0(
    // input
    .clk(clk), .rst(reset), .enable(1),
    // input (face to normal CPU)
    .pc(EX_pc),
    .eret(EX_ctl_eret),
    .read(EX_ctl_cp0_read),
    .write(EX_ctl_cp0_write),
    .exception(EX_ctl_exception),
    .sel(EX_sel),
    .rd(EX_rd),
    .rt_data(EX_rt_data),
    .cp0_exception_code(EX_ctl_cp0_exception_code),
    // input (face to TLB)
    .wen(4'h0),
    .EntryHi_wdata(32'h0),
    .EntryLo0_wdata(32'h0),
    .EntryLo1_wdata(32'h0),
    .IndexReg_wdata(32'h0),
    // output
    .CP0_rdata(EX_CP0_rdata),
    .T1(EX_T1),
    .recover_pc(EX_recover_pc),
    .VPN2(VPN2),
    .ASID(ASID),
    .PFN0(PFN0),
    .PFN1(PFN1),
    .C0(C0),
    .C1(C1),
    .D0(D0),
    .D1(D1),
    .V0(V0),
    .V1(V1),
    .G0(G0),
    .G1(G1),
    .Index(Index)
);

MUX5_32b MUX5_32b_alures_merge(.oneHot(EX_ctl_alures_merge_mux),
    .in0(EX_alu_res), .in1(EX_pc_plus_8), .in2(EX_high_rdata), .in3(EX_low_rdata), .in4(EX_CP0_rdata), .out(EX_alures_merge) );





WaitRegs EXE_MEM_wait(
    .clk(clk), .reset(reset), .enable(1),
    .delete(0),
    .begin_save(1),
    .addi_save(0),
    .end_save(1),
    .ready_go(1),
    // in-out pair
    .i1(EX_ctl_dataRam_en), .o1(ME_ctl_dataRam_en),
    .i2(EX_ctl_dataRam_wen), .o2(ME_ctl_dataRam_wen),
    .i3(EX_ctl_rf_wen), .o3(ME_ctl_rf_wen),
    .i5(EX_alu_zero), .o5(ME_alu_zero),
    .i6(EX_ctl_low_wen), .o6(ME_ctl_low_wen),
    .i7(EX_ctl_high_wen), .o7(ME_ctl_high_wen),
    .i8(EX_ctl_data_zero_extend), .o8(ME_ctl_data_zero_extend),
    .i31(EX_ctl_data_size), .o31(ME_ctl_data_size),
    .i61(EX_ctl_rfWriteData_mux), .o61(ME_ctl_rfWriteData_mux),
    .i81(EX_reg_waddr), .o81(ME_reg_waddr),
    .i321(EX_pc_plus_4_plus_4imm), .o321(ME_pc_plus_4_plus_4imm),
    .i322(EX_pc_plus_4), .o322(ME_pc_plus_4),
    .i323(EX_alu_res), .o323(ME_alu_res),
    .i324(EX_alu_res_high), .o324(ME_alu_res_high),
    .i325(EX_rt_data), .o325(ME_rt_data),
    .i326(EX_rs_data), .o326(ME_rs_data),
    .i327(EX_index), .o327(ME_index),
    .i328(EX_low_wdata), .o328(ME_low_wdata),
    .i329(EX_high_wdata), .o329(ME_high_wdata),
    .i32a(EX_alures_merge), .o32a(ME_alures_merge),
    .i32b(EX_pc), .o32b(ME_pc)
);





/***** Welcome to MEM *****/

assign ME_dram_waddr = ME_alu_res;
assign ME_dataram_raddr = ME_alu_res;
assign ME_dram_wdata = ME_rt_data;

data_cache data_cache_0(
    // global input
    .clk(clk), .reset(reset), .enable(ME_ctl_dataRam_en),

    // input (face to CPU)
    .wen(ME_ctl_dataRam_wen),
    .size(ME_ctl_data_size),
    .addr(ME_dram_waddr),
    // .addr(ME_dram_waddr_after_mmu),
    .data(ME_dram_wdata),
    .cache_call_begin(ME_ctl_dataRam_en),
    .zero_extend(ME_ctl_data_zero_extend),
    
    // output (face to CPU)
    .cache_return_ready(ME_data_cache_return_ready),
    .cache_return_rdata(ME_dataram_rdata),

    // output data (face to interface)
    .data_interface_enable(ME_data_interface_enable),
    .write_enable(ME_write_enable),
    .read_size(ME_read_size),
    .write_size(ME_write_size),
    .data_interface_raddr(ME_data_interface_raddr),
    .data_interface_waddr(ME_data_interface_waddr),
    .data_interface_wdata(ME_data_interface_wdata),
    .data_interface_call_begin(ME_data_interface_call_begin),

    // input data (face to interface)
    .data_interface_return_ready(ME_data_interface_return_ready),
    .data_interface_rdata(ME_data_interface_rdata)
);

data_ram_interface data_ram_interface_0(
    // global input
    .clk(clk), .reset(reset), .enable(ME_data_interface_enable),

    // input data (face to CACHE)
    .write_enable(ME_write_enable),
    .read_size(ME_read_size),
    .write_size(ME_write_size),
    .data_interface_raddr(ME_data_interface_raddr),
    .data_interface_waddr(ME_data_interface_waddr),
    .data_interface_wdata(ME_data_interface_wdata),
    .data_interface_call_begin(ME_data_interface_call_begin),

    // output data (face to CACHE)
    .data_interface_return_ready(ME_data_interface_return_ready),
    .data_interface_rdata(ME_data_interface_rdata),

    // read address (face to AXI)
    .ARID(D_ARID),
    .ARADDR(D_ARADDR),
    .ARLEN(D_ARLEN),
    .ARSIZE(D_ARSIZE),
    .ARBURST(D_ARBURST),
    .ARLOCK(D_ARLOCK),
    .ARCACHE(D_ARCACHE),
    .ARPROT(D_ARPROT),
    .ARVALID(D_ARVALID),
    .ARREADY(ARREADY),

    // read response (face to AXI)
    .RID(RID),
    .RDATA(RDATA),
    .RRESP(RRESP),
    .RLAST(RLAST),
    .RVALID(RVALID),
    .RREADY(D_RREADY),

    // write address (face to AXI)
    .AWID(AWID),
    .AWADDR(AWADDR),
    .AWLEN(AWLEN),
    .AWSIZE(AWSIZE),
    .AWBURST(AWBURST),
    .AWLOCK(AWLOCK),
    .AWCACHE(AWCACHE),
    .AWPROT(AWPROT),
    .AWVALID(AWVALID),
    .AWREADY(AWREADY),

    // write data (face to AXI)
    .WID(WID),
    .WDATA(WDATA),
    .WSTRB(WSTRB),
    .WLAST(WLAST),
    .WVALID(WVALID),
    .WREADY(WREADY),

    // write response (face to AXI)
    .BID(BID),
    .BRESP(BRESP),
    .BVALID(BVALID),
    .BREADY(BREADY)
);

assign ARID = I_ARID | D_ARID;
assign ARADDR = I_ARADDR | D_ARADDR;
assign ARLEN = I_ARLEN | D_ARLEN;
assign ARSIZE = I_ARSIZE | D_ARSIZE;
assign ARBURST = I_ARBURST | D_ARBURST;
assign ARLOCK = I_ARLOCK | D_ARLOCK;
assign ARCACHE = I_ARCACHE | D_ARCACHE;
assign ARPROT = I_ARPROT | D_ARPROT;
assign ARVALID = I_ARVALID | D_ARVALID;
assign RREADY = I_RREADY | D_RREADY;

// data_RAM data_RAM_0(
//     // in
//     .clk(clk), .en(ME_ctl_dataRam_en), .we(ME_ctl_dataRam_wen),
//     .data_address(ME_dram_waddr), .data(ME_dram_wdata),
//     // out
//     .res(ME_dataram_rdata)
// );

wire MEWB_begin_save, MEWB_save, MEWB_ready_go, MEWB_lw;
reg MEWB_last_begin_save, MEWB_last_save, MEWB_last_ready_go;

always @ (posedge clk) begin
    if (reset) begin
        MEWB_last_begin_save <= 1;
        MEWB_last_save <= 1;
        MEWB_last_ready_go <= 1;
    end
    else begin
        MEWB_last_begin_save <= MEWB_begin_save;
        MEWB_last_save <= MEWB_save;
        MEWB_last_ready_go <= MEWB_ready_go;
    end
end
assign MEWB_lw = ME_data_interface_enable & ~ME_write_enable;
assign MEWB_begin_save = 1'b1;
assign MEWB_save = (ME_ctl_dataRam_en | ~MEWB_last_save) ? ME_data_interface_return_ready : 1'b1;
assign MEWB_ready_go = (ME_ctl_dataRam_en | ~MEWB_last_ready_go) ? ME_data_interface_return_ready : 1'b1;
assign ME_mem_return_ready = MEWB_begin_save & MEWB_save & MEWB_ready_go;
assign ME_mem_lw_return_ready = ME_mem_return_ready & MEWB_lw;

WaitRegs MEM_WB_wait(
    .clk(clk), .reset(reset), .enable(1),
    .delete(0),
    .begin_save(MEWB_last_save),
    .addi_save(MEWB_lw ? ME_mem_lw_return_ready : MEWB_save),
    .end_save(MEWB_lw ? ME_mem_lw_return_ready : MEWB_ready_go),
    .ready_go(1),
    // in-out pair
    .i3(ME_ctl_rf_wen), .o3(WB_ctl_rf_wen),
    .i4(ME_ctl_low_wen), .o4(WB_ctl_low_wen),
    .i5(ME_ctl_high_wen), .o5(WB_ctl_high_wen),
    .i61(ME_ctl_rfWriteData_mux), .o61(WB_ctl_rfWriteData_mux),
    .i81(ME_reg_waddr), .o81(WB_reg_waddr),
    .i323(ME_alures_merge), .o323(WB_alures_merge),
    .i324(ME_low_wdata), .o324(WB_low_wdata),
    .i325(ME_high_wdata), .o325(WB_high_wdata),
    .i326(ME_pc), .o326(WB_pc),
    // in-out pair: addi_save
    .ai321(ME_dataram_rdata), .ao321(WB_dataram_rdata)
);





/***** Welcome to WB *****/

// rfInData: MUX2_32b, [alures_merge, ramdata]
MUX2_32b MUX2_32b_wb_wdata( .oneHot(WB_ctl_rfWriteData_mux),
    .in0(WB_alures_merge), .in1(WB_dataram_rdata), .out(WB_reg_wdata) );





endmodule
