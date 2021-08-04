`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/09 22:51:24
// Design Name: 
// Module Name: id
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
module id(
    input wire clk,
    input wire rst,
    input wire stallreq_from_ex,
    input wire stallreq_from_dcache,
    
    input wire issue_en1,
	input wire [`InstAddrBus] inst_addr_i1,  // ����׶ε�ָ���Ӧ�ĵ�ַ
	input wire [`InstAddrBus] inst_addr_i2,
	input wire [`InstBus] inst_i1,  // ����׶ε�ָ��
    input wire [`InstBus] inst_i2,
    input wire [`BPBPacketWidth] predict_pkt,
    input wire pre_inst_is_bly,
    input wire ex_branch_flag,
    
    // ��ȡ��regfile��ֵ
//	input wire [`RegBus] reg1_data_i1,  // ��regfile����ĵ�һ�����˿ڵ����
//	input wire [`RegBus] reg2_data_i1,
//    input wire [`RegBus] reg1_data_i2,
//    input wire [`RegBus] reg2_data_i2,
    
	//�͵�regfile����Ϣ
	output wire reg1_read_o1,  // regfile�ĵ�һ�����˿ڵĶ�ʹ���ź�
	output wire reg2_read_o1,
	output wire reg1_read_o2,
	output wire reg2_read_o2,
	     
	output wire [`RegAddrBus] reg1_addr_o1,  // regfile�ĵ�һ�����˿ڵĶ���ַ�ź�
	output wire [`RegAddrBus] reg2_addr_o1,
	output wire [`RegAddrBus] reg1_addr_o2,
	output wire [`RegAddrBus] reg2_addr_o2, 	      
	
	// �͵�ִ�н׶ε���Ϣ
    output reg [`BPBPacketWidth] predict_pkt_o,
    output reg [2:0] cp0_sel_o,
    output reg [`RegAddrBus] cp0_addr_o,
    output reg is_bly1,  // �Ƿ���branch_likelyָ��
    
	// ��һ��ָ�����Ϣ
    output reg [`RegBus] imm_o1,
	output reg [`AluOpBus] aluop_o1,
	output reg [`AluSelBus] alusel_o1,
//	output reg [`RegBus] reg1_o1,  // Դ������1
//	output reg [`RegBus] reg2_o1,
	output reg [`RegAddrBus] wd_o1,  // Ҫд���Ŀ�ļĴ����ĵ�ַ
	output reg wreg_o1,  // �Ƿ���Ҫд���Ŀ�ļĴ���
	output reg [`InstAddrBus] inst_addr_o1,
	output reg [31:0] excepttype_o1,
	
	// �ڶ���ָ�����Ϣ
	output wire [`RegBus] imm_o2,
	output reg [`AluOpBus] aluop_o2,
    output reg [`AluSelBus] alusel_o2,
//    output reg [`RegBus] reg1_o2,
//    output reg [`RegBus] reg2_o2,
    output reg [`RegAddrBus] wd_o2,
    output reg wreg_o2,
    output reg [`InstAddrBus] inst_addr_o2,
    output reg [31:0] excepttype_o2,
    
// ��������������
    // ����ִ�н׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
//    input wire ex_we_i1,
//    input wire [`RegBus] ex_wdata_i1,
    input wire [`RegAddrBus] ex_waddr_i1,
//    input wire ex_we_i2,
//    input wire [`RegBus] ex_wdata_i2,
    input wire [`RegAddrBus] ex_waddr_i2,
        
    // ���ڷô�׶ε�ָ��Ҫд���Ŀ�ļĴ�����Ϣ
//    input wire mem_we_i1,
//    input wire [`RegBus] mem_wdata_i1,
//    input wire [`RegAddrBus] mem_waddr_i1,
//    input wire mem_we_i2,
//    input wire [`RegBus] mem_wdata_i2,
//    input wire [`RegAddrBus] mem_waddr_i2,
    
    // �ô�ָ������������������
    input wire [`AluOpBus] ex_aluop_i1,
    
    // ת��ָ������
    input wire is_in_delayslot_i,  // ָ��1�Ƿ����ӳٲ�ָ��
    output reg is_in_delayslot_o1,  // ָ��1�Ƿ����ӳٲ�ָ��
    output reg is_in_delayslot_o2,  // ָ��2�Ƿ����ӳٲ�ָ��
    output wire next_inst_in_delayslot,  // ��һ��ָ��1�Ƿ����ӳٲ�ָ��
    
    // ����ģʽ����
    output reg issue_mode,
    output reg issue_o,
    
    output reg stallreq_from_id
    );
    
    // ��ʱ�洢��һ��ָ�����Ϣ
    wire [`AluOpBus] aluop_o1_temp;
    wire [`AluSelBus] alusel_o1_temp;
//    wire [`RegBus] reg1_o1_temp;
//    wire [`RegBus] reg2_o1_temp;
    wire [`RegAddrBus] wd_o1_temp;
    wire wreg_o1_temp;
    wire [31:0] excepttype_o1_temp;
	wire [`RegBus] imm_temp;
    wire [2:0] cp0_sel_o_temp;
    wire [`RegAddrBus] cp0_addr_o_temp;
    
    // ��ʱ�洢�ڶ���ָ�����Ϣ
    wire [`AluOpBus] aluop_o2_temp;
    wire [`AluSelBus] alusel_o2_temp;
//    wire [`RegBus] reg1_o2_temp;
//    wire [`RegBus] reg2_o2_temp;
    wire [`RegAddrBus] wd_o2_temp;
    wire wreg_o2_temp;
    wire [31:0] excepttype_o2_temp;
    
    // �洢���������Ӳ�����hi��lo�Ĵ����Ķ�д��Ϣ
    wire hi_re1, hi_we1, lo_re1, lo_we1;
    wire hi_re2, hi_we2, lo_re2, lo_we2;
    
    // ָ����Ϣ
    wire is_md1, is_md2;  // �Ƿ��ǳ˳���ָ��
    wire is_jb1;
    wire is_jb2;  // �Ƿ���ת��ָ��
    wire is_ls1, is_ls2;  // �Ƿ��Ƿô�ָ��
    wire is_cp01, is_cp02;  // �Ƿ�����Ȩָ��
    wire is_bly1_temp;  // ָ��1�Ƿ���branch_likelyָ��
    wire pre_inst_is_load;  // ��һ��ָ���Ƿ��Ǽ���ָ��
    
    // ���������Ӳ���֮���Ƿ�����������
    reg reg3_raw;
    reg reg4_raw;
    reg hilo_raw;
    wire load_dependency;
    wire reg12_load_dependency;
    wire reg34_load_dependency;
//    wire mem_dependency;
//    wire reg12_mem_dependency;
//    wire reg34_mem_dependency;
   
    // ���ָ��1��ת��ָ���ҵ����䣬����һ��ָ��1���ӳٲ�ָ��
    assign next_inst_in_delayslot = (is_jb1 == 1'b1 && issue_mode == `SingleIssue) ? 
                                    `InDelaySlot : `NotInDelaySlot;
                                    
    assign pre_inst_is_load = ((ex_aluop_i1 == `EXE_LB_OP) | 
                                (ex_aluop_i1 == `EXE_LBU_OP)|
                                (ex_aluop_i1 == `EXE_LH_OP) |
                                (ex_aluop_i1 == `EXE_LHU_OP)|
                                (ex_aluop_i1 == `EXE_LW_OP) |
                                (ex_aluop_i1 == `EXE_LWR_OP)|
                                (ex_aluop_i1 == `EXE_LWL_OP)|
                                (ex_aluop_i1 == `EXE_LL_OP) |
                                (ex_aluop_i1 == `EXE_SC_OP));

    assign load_dependency = (reg12_load_dependency == `LoadDependent || 
                              reg34_load_dependency == `LoadDependent) ? 
                              `LoadDependent : `LoadIndependent;
//    assign mem_dependency = reg12_mem_dependency | reg34_mem_dependency;
    
    id_sub id_sub1(
        .clk(clk),
        .rst(rst),
        .inst_addr_i(inst_addr_i1),
        .inst_i(inst_i1),
//        .reg1_data_i(reg1_data_i1),
//        .reg2_data_i(reg2_data_i1),
        // �͵�regfile����Ϣ
        .reg1_read_o(reg1_read_o1),
        .reg2_read_o(reg2_read_o1),       
        .reg1_addr_o(reg1_addr_o1),
        .reg2_addr_o(reg2_addr_o1),       
        // �͵�ID/EXģ�����Ϣ
        .aluop_o(aluop_o1_temp),
        .alusel_o(alusel_o1_temp),
//        .reg1_o(reg1_o1_temp),
//        .reg2_o(reg2_o1_temp),
        .wd_o(wd_o1_temp),
        .wreg_o(wreg_o1_temp),
        .imm(imm_temp),
        .cp0_sel_o(cp0_sel_o_temp),
        .cp0_addr_o(cp0_addr_o_temp),
        .excepttype_o(excepttype_o1_temp),
        // ��hi��lo�Ĵ����Ķ�д��Ϣ
        .hi_re(hi_re1),
        .lo_re(lo_re1),
        .hi_we(hi_we1),
        .lo_we(lo_we1),
        // ָ����Ϣ
        .is_jb(is_jb1),
        .is_ls(is_ls1),
        .is_cp0(is_cp01),
        .is_md(is_md1),
        .is_bly(is_bly1_temp),
        .pre_inst_is_load(pre_inst_is_load),
        // ��������������
        .ex_waddr_i1(ex_waddr_i1),
        .ex_waddr_i2(ex_waddr_i2),
//        .ex_we_i1(ex_we_i1),
//        .ex_we_i2(ex_we_i2),
//        .ex_wdata_i1(ex_wdata_i1),
//        .ex_wdata_i2(ex_wdata_i2),
//        .mem_waddr_i1(mem_waddr_i1),
//        .mem_waddr_i2(mem_waddr_i2),
//        .mem_we_i1(mem_we_i1),
//        .mem_we_i2(mem_we_i2),
//        .mem_wdata_i1(mem_wdata_i1),
//        .mem_wdata_i2(mem_wdata_i2),       
        .load_dependency(reg12_load_dependency)
//        .mem_dependency(reg12_mem_dependency)
    );
    
    id_sub id_sub2(
        .clk(clk),
        .rst(rst),
        .inst_addr_i(inst_addr_i2),
        .inst_i(inst_i2),
//        .reg1_data_i(reg1_data_i2),
//        .reg2_data_i(reg2_data_i2),
        //�͵�regfile����Ϣ
        .reg1_read_o(reg1_read_o2),
        .reg2_read_o(reg2_read_o2),       
        .reg1_addr_o(reg1_addr_o2),
        .reg2_addr_o(reg2_addr_o2),       
        //�͵�ID/EXģ�����Ϣ
        .aluop_o(aluop_o2_temp),
        .alusel_o(alusel_o2_temp),
//        .reg1_o(reg1_o2_temp),
//        .reg2_o(reg2_o2_temp),
        .wd_o(wd_o2_temp),
        .wreg_o(wreg_o2_temp),
        .imm(imm_o2),
        .cp0_sel_o(),
        .cp0_addr_o(),
        .excepttype_o(excepttype_o2_temp),
        // ��hi��lo�Ĵ����Ķ�д��Ϣ
        .hi_re(hi_re2),
        .lo_re(lo_re2),
        .hi_we(hi_we2),
        .lo_we(lo_we2),
        // ָ����Ϣ
        .is_jb(is_jb2),
        .is_ls(is_ls2),
        .is_cp0(is_cp02),
        .is_md(is_md2),
        .is_bly(),
        .pre_inst_is_load(pre_inst_is_load),
        // ��������������
        .ex_waddr_i1(ex_waddr_i1),
        .ex_waddr_i2(ex_waddr_i2),
//        .ex_we_i1(ex_we_i1),
//        .ex_we_i2(ex_we_i2),
//        .ex_wdata_i1(ex_wdata_i1),
//        .ex_wdata_i2(ex_wdata_i2),
//        .mem_waddr_i1(mem_waddr_i1),
//        .mem_waddr_i2(mem_waddr_i2),
//        .mem_we_i1(mem_we_i1),
//        .mem_we_i2(mem_we_i2),
//        .mem_wdata_i1(mem_wdata_i1),
//        .mem_wdata_i2(mem_wdata_i2),
        .load_dependency(reg34_load_dependency)
//        .mem_dependency(reg34_mem_dependency)
    );
    
// ��һ�Σ�RAW����Լ��
    always @ (*) begin
        if (rst == `RstEnable)
            reg3_raw = `RAWIndependent;  // ��λʱ����Ϊ��������� 
        // ָ��2�Ķ��˿�1�ɶ���ָ��1д��ĵ�ַΪָ��2��Դ�Ĵ���1ʱRAW���
        // ����д��ַ��Ϊ0�Ļ���λ
        else if (wd_o1 != `RegNumLog2'h0 && reg1_read_o2 == `ReadEnable 
                && wreg_o1 == `WriteEnable && wd_o1 == reg1_addr_o2) 
            reg3_raw = `RAWDependent;
        else 
            reg3_raw = `RAWIndependent;
    end
    
    always @ (*) begin
        if (rst == `RstEnable) 
            reg4_raw = `RAWIndependent;
        else if (wd_o1 != `RegNumLog2'h0 && reg2_read_o2 == `ReadEnable 
                && wreg_o1 == `WriteEnable && wd_o1 == reg2_addr_o2) 
            reg4_raw = `RAWDependent;
        else 
            reg4_raw = `RAWIndependent;
    end

    always @ (*) begin
        if (rst == `RstEnable)
            hilo_raw = `RAWIndependent;
        else if (hi_we1 == `WriteEnable && hi_re2 == `ReadEnable)
            // HI�Ĵ����������
            hilo_raw = `RAWDependent;
        else if (lo_we1 == `WriteEnable && lo_re2 == `ReadEnable)
            // LO�Ĵ����������
            hilo_raw = `RAWDependent;
        else
            hilo_raw = `RAWIndependent;
    end
    
