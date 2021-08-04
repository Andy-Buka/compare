`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/16 16:21:31
// Design Name: 
// Module Name: div
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


module div(

	input wire clk,
	input wire rst,
	
	input wire signed_div_i,  // �Ƿ�Ϊ�з��ų���
	input wire [`RegBus] opdata1_i,  // ������
	input wire [`RegBus] opdata2_i,  // ����
	input wire start_i,  // �Ƿ�ʼ��������
	input wire annul_i,  // �Ƿ�ȡ����������
	
	output reg [`DoubleRegBus] result_o,
	output reg ready_o
);

	wire [32:0] div_temp;
	reg [5:0] cnt;
	reg [64:0] dividend;
	reg [1:0] state;
	reg [31:0] divisor;
	
    // dividend�ĵ�32Ϊ������Ǳ��������м�������k�ε���������ʱ��dividend[k:0]
    // ����ľ��ǵ�ǰ�õ����м�����dividend[31:k+1]����ľ��Ǳ������л�û�в�������
    // ������,dividend��32λ����ÿ�ε���ʱ�ı�����������dividend[63:32]����minuend,
    // divisor���ǳ���n���˴����еľ���minuend-n���㣬���������div_temp��
	assign div_temp = {1'b0,dividend[63:32]} - {1'b0,divisor};

	always @ (posedge clk) begin
		if (rst == `RstEnable) begin
			state <= `DivFree;
			ready_o <= `DivResultNotReady;
			result_o <= {`ZeroWord,`ZeroWord};
		end else begin
		    case (state)
                `DivFree:      begin  // ����ģ�����
                    if (start_i == `DivStart && annul_i == 1'b0) begin
                        if (opdata2_i == `ZeroWord)
                            state <= `DivByZero;
                        else begin
                            state <= `DivOn;
                            cnt <= 6'b000000;
                            dividend[63:33] <= 31'b0;
                            dividend[0] <= 1'b0;
                            if (signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 )
                                dividend[32:1] <= ~opdata1_i + 1;
                            else
                                dividend[32:1] <= opdata1_i;
                            if (signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 )
                                divisor <= ~opdata2_i + 1;
                            else
                                divisor <= opdata2_i;
                        end
                    end else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord,`ZeroWord};
                    end          	
                end
                `DivByZero:		begin
                    dividend <= {`ZeroWord,`ZeroWord};
                    state <= `DivEnd;		 		
                end
                `DivOn:         begin
                    if(annul_i == 1'b0) begin
                        if(cnt != 6'b100000) begin  // cnt��Ϊ32����ʾ���̷���û�н���
                            if(div_temp[32] == 1'b1)
                                // ���div_temp[32]Ϊ1����ʾ(minuend-n)���С��0��
                                // ��dividend������һλ�������ͽ���������û�в��������
                                // ���λ���뵽��һ�ε����ı������У�ͬʱ��0׷�ӵ��м���
                                dividend <= {dividend[63:0] , 1'b0};
                            else
                                // ���div_temp[32]Ϊ0����ʾ(minuend-n)������ڵ���0��
                                // �������Ľ���뱻������û�в�����������λ���뵽
                                // ��һ�ε����ı������У�ͬʱ��1׷�ӵ��м���
                                dividend <= {div_temp[31:0] , dividend[31:0] , 1'b1};
                            cnt <= cnt + 1;
                        end else begin
                            if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ opdata2_i[31]) == 1'b1))
                                dividend[31:0] <= (~dividend[31:0] + 1);
                            if((signed_div_i == 1'b1) && ((opdata1_i[31] ^ dividend[64]) == 1'b1))           
                                dividend[64:33] <= (~dividend[64:33] + 1);
                            state <= `DivEnd;
                            cnt <= 6'b000000;            	
                        end
                    end else
                        state <= `DivFree;  // ȡ���Ļ���ֱ�ӻص�DivFree״̬
                end
                `DivEnd:       begin
                    result_o <= {dividend[64:33], dividend[31:0]};  
                    ready_o <= `DivResultReady;
                    if(start_i == `DivStop) begin
                        state <= `DivFree;
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord,`ZeroWord};       	
                    end		  	
                end
            endcase
        end
    end

endmodule
