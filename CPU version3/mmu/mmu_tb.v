`timescale 1ns/1ps



module mmu_tb();
    // output
    wire [31:0] data_address_o;
    wire [31:0] inst_address_o;
    wire data_uncached; //control signal
    wire inst_uncached; //no use
    wire data_exp_miss;
    wire inst_exp_miss;
    wire data_exp_illegal;
    wire inst_exp_illegal;
    wire data_exp_dirty;
    wire data_exp_invalid;
    wire inst_exp_invalid; 
    wire [31:0] tlbp_result; //search result
    
    // input
    reg rst_n;
    reg clk;
    reg [31:0] data_address_i;
    reg [31:0] inst_address_i;
    reg data_en;
    reg inst_en;
    reg user_mode; //no use
    reg [89:0] tlb_config; //cp0
    reg tlbwi; //control
    reg tlbp; //miss or not
    reg [7:0] asid; //cp0
    reg cp0_kseg0_uncached; //cp0
    
    parameter WITH_TLB = 1;
      
      initial begin
        clk = 0;
        rst_n = 1;
        #100 rst_n = 0;
      end
    
      initial begin
        data_address_i = 32'h0000_0000;
      end
    
    always #10 clk = ~clk;
    
    always #20 begin
        data_address_i = data_address_i + 32'd16;
    end

    mmu_top #(.WITH_TLB(WITH_TLB)) mmu(/*autoinst*/
      .data_address_o(data_address_o),
      .inst_address_o(),    
      .data_uncached(),
      .inst_uncached(),
      .data_exp_miss(),
      .inst_exp_miss(),
      .data_exp_illegal(),
      .inst_exp_illegal(),
      .data_exp_dirty(),
      .inst_exp_invalid(),
      .data_exp_invalid(),
      .rst_n(rst_n),
      .clk(clk),
      .data_address_i(data_address_i),
      .inst_address_i(),
      .data_en(1),
      .inst_en(1'b1),
      .tlb_config(80'b0),
      .tlbwi(),
      .tlbp(1),
      .tlbp_result(tlbp_result),
      .cp0_kseg0_uncached(),
      .asid(),
      .user_mode(1));
endmodule

/*
meaning:
mmu_top #(.WITH_TLB(WITH_TLB)) mmu(
      .data_address_o(dbus_address),
      .inst_address_o(if_iaddr_phy),
      .data_uncached(mm_dbus_uncached),
      .inst_uncached(),
      .data_exp_miss(mm_daddr_exp_miss),
      .inst_exp_miss(if_iaddr_exp_miss),
      .data_exp_illegal(mm_daddr_exp_illegal),
      .inst_exp_illegal(if_iaddr_exp_illegal),
      .data_exp_dirty(mm_daddr_dirty),
      .inst_exp_invalid(if_iaddr_exp_invalid),
      .data_exp_invalid(mm_daddr_exp_invalid),
      .rst_n(rst_n),
      .clk(clk),
      .data_address_i(mm_mem_address),
      .inst_address_i(if_pc),
      .data_en(mm_mem_rd | mm_mem_wr | mm_inv_wb_dcache | mm_inv_icache),
      .inst_en(1'b1),
      .tlb_config(cp0_tlb_config),
      .tlbwi(wb_we_tlb & ~wb_exception_detected),
      .tlbp(mm_probe_tlb),
      .tlbp_result(mm_probe_result),
      .cp0_kseg0_uncached(cp0_kseg0_uncached),
      .asid(cp0_asid),
      .user_mode(cp0_user_mode));
*/