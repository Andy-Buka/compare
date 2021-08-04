`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/09 21:27:17
// Design Name: 
// Module Name: mem
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


module mem(

	input wire rst,
	
	// ����ִ�н׶ε���Ϣ
    input wire LLbit_i,
    input wire LLbit_we_i,
    
    // �ô�ָ���йص���Ϣ
    input wire [`AluOpBus] aluop_i,
    input wire [`RegBus] mem_addr_i,
    input wire [`RegBus] reg2_i,
    input wire [`RegBus] mem_data_i,
    
    // ��Ȩָ���йص���Ϣ
    input wire [2:0] cp0_wsel_i,
    input wire cp0_we_i,
    input wire [4:0] cp0_waddr_i,
    input wire [`RegBus] cp0_wdata_i,
    
    // �쳣�йص���Ϣ
    input wire [`RegBus] cp0_status_i,
    input wire [`RegBus] cp0_cause_i,
    input wire [`RegBus] cp0_epc_i,
    input wire [`RegBus] cp0_ebase_i,
    input wire [2:0] commit_cp0_wsel_i,
    input wire commit_cp0_we_i,
    input wire [`RegAddrBus] commit_cp0_waddr_i,
    input wire [`RegBus] commit_cp0_wdata_i,
    
	// ��һ��ָ�����Ϣ	
	input wire [`RegAddrBus] wd_i1,
	input wire wreg_i1,
	input wire [`RegBus] wdata_i1,
	input wire [`InstAddrBus] inst_addr_i1,
	input wire is_in_delayslot_i1,
	input wire [31:0] excepttype_i1,
	
    // �ڶ���ָ�����Ϣ	
    input wire [`RegAddrBus] wd_i2,
    input wire wreg_i2,
    input wire [`RegBus] wdata_i2,
    input wire [`InstAddrBus] inst_addr_i2,
    input wire is_in_delayslot_i2,
    input wire [31:0] excepttype_i2,
    
	// �͵��ύ�׶ε���Ϣ
    output reg LLbit_o,
    output reg LLbit_we_o,
    output wire [`RegBus] mem_addr_o,
    
    // ��Ȩָ���йص���Ϣ
    output reg [2:0] cp0_wsel_o,
    output reg cp0_we_o,
    output reg [4:0] cp0_waddr_o,
    output reg [`RegBus] cp0_wdata_o,
    
	// ��һ��ָ�����Ϣ
	output reg [`RegAddrBus] wd_o1,
	output reg wreg_o1,
	output reg [`RegBus] wdata_o1,
	output wire [`InstAddrBus] inst_addr_o1,
	output wire is_in_delayslot_o1,
	
    // �ڶ���ָ�����Ϣ
    output reg [`RegAddrBus] wd_o2,
    output reg wreg_o2,
    output reg [`RegBus] wdata_o2,
    output wire [`InstAddrBus] inst_addr_o2,
    output wire is_in_delayslot_o2,
    
    // �쳣�йص���Ϣ
    output wire [`RegBus] cp0_epc_o,
    output wire [`RegBus] cp0_ebase_o,
    output wire [4:0] excepttype_o,
	output wire exception_flag,  // �Ƿ������쳣
	output wire exception_inst_sel  // �����쳣��ָ������һ��,Ϊ1��ʾ��һ����Ϊ0��ʾ�ڶ���
);

    reg [`RegBus] cp0_status;
    reg [`RegBus] cp0_cause;
    reg [`RegBus] cp0_epc;
    reg [`RegBus] cp0_ebase;
    reg [4:0] excepttype1;
    reg [4:0] excepttype2;
    reg int1,int2;
    wire exception_flag1, exception_flag2;
    
    assign cp0_epc_o = cp0_epc;
    assign cp0_ebase_o = cp0_ebase;
    assign is_in_delayslot_o1 = is_in_delayslot_i1;
    assign is_in_delayslot_o2 = is_in_delayslot_i2;
    assign inst_addr_o1 = inst_addr_i1;
    assign inst_addr_o2 = inst_addr_i2;
    assign mem_addr_o = mem_addr_i;
    
