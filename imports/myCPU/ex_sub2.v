`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/09 20:51:23
// Design Name: 
// Module Name: ex_sub2
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


// ��Ҫ������ʱ��ex_sub2������룬���ֻ��ִ�������߼��ȼ�ָ��
module ex_sub2(

	input wire rst,
	
	// �͵�ִ�н׶ε���Ϣ
	input wire [`AluOpBus] aluop_i,
	input wire [`AluSelBus] alusel_i,
	input wire [`RegBus] reg1_i,
	input wire [`RegBus] reg2_i,
	input wire [`RegAddrBus] wd_i,
	input wire wreg_i,
	input wire [31:0] excepttype_i,
	
	input [`RegBus] hi_i,
	input [`RegBus] lo_i,

	// ִ�еĽ��
	output reg [`RegAddrBus] wd_o,
	output reg wreg_o,
	output reg [`RegBus] wdata_o,
	
	// ����ִ�н׶ε�ָ���HI��LO�Ĵ�����д��������
	output reg [`RegBus] hi_o,
	output reg [`RegBus] lo_o,
	output reg whilo_o,	
	
	output wire [31:0] excepttype_o
);

	reg [`RegBus] logicout;  // �����߼�������
	reg [`RegBus] shiftres;  // ������λ������
	reg [`RegBus] moveres;  // �����ƶ��������
	reg [`RegBus] arithmeticres;  // ��������������
	
	// ���������йصı���
	wire ov_sum;  // ����������
	wire [`RegBus] reg2_i_mux;  // ��������ĵڶ���������reg2_i�Ĳ���
	wire [`RegBus] result_sum;  // ����ӷ����
	
//	// �˷������йصı���
//    wire [`RegBus] opdata1_mult;  // �˷������еı�����
//    wire [`RegBus] opdata2_mult;  // �˷������еĳ���
//    wire [`DoubleRegBus] hilo_temp;  // ��ʱ����˷���������Ϊ64λ
//    reg [`DoubleRegBus] mulres;  // ����˷���������Ϊ64λ
    
    reg ovassert;
    	
    assign excepttype_o = {excepttype_i[31:13], ovassert, excepttype_i[11:0]};
    
// ���������ֵ
	// ����Ǽ������з��űȽ����㣬��ôreg2_i_mux����
    // �ڶ���������reg2_i�Ĳ��룬����reg2_i_mux�͵��ڵڶ���������reg2_i
	assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || 
                        (aluop_i == `EXE_SUBU_OP) ||
                        (aluop_i == `EXE_SLT_OP)) ?
                        (~reg2_i)+1 : reg2_i;
    
    assign result_sum = reg1_i + reg2_i_mux;                                         
    
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
                    ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));