// �ڶ��Σ���������ģʽ
    // �����仹��˫����
    always @ (*) begin
        if (rst == `RstEnable)
            issue_mode = `DualIssue;
        else if (is_md1 | is_md2 | is_jb2 | is_in_delayslot_i | is_ls1 | is_ls2 | is_cp01 | is_cp02)
            issue_mode = `SingleIssue;
        else if (reg3_raw == `RAWDependent || reg4_raw == `RAWDependent || hilo_raw == `RAWDependent) 
            issue_mode = `SingleIssue;
        else 
            issue_mode = `DualIssue;
    end
    
    // �Ƿ�������
    always @ (*) begin
        if (rst == `RstEnable || stallreq_from_ex == `Stop || stallreq_from_dcache == `Stop) begin
            issue_o = 1'b0;
            stallreq_from_id = `NoStop;
//        end else if (load_dependency == `LoadDependent || mem_dependency) begin
        end else if (load_dependency == `LoadDependent) begin
            issue_o = 1'b0;
            stallreq_from_id = `Stop;
        end else if (issue_en1 == 1'b1) begin
            issue_o = 1'b1;
            stallreq_from_id = `NoStop;
        end else begin
            issue_o = 1'b0;
            stallreq_from_id = `Stop;            
        end
    end
    
    // ָ��1������
    always @ (*) begin
        if (is_in_delayslot_i & pre_inst_is_bly & ~ex_branch_flag) begin
            // branch-likelyָ���ת�Ļ���ִ���ӳٲ�ָ��
            aluop_o1 = `EXE_NOP_OP;
            alusel_o1 = `EXE_RES_NOP;
//            reg1_o1 = `ZeroWord;
//            reg2_o1 = `ZeroWord;
            wd_o1 = `NOPRegAddr;
            wreg_o1 = `WriteDisable;
            inst_addr_o1 = `ZeroWord;
            excepttype_o1 = `ZeroWord;
            imm_o1 = `ZeroWord;
            predict_pkt_o = 35'b0;
            cp0_sel_o = 3'b0;
            cp0_addr_o = 5'b0;
            is_bly1 = 1'b0;
        end else begin
            // ������������������
            aluop_o1 = aluop_o1_temp;
            alusel_o1 = alusel_o1_temp;
//            reg1_o1 = reg1_o1_temp;
//            reg2_o1 = reg2_o1_temp;
            wd_o1 = wd_o1_temp;
            wreg_o1 = wreg_o1_temp;
            inst_addr_o1 = inst_addr_i1;
            excepttype_o1 = excepttype_o1_temp;
            imm_o1 = imm_temp;
            predict_pkt_o = predict_pkt;
            cp0_sel_o = cp0_sel_o_temp;
            cp0_addr_o = cp0_addr_o_temp;
            is_bly1 = is_bly1_temp;
        end
    end
    
    // ָ��2������
    always @ (*) begin
        if (issue_mode == `SingleIssue) begin
            // ������������ָ��2Ϊ��ָ��
            aluop_o2 = `EXE_NOP_OP;
            alusel_o2 = `EXE_RES_NOP;
//            reg1_o2 = `ZeroWord;
//            reg2_o2 = `ZeroWord;
            wd_o2 = `NOPRegAddr;
            wreg_o2 = `WriteDisable;
            inst_addr_o2 = `ZeroWord;
            excepttype_o2 = `ZeroWord;
        end else begin
            // ˫��������������������
            aluop_o2 = aluop_o2_temp;
            alusel_o2 = alusel_o2_temp;
//            reg1_o2 = reg1_o2_temp;
//            reg2_o2 = reg2_o2_temp;
            wd_o2 = wd_o2_temp;
            wreg_o2 = wreg_o2_temp;
            inst_addr_o2 = inst_addr_i2;
            excepttype_o2 = excepttype_o2_temp;
        end
    end
    
    // �ӳٲ�ָ������
    always @ (*) begin
        if (rst == `RstEnable) begin
            is_in_delayslot_o1 = `NotInDelaySlot;
            is_in_delayslot_o2 = `NotInDelaySlot;
        end else if (is_jb1 == 1'b1 && issue_mode == `DualIssue) begin
            // ���ָ��1��ת��ָ����˫���䣬��ָ��2���ӳٲ�ָ��
            is_in_delayslot_o1 = is_in_delayslot_i;
            is_in_delayslot_o2 = `InDelaySlot;
        end else begin
            is_in_delayslot_o1 = is_in_delayslot_i;
            is_in_delayslot_o2 = `NotInDelaySlot;
        end
    end
    
endmodule
