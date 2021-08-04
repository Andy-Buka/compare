`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/09 23:33:08
// Design Name: 
// Module Name: ex
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

`include "defines.v"
module ex(

	input wire rst,
	
	// �͵�ִ�н׶ε���Ϣ
	input wire [`RegBus] hi_i,
	input wire [`RegBus] lo_i,
	input wire [`RegBus] imm_i,  // ָ��1ִ������Ҫ��������
    input wire [`BPBPacketWidth] predict_pkt_i,
    input wire mem_exception_flag,
    input wire is_bly1,

	// ��һ��ָ�����Ϣ
	input wire [`AluOpBus] aluop_i1,
	input wire [`AluSelBus] alusel_i1,
	input wire [`RegBus] reg1_i1,
	input wire [`RegBus] reg2_i1,
	input wire [`RegAddrBus] wd_i1,
	input wire wreg_i1,
    input wire is_in_delayslot_i1,
    input wire [`InstAddrBus] inst_addr_i1,
    input wire [31:0] excepttype_i1,
    
	// �ڶ���ָ�����Ϣ
    input wire [`AluOpBus] aluop_i2,
    input wire [`AluSelBus] alusel_i2,
    input wire [`RegBus] reg1_i2,
    input wire [`RegBus] reg2_i2,
    input wire [`RegAddrBus] wd_i2,
    input wire wreg_i2,
    input wire is_in_delayslot_i2,
    input wire [`InstAddrBus] inst_addr_i2,
    input wire [31:0] excepttype_i2,
    
    // �����ģ���йصı���
    input wire [`DoubleRegBus] div_result_i,
    input wire div_ready_i,
    output wire [`RegBus] div_opdata1_o,
    output wire [`RegBus] div_opdata2_o,
    output wire div_start_o,
    output wire signed_div_o,

	// ִ�еĽ��
	output reg [`RegBus] hi_o,
	output reg [`RegBus] lo_o,
	output reg whilo_o,
	output wire LLbit_o,
	output wire LLbit_we_o,
	
	// ��һ��ָ�����Ϣ
	output wire [`RegAddrBus] wd_o1,
	output wire wreg_o1,
	output wire [`RegBus] wdata_o1,
	output wire [31:0] excepttype_o1,
	output wire is_in_delayslot_o1,	
	output wire [`InstAddrBus] inst_addr_o1,
	
	// �ڶ���ָ�����Ϣ
	output reg [`RegAddrBus] wd_o2,
    output reg wreg_o2,
    output reg [`RegBus] wdata_o2,	
    output reg [31:0] excepttype_o2,
    output reg is_in_delayslot_o2,
    output reg [`InstAddrBus] inst_addr_o2,
    
	// ת��ָ���йصı���
    output wire ex_branch_flag,
    output wire [`RegBus] ex_branch_target_addr,
    output wire predict_flag,  // Ԥ����ȷ���
    output wire [`BPBPacketWidth] corr_pkt,
    output wire predict_success,
    
    // �ô�ָ���йصı���
    output wire [`AluOpBus] aluop_o1,
    output wire [`RegBus] reg2_o1,
    output wire [`RegBus] mem_addr_o,
    output wire [`RegBus] dcache_addr_o,
    output wire mem_we_o,
    output wire [3:0] mem_sel_o,
    output wire [2:0] mem_arsize_o,
    output wire [`RegBus] mem_data_o,
    output wire mem_re_o,
    
    // CACHEָ���йصı���
    output wire [2:0] icache_op,
    output wire icache_creq,
    output wire [`RegBus] icache_caddr_o,
    output wire [`RegBus] icache_cdata_o,
    output wire [2:0] dcache_op,
    
    // ��Ȩָ���йصı���
    output wire cp0_we_o,
    output wire [`RegAddrBus] cp0_waddr_o,
    output wire [`RegBus] cp0_wdata_o,
    output wire [`RegAddrBus] cp0_raddr_o,
    output wire [2:0] cp0_wsel_o,
    output wire [2:0] cp0_rsel_o,
    
    // ���ۼӡ����ۼ�ָ���йصı���
    input wire [`DoubleRegBus] hilo_temp_i,
    input wire [1:0] cnt_i,
    output wire [`DoubleRegBus] hilo_temp_o,
    output wire [1:0] cnt_o,
    
// ��������������
    // LLbit
    input wire LLbit_i,  // LLbitģ�������ֵ
    input wire mem_LLbit_i,
    input wire mem_LLbit_we_i,
    input wire commit_LLbit_i,
    input wire commit_LLbit_we_i,
    // cp0
    input wire [2:0] cp0_sel_i,
    input wire [`RegAddrBus] cp0_addr_i,  // Ҫ��ȡ��cp0�мĴ����ĵ�ַ
    input wire [`RegBus] cp0_data_i,  // cp0ģ�������ֵ
    input wire [2:0] mem_cp0_wsel_i,
    input wire mem_cp0_we_i,
    input wire [`RegAddrBus] mem_cp0_waddr_i,
    input wire [2:0] commit_cp0_wsel_i,
    input wire commit_cp0_we_i,
    input wire [`RegAddrBus] commit_cp0_waddr_i,
    
    output wire stallreq_from_ex 
		
    );
    
    // �洢����ִ���Ӳ���hi��lo��whilo������ֵ
    wire[`RegBus] ex_sub_1_hi_o;
    wire[`RegBus] ex_sub_1_lo_o;
    wire ex_sub_1_whilo_o;
    reg [`RegBus] ex_sub_2_hi_o;
    reg [`RegBus] ex_sub_2_lo_o;
    reg ex_sub_2_whilo_o;
    reg LLbit;  // ����LLbit�Ĵ���������ֵ
    
    // ��ʱ�洢ָ��2��ִ�н��
    wire [`RegAddrBus] wd_o2_temp;
    wire wreg_o2_temp;
    wire [`RegBus] wdata_o2_temp;    
    wire [31:0] excepttype_o2_temp;
    wire [`RegBus] ex_sub_2_hi_o_temp;
    wire [`RegBus] ex_sub_2_lo_o_temp;
    wire ex_sub_2_whilo_o_temp;    
    
    // ��ȡLLbit�Ĵ���������ֵ
    always @ (*) begin
        if (rst == `RstEnable) LLbit = 1'b0;
        else if (mem_LLbit_we_i == `WriteEnable) LLbit = mem_LLbit_i;
        else if (commit_LLbit_we_i == `WriteEnable) LLbit = commit_LLbit_i;
        else LLbit = LLbit_i;
    end
    
    assign aluop_o1 = aluop_i1;
    assign reg2_o1 = reg2_i1;
    assign is_in_delayslot_o1 = is_in_delayslot_i1;
    assign inst_addr_o1 = inst_addr_i1;
    assign cp0_rsel_o = cp0_sel_i;
    assign cp0_wsel_o = cp0_sel_i;
    
    ex_sub1 ex_sub1_u(
        .rst(rst),
        .aluop_i(aluop_i1),
        .alusel_i(alusel_i1),
        .reg1_i(reg1_i1),
        .reg2_i(reg2_i1),
        .wd_i(wd_i1),
        .wreg_i(wreg_i1),
        .imm_i(imm_i),
        .inst_addr_i(inst_addr_i1),
        .predict_pkt_i(predict_pkt_i),
        .mem_exception_flag(mem_exception_flag),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .LLbit_i(LLbit),
        .wd_o(wd_o1),
        .wreg_o(wreg_o1),
        .wdata_o(wdata_o1),
        .hi_o(ex_sub_1_hi_o),
        .lo_o(ex_sub_1_lo_o),
        .whilo_o(ex_sub_1_whilo_o),
        .LLbit_o(LLbit_o),
        .LLbit_we_o(LLbit_we_o),
        // �����ģ���йصı���
        .div_result_i(div_result_i),
        .div_ready_i(div_ready_i),
        .div_opdata1_o(div_opdata1_o),
        .div_opdata2_o(div_opdata2_o),
        .div_start_o(div_start_o),
        .signed_div_o(signed_div_o),
        // ת��ָ���йصı���
        .ex_branch_flag(ex_branch_flag),
        .branch_target_addr(ex_branch_target_addr),
        .predict_flag(predict_flag),
        .corr_pkt(corr_pkt),
        .predict_success(predict_success),
        // CACHEָ���йصı���
        .icache_op(icache_op),
        .icache_creq(icache_creq),
        .icache_caddr_o(icache_caddr_o),
        .icache_cdata_o(icache_cdata_o),
        .dcache_op(dcache_op),
        // �ô�ָ���йصı���
        .mem_addr_o(mem_addr_o),
        .dcache_addr_o(dcache_addr_o),
        .mem_we_o(mem_we_o),
        .mem_sel_o(mem_sel_o),
        .mem_arsize_o(mem_arsize_o),
        .mem_data_o(mem_data_o),
        .mem_re_o(mem_re_o),
        // ��Ȩָ���йصı���
        .cp0_sel_i(cp0_sel_i),
        .cp0_addr_i(cp0_addr_i),
        .cp0_data_i(cp0_data_i),
        .cp0_we_o(cp0_we_o),
        .cp0_waddr_o(cp0_waddr_o),
        .cp0_wdata_o(cp0_wdata_o),
        .cp0_raddr_o(cp0_raddr_o),
        .mem_cp0_wsel_i(mem_cp0_wsel_i),
        .mem_cp0_we_i(mem_cp0_we_i),
        .mem_cp0_waddr_i(mem_cp0_waddr_i),
        .commit_cp0_wsel_i(commit_cp0_wsel_i),
        .commit_cp0_we_i(commit_cp0_we_i),
        .commit_cp0_waddr_i(commit_cp0_waddr_i),
        // ���ۼӡ����ۼ�ָ���йصı���
        .hilo_temp_i(hilo_temp_i),
        .cnt_i(cnt_i),
        .hilo_temp_o(hilo_temp_o),
        .cnt_o(cnt_o),
        
        .stallreq_from_ex(stallreq_from_ex),
        .excepttype_i(excepttype_i1),
        .excepttype_o(excepttype_o1)
    );
    
    ex_sub2 ex_sub2_u(
        .rst(rst),
        .aluop_i(aluop_i2),
        .alusel_i(alusel_i2),
        .reg1_i(reg1_i2),
        .reg2_i(reg2_i2),
        .wd_i(wd_i2),
        .wreg_i(wreg_i2),
        .hi_i(hi_i),
        .lo_i(lo_i),
        .wd_o(wd_o2_temp),
        .wreg_o(wreg_o2_temp),
        .wdata_o(wdata_o2_temp),
        .hi_o(ex_sub_2_hi_o_temp),
        .lo_o(ex_sub_2_lo_o_temp),
        .whilo_o(ex_sub_2_whilo_o_temp),
        .excepttype_i(excepttype_i2),
        .excepttype_o(excepttype_o2_temp)
    );
    
    always @ (*) begin
        if (is_in_delayslot_i2 & is_bly1 & ~ex_branch_flag) begin
        // branch-likelyָ���ת�Ļ���ִ���ӳٲ�ָ��
            wd_o2 = `NOPRegAddr;
            wreg_o2 = `WriteDisable;
            wdata_o2 = `ZeroWord;    
            excepttype_o2 = `ZeroWord;
            is_in_delayslot_o2 = 1'b0;
            inst_addr_o2 = `ZeroWord;
            ex_sub_2_hi_o = `ZeroWord;
            ex_sub_2_lo_o = `ZeroWord;
            ex_sub_2_whilo_o = `WriteDisable;
        end else begin
            wd_o2 = wd_o2_temp;
            wreg_o2 = wreg_o2_temp;
            wdata_o2 = wdata_o2_temp;
            excepttype_o2 = excepttype_o2_temp;
            is_in_delayslot_o2 = is_in_delayslot_i2;
            inst_addr_o2 = inst_addr_i2;
            ex_sub_2_hi_o = ex_sub_2_hi_o_temp;
            ex_sub_2_lo_o = ex_sub_2_lo_o_temp;
            ex_sub_2_whilo_o = ex_sub_2_whilo_o_temp;
        end
    end     
        
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end else if (mem_exception_flag | |excepttype_o1) begin  // �����쳣֮���ָ�������¼Ĵ���״̬
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end else if (|excepttype_o2) begin  // ����ڶ���ָ��ᵼ�����⣬���Ƿ����hilo�Ĵ���ȡ���ڵ�һ��ָ��
            whilo_o = ex_sub_1_whilo_o;
            hi_o = ex_sub_1_hi_o;
            lo_o = ex_sub_1_lo_o;            
        end else if (ex_sub_2_whilo_o == `WriteEnable) begin
            // ����ָ��2
            whilo_o = `WriteEnable;
            hi_o = ex_sub_2_hi_o;
            lo_o = ex_sub_2_lo_o;
        end else if (ex_sub_1_whilo_o == `WriteEnable) begin
            whilo_o = `WriteEnable;
            hi_o = ex_sub_1_hi_o;
            lo_o = ex_sub_1_lo_o;
        end else begin
            whilo_o = `WriteDisable;
            hi_o = `ZeroWord;
            lo_o = `ZeroWord;
        end
    end
endmodule