// ��һ�Σ�����aluop_iָʾ�����������ͽ��м���	
    // �����߼�����
    always @ (*) begin
        if(rst == `RstEnable)
            logicout = `ZeroWord;
        else begin
			case (aluop_i)
                `EXE_OR_OP:     logicout = reg1_i | reg2_i;
                `EXE_AND_OP:    logicout = reg1_i & reg2_i;
                `EXE_NOR_OP:    logicout = ~(reg1_i |reg2_i);
                `EXE_XOR_OP:    logicout = reg1_i ^ reg2_i;
				default:        logicout = `ZeroWord;
			endcase
		end  //if
	end  //always
    
    // ������λ����
    always @ (*) begin
        if(rst == `RstEnable)
            shiftres = `ZeroWord;
        else begin
            case (aluop_i)
                `EXE_SLL_OP:    shiftres = reg2_i << reg1_i[4:0] ;
                `EXE_SRL_OP:    shiftres = reg2_i >> reg1_i[4:0];
                `EXE_SRA_OP:    shiftres = ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) 
                                            | reg2_i >> reg1_i[4:0];
                default:        shiftres = `ZeroWord;
            endcase
        end  //if
    end  //always
    
    // �����ƶ�����
    always @ (*) begin
        if (rst == `RstEnable) 
            moveres = `ZeroWord;
        else begin
            case (aluop_i)
                `EXE_MFHI_OP:   moveres = hi_i;
                `EXE_MFLO_OP:   moveres = lo_i;
                `EXE_MOVZ_OP:   moveres = reg1_i;
                `EXE_MOVN_OP:   moveres = reg1_i;
                default:        moveres = `ZeroWord;
            endcase
        end
    end
    
    // ������������
    always @ (*) begin
        if(rst == `RstEnable)
            arithmeticres = `ZeroWord;
        else begin
            case (aluop_i)
                `EXE_ADD_OP,`EXE_ADDU_OP,`EXE_ADDI_OP,`EXE_ADDIU_OP,`EXE_SUB_OP, `EXE_SUBU_OP:
                    arithmeticres = result_sum; 
                `EXE_SLT_OP:
                    arithmeticres = (reg1_i[31] & ~reg2_i[31]) ?
                                    1'b1 : (~reg1_i[31] & reg2_i[31]) ?
                                    1'b0 : result_sum[31];
                `EXE_SLTU_OP:   
                    arithmeticres = reg1_i < reg2_i;
                `EXE_CLZ_OP:        begin
                    arithmeticres = reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
                                     reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
                                     reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 : 
                                     reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
                                     reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 : 
                                     reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 : 
                                     reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
                                     reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 : 
                                     reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 : 
                                     reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 : 
                                     reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
                end
                `EXE_CLO_OP:        begin
                    arithmeticres = ~reg1_i[31] ? 0 : ~reg1_i[30] ? 1 : ~reg1_i[29] ? 2 :
                                    ~reg1_i[28] ? 3 : ~reg1_i[27] ? 4 : ~reg1_i[26] ? 5 :
                                    ~reg1_i[25] ? 6 : ~reg1_i[24] ? 7 : ~reg1_i[23] ? 8 : 
                                    ~reg1_i[22] ? 9 : ~reg1_i[21] ? 10 : ~reg1_i[20] ? 11 :
                                    ~reg1_i[19] ? 12 : ~reg1_i[18] ? 13 : ~reg1_i[17] ? 14 : 
                                    ~reg1_i[16] ? 15 : ~reg1_i[15] ? 16 : ~reg1_i[14] ? 17 : 
                                    ~reg1_i[13] ? 18 : ~reg1_i[12] ? 19 : ~reg1_i[11] ? 20 :
                                    ~reg1_i[10] ? 21 : ~reg1_i[9] ? 22 : ~reg1_i[8] ? 23 : 
                                    ~reg1_i[7] ? 24 : ~reg1_i[6] ? 25 : ~reg1_i[5] ? 26 : 
                                    ~reg1_i[4] ? 27 : ~reg1_i[3] ? 28 : ~reg1_i[2] ? 29 : 
                                    ~reg1_i[1] ? 30 : ~reg1_i[0] ? 31 : 32 ;
                end
                default:
                    arithmeticres = `ZeroWord;
            endcase
        end
    end
    
//    // ���г˷�����
//    //ȡ�ó˷������Ĳ�������������з��ų����Ҳ������Ǹ�������ôȡ����һ
//    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
//                            && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;   
//    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP))
//                            && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;
//    //�õ���ʱ�˷�����������ڱ���hilo_temp��
//    assign hilo_temp = opdata1_mult * opdata2_mult;
//    //����ʱ�˷�����������������յĳ˷���������ڱ���mulres��
//	always @ (*) begin
//        if(rst == `RstEnable)
//            mulres = {`ZeroWord,`ZeroWord};
//        else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP))
//            mulres = (reg1_i[31] ^ reg2_i[31]) ? ~hilo_temp + 1 : hilo_temp;
//        else
//            mulres = hilo_temp;
//    end
    
// �ڶ��Σ�����alusel_iָʾ���������ͣ�ѡ��һ����������Ϊ���ս��
    always @ (*) begin
        wd_o = wd_i;	 	 	
        wreg_o = wreg_i;
        ovassert = 1'b0;
        case (alusel_i) 
            `EXE_RES_LOGIC:     wdata_o = logicout;
            `EXE_RES_SHIFT:     wdata_o = shiftres;
//            `EXE_RES_MUL:		wdata_o = mulres[31:0];
            `EXE_RES_ARITHMETIC: begin
                wdata_o = arithmeticres;
                if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) 
                    || (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
                    wreg_o = `WriteDisable;
                    ovassert = 1'b1;
                end else begin
                    wreg_o = wreg_i;
                    ovassert = 1'b0;
                end
            end
            `EXE_RES_MOVE:      begin
                wdata_o = moveres;
                // MOVZ��MOVN���������ƶ�ָ����Ҫ����һ�������ж�
                case (aluop_i)
                    `EXE_MOVZ_OP:   wreg_o = (reg2_i != 0) ? `WriteDisable : `WriteEnable;
                    `EXE_MOVN_OP:   wreg_o = (reg2_i == 0) ? `WriteDisable : `WriteEnable;
                    default:        ;
                endcase  // case aluop_i
            end
            default:            wdata_o = `ZeroWord;
        endcase  // case alusel_i
    end	

// �����Σ������MTHI��MTLO��MULT��MULTUָ���ô��Ҫ����whilo_o��hi_o��lo_o��ֵ
    always @ (*) begin
		if(rst == `RstEnable) begin
			whilo_o = `WriteDisable;
			hi_o = `ZeroWord;
			lo_o = `ZeroWord;
//        end else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
//            whilo_o = `WriteEnable;
//            hi_o = mulres[63:32];
//            lo_o = mulres[31:0];
		end else if(aluop_i == `EXE_MTHI_OP) begin
			whilo_o = `WriteEnable;
			hi_o = reg1_i;
			lo_o = lo_i;
		end else if(aluop_i == `EXE_MTLO_OP) begin
			whilo_o = `WriteEnable;
			hi_o = hi_i;
			lo_o = reg1_i;
		end else begin
			whilo_o = `WriteDisable;
			hi_o = `ZeroWord;
			lo_o = `ZeroWord;
		end				
	end
	
endmodule