// �õ�cp0�мĴ���������ֵ����Ϊ���쳣����
    // status
    always @ (*) begin
        if (rst == `RstEnable) 
            cp0_status = `CP0_STATUS_RST;
        else if (commit_cp0_wsel_i == 3'b000 && commit_cp0_we_i == `WriteEnable && commit_cp0_waddr_i == `CP0_REG_STATUS) 
            cp0_status = {cp0_status_i[31:16], commit_cp0_wdata_i[15:8], cp0_status_i[7:2], cp0_status_i[1:0]};
        else 
            cp0_status = cp0_status_i;
    end
    
    // epc
    always @ (*) begin
        if (rst == `RstEnable) 
            cp0_epc = `ZeroWord;
        else if (commit_cp0_wsel_i == 3'b000 && commit_cp0_we_i == `WriteEnable && commit_cp0_waddr_i == `CP0_REG_EPC) 
            cp0_epc = commit_cp0_wdata_i;
        else 
            cp0_epc = cp0_epc_i;
    end
    
    // cause
    always @ (*) begin
        if (rst == `RstEnable) 
            cp0_cause = `ZeroWord;
        else if (commit_cp0_wsel_i == 3'b000 && commit_cp0_we_i == `WriteEnable && commit_cp0_waddr_i == `CP0_REG_CAUSE) 
            cp0_cause = {cp0_cause_i[31:10], commit_cp0_wdata_i[9:8], cp0_cause_i[7:0]};
        else 
            cp0_cause = cp0_cause_i;
    end
    
    // ebase
    always @ (*) begin
        if (rst == `RstEnable)
            cp0_ebase = `ZeroWord;
        else if (commit_cp0_wsel_i == 3'b001 && commit_cp0_we_i == `WriteEnable && commit_cp0_waddr_i == `CP0_REG_EBase) 
            cp0_ebase = commit_cp0_wdata_i;
        else 
            cp0_ebase = cp0_ebase_i;
    end
    
// �������յ��쳣����
    // ��һ��ָ��
    always @ (*) begin
        if (rst == `RstEnable) begin  
            excepttype1 = 5'b0;
            int1 = 1'b0;
        end else begin
            int1 = 1'b0;
            excepttype1 = 5'b0;
            if (| inst_addr_i1) begin // ��ˮ�ߵ�ǰû�����������
                if (((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && 
                    (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin    
                    excepttype1 = `EXCEPTION_INT;
                    int1 = 1'b1;
                // ���������ִ�д������ȼ������Բ����Ż�
                end else if (excepttype_i1[4])  excepttype1 = `EXCEPTION_ADEL;
                else if (excepttype_i1[10]) excepttype1 = `EXCEPTION_RI;
                else if (excepttype_i1[12]) excepttype1 = `EXCEPTION_OV;
                else if (excepttype_i1[13]) excepttype1 = `EXCEPTION_TR;
                else if (excepttype_i1[8])  excepttype1 = `EXCEPTION_SYS;
                else if (excepttype_i1[5])  excepttype1 = `EXCEPTION_ADES;
                else if (excepttype_i1[9])  excepttype1 = `EXCEPTION_BP;
                else if (excepttype_i1[14]) excepttype1 = `EXCEPTION_ERET;
            end
        end
    end
    
    // �ڶ���ָ��쳣����û�е�һ����
    always @ (*) begin
        if (rst == `RstEnable) begin
            excepttype2 = 5'b0;
            int2 = 1'b0;
        end else begin
            excepttype2 = 5'b0;
            int2 = 1'b0;
            if (| inst_addr_i2) begin // ��ˮ�ߵ�ǰû�����������
                if (((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && 
                    (cp0_status[1] == 1'b0) && (cp0_status[0] == 1'b1)) begin    
                    excepttype2 = `EXCEPTION_INT;
                    int2 = 1'b1;
                end else if (excepttype_i2[4])  excepttype2 = `EXCEPTION_ADEL;
                else if (excepttype_i2[10]) excepttype2 = `EXCEPTION_RI;
                else if (excepttype_i2[12]) excepttype2 = `EXCEPTION_OV;
            end
        end
    end
    
    assign exception_flag1 = (|excepttype_i1) | int1;
    assign exception_flag2 = (|excepttype_i2) | int2;
    assign exception_flag = exception_flag1 | exception_flag2;
    assign excepttype_o = exception_flag1 ? excepttype1 : 
                            exception_flag2 ? excepttype2 : 5'b0;
    assign exception_inst_sel = exception_flag1;
        
	always @ (*) begin
		if(rst == `RstEnable) begin
			wd_o1 = `NOPRegAddr;
			wd_o2 = `NOPRegAddr;
			wreg_o1 = `WriteDisable;
			wreg_o2 = `WriteDisable;
            wdata_o1 = `ZeroWord;
            wdata_o2 = `ZeroWord;
            LLbit_o = 1'b0;
            LLbit_we_o = `WriteDisable;
            cp0_we_o = `WriteDisable;
            cp0_waddr_o = 5'b00000;
            cp0_wdata_o = `ZeroWord;
            cp0_wsel_o = 3'b000;
		end else begin
            wd_o1 = wd_i1;
            wd_o2 = wd_i2;
			wreg_o1 = wreg_i1;
            wreg_o2 = wreg_i2;
            wdata_o1 = wdata_i1;
			wdata_o2 = wdata_i2;
            LLbit_o = LLbit_i;
            LLbit_we_o = LLbit_we_i;
            cp0_we_o = cp0_we_i;
            cp0_waddr_o = cp0_waddr_i;
            cp0_wdata_o = cp0_wdata_i;
            cp0_wsel_o = cp0_wsel_i;
            case (aluop_i)
                `EXE_LB_OP:     begin
                    case (mem_addr_i[1:0])
                        2'b00:  wdata_o1 = {{24{mem_data_i[7]}},mem_data_i[7:0]};
                        2'b01:  wdata_o1 = {{24{mem_data_i[15]}},mem_data_i[15:8]};
                        2'b10:  wdata_o1 = {{24{mem_data_i[23]}},mem_data_i[23:16]};
                        2'b11:  wdata_o1 = {{24{mem_data_i[31]}},mem_data_i[31:24]};
                        default: ;
                    endcase
                end
                `EXE_LBU_OP:    begin
                    case (mem_addr_i[1:0])
                        2'b00:  wdata_o1 = {24'b0,mem_data_i[7:0]};
                        2'b01:  wdata_o1 = {24'b0,mem_data_i[15:8]};
                        2'b10:  wdata_o1 = {24'b0,mem_data_i[23:16]};
                        2'b11:  wdata_o1 = {24'b0,mem_data_i[31:24]};
                        default: ; 
                    endcase                
                end
                `EXE_LH_OP:     begin
                    case (mem_addr_i[1:0])
                        2'b00:  wdata_o1 = {{16{mem_data_i[15]}},mem_data_i[15:0]};
                        2'b10:  wdata_o1 = {{16{mem_data_i[31]}},mem_data_i[31:16]};
                        default: ;
                    endcase                    
                end
                `EXE_LHU_OP:    begin
                    case (mem_addr_i[1:0])
                        2'b00:  wdata_o1 = {{16{1'b0}},mem_data_i[15:0]};   
                        2'b10:  wdata_o1 = {{16{1'b0}},mem_data_i[31:16]};
                        default: ;
                    endcase                
                end
                `EXE_LW_OP:     begin
                    wdata_o1 = mem_data_i;  
                end
                `EXE_LWL_OP:    begin
                    case (mem_addr_i[1:0])
                        2'b00:  wdata_o1 = {mem_data_i[7:0],reg2_i[23:0]};
                        2'b01:  wdata_o1 = {mem_data_i[15:0],reg2_i[15:0]};
                        2'b10:  wdata_o1 = {mem_data_i[23:0],reg2_i[7:0]};
                        2'b11:  wdata_o1 = mem_data_i;    
                        default: ;
                    endcase                
                end
                `EXE_LWR_OP:    begin
                    case (mem_addr_i[1:0])
                        2'b00:  wdata_o1 = mem_data_i; 
                        2'b01:  wdata_o1 = {reg2_i[31:24],mem_data_i[31:8]};
                        2'b10:  wdata_o1 = {reg2_i[31:16],mem_data_i[31:16]}; 
                        2'b11:  wdata_o1 = {reg2_i[31:8],mem_data_i[31:24]};  
                        default: ;
                    endcase                    
                end
                `EXE_LL_OP:     begin
                    wdata_o1 = mem_data_i;
                end
                default: ;
            endcase
        end  //if
	end  //always
			
endmodule
