//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/09 14:33:20
// Design Name: 
// Module Name: defines
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

//********************		 全局的宏定义		********************
`define RstEnable           1'b0			    //复位信号有效
`define RstDisable			 1'b1			  	//复位信号无效
`define ZeroWord			 32'h00000000  		//32位的数值0
`define WriteEnable		 1'b1				//使能写
`define WriteDisable		 1'b0				//禁止写
`define ReadEnable			 1'b1			    //使能读
`define ReadDisable		 1'b0				//禁止读
`define AluOpBus			 7:0				//译码阶段的输出aluop_o的宽度
`define AluSelBus			 2:0				//译码阶段的输出alusel_o的宽度
`define InstValid			 1'b0				//指令有效
`define InstInvalid		 1'b1				//指令无效
`define True_v				 1'b1				//逻辑"真"
`define False_v			 1'b0				//逻辑"假"
`define ChipEnable			 1'b1				//芯片使能
`define ChipDisable		 1'b0				//芯片禁止
`define Stop                1'b1               //流水线暂停
`define NoStop              1'b0               //流水线继续
`define Branch              1'b1               //转移
`define NotBranch           1'b0               //不转移
`define InDelaySlot         1'b1               //在延迟槽中
`define NotInDelaySlot      1'b0               //不在延迟槽中
`define InterruptAssert     1'b1               //时钟中断开启
`define InterruptNotAssert  1'b0               //时钟中断关闭
`define TrapAssert          1'b1               //自陷异常开启
`define TrapNotAssert       1'b0               //自陷异常关闭
`define RAWIndependent      1'b0               //没有RAW相关
`define RAWDependent        1'b1               //RAW相关
`define LoadIndependent     1'b0               //无load相关
`define LoadDependent       1'b1               //load相关
`define SingleIssue         1'b0               //单发射
`define DualIssue           1'b1               //双发射
`define Exception           1'b0
`define FailedBranchPrediction  1'b1

//********************		与具体指令有关的宏定义		********************
`define EXE_AND			 6'b100100			//指令and的功能码
`define EXE_OR			     6'b100101			//指令or的功能码
`define EXE_XOR			 6'b100110			//指令xor的功能码
`define EXE_NOR			 6'b100111			//指令nor的功能码
`define EXE_ANDI			 6'b001100			//指令andi的指令码
`define EXE_ORI			 6'b001101			//指令ori的指令码
`define EXE_XORI			 6'b001110			//指令xori的指令码
`define EXE_LUI			 6'b001111			//指令lui的指令码

`define EXE_SLL			 6'b000000			//指令sll的功能码
`define EXE_SLLV			 6'b000100			//指令sllv的功能码
`define EXE_SRL			 6'b000010			//指令srl的功能码
`define EXE_SRLV			 6'b000110			//指令srlv的功能码
`define EXE_SRA			 6'b000011			//指令sra的功能码
`define EXE_SRAV			 6'b000111			//指令srav的功能码

`define EXE_SYNC			 6'b001111			//指令sync的功能码
`define EXE_PREF			 6'b110011			//指令pref的指令码
`define EXE_SPECIAL_INST	 6'b000000			//SPECIAL类指令的指令码
`define EXE_REGIMM_INST     6'b000001
`define EXE_SPECIAL2_INST   6'b011100

`define EXE_MOVZ			 6'b001010			//指令movz的功能码
`define EXE_MOVN			 6'b001011			//指令movn的功能码
`define EXE_MFHI			 6'b010000			//指令mfhi的功能码
`define EXE_MTHI			 6'b010001			//指令mthi的功能码
`define EXE_MFLO			 6'b010010			//指令mflo的功能码
`define EXE_MTLO			 6'b010011			//指令mtlo的功能码

`define EXE_SLT             6'b101010
`define EXE_SLTU            6'b101011
`define EXE_SLTI            6'b001010
`define EXE_SLTIU           6'b001011
`define EXE_ADD             6'b100000
`define EXE_ADDU            6'b100001
`define EXE_SUB             6'b100010
`define EXE_SUBU            6'b100011
`define EXE_ADDI            6'b001000
`define EXE_ADDIU           6'b001001
`define EXE_CLZ             6'b100000  // CLZ、CLO的功能码与ADD、ADDU相同但指令码不同
`define EXE_CLO             6'b100001

`define EXE_MULT            6'b011000
`define EXE_MULTU           6'b011001
`define EXE_MUL             6'b000010
`define EXE_MADD            6'b000000
`define EXE_MADDU           6'b000001
`define EXE_MSUB            6'b000100
`define EXE_MSUBU           6'b000101

`define EXE_DIV             6'b011010
`define EXE_DIVU            6'b011011

`define EXE_J               6'b000010
`define EXE_JAL             6'b000011
`define EXE_JALR            6'b001001
`define EXE_JR              6'b001000
`define EXE_BEQ             6'b000100
`define EXE_BGEZ            5'b00001
`define EXE_BGEZAL          5'b10001
`define EXE_BGTZ            6'b000111
`define EXE_BLEZ            6'b000110
`define EXE_BLTZ            5'b00000
`define EXE_BLTZAL          5'b10000
`define EXE_BNE             6'b000101
`define EXE_BEQL            6'b010100
`define EXE_BNEL            6'b010101
`define EXE_BGTZL           6'b010111
`define EXE_BLEZL           6'b010110
`define EXE_BLTZL           5'b00010
`define EXE_BLTZALL         5'b10010
`define EXE_BGEZL           5'b00011
`define EXE_BGEZALL         5'b10011

`define EXE_LB              6'b100000
`define EXE_LBU             6'b100100
`define EXE_LH              6'b100001
`define EXE_LHU             6'b100101
`define EXE_LW              6'b100011
`define EXE_LWL             6'b100010
`define EXE_LWR             6'b100110
`define EXE_SB              6'b101000
`define EXE_SH              6'b101001
`define EXE_SW              6'b101011
`define EXE_SWL             6'b101010
`define EXE_SWR             6'b101110
`define EXE_LL              6'b110000
`define EXE_SC              6'b111000

`define EXE_SYSCALL         6'b001100
`define EXE_BREAK           6'b001101
`define EXE_TEQ             6'b110100
`define EXE_TEQI            5'b01100
`define EXE_TGE             6'b110000
`define EXE_TGEI            5'b01000
`define EXE_TGEIU           5'b01001
`define EXE_TGEU            6'b110001
`define EXE_TLT             6'b110010
`define EXE_TLTI            5'b01010
`define EXE_TLTIU           5'b01011
`define EXE_TLTU            6'b110011
`define EXE_TNE             6'b110110
`define EXE_TNEI            5'b01110
`define EXE_ERET            32'b01000010000000000000000000011000
`define EXE_COP0            6'b010000

`define EXE_CACHE           6'b101111
`define EXE_III             5'b00000
`define EXE_IIST            5'b01000
`define EXE_IHI             5'b10000
`define EXE_DIWI            5'b00001
`define EXE_DIST            5'b01001
`define EXE_DHI             5'b10001
`define EXE_DHWI            5'b10101
`define EXE_III_OP          8'b11111001
`define EXE_IIST_OP         8'b11111010
`define EXE_IHI_OP          8'b11111011
`define EXE_DIWI_OP         8'b11111100
`define EXE_DIST_OP         8'b11111101
`define EXE_DHI_OP          8'b11111110
`define EXE_DHWI_OP         8'b11111111

//AluOp
`define EXE_AND_OP   8'b00100100
`define EXE_OR_OP    8'b00100101
`define EXE_XOR_OP  8'b00100110
`define EXE_NOR_OP  8'b00100111
`define EXE_ANDI_OP  8'b01011001
`define EXE_ORI_OP  8'b01011010
`define EXE_XORI_OP  8'b01011011
`define EXE_LUI_OP  8'b01011100   

`define EXE_SLL_OP  8'b01111100
`define EXE_SLLV_OP  8'b00000100
`define EXE_SRL_OP  8'b00000010
`define EXE_SRLV_OP  8'b00000110
`define EXE_SRA_OP  8'b00000011
`define EXE_SRAV_OP  8'b00000111

`define EXE_MOVZ_OP  8'b00001010
`define EXE_MOVN_OP  8'b00001011
`define EXE_MFHI_OP  8'b00010000
`define EXE_MTHI_OP  8'b00010001
`define EXE_MFLO_OP  8'b00010010
`define EXE_MTLO_OP  8'b00010011

`define EXE_SLT_OP  8'b00101010
`define EXE_SLTU_OP  8'b00101011
`define EXE_SLTI_OP  8'b01010111
`define EXE_SLTIU_OP  8'b01011000   
`define EXE_ADD_OP  8'b00100000
`define EXE_ADDU_OP  8'b00100001
`define EXE_SUB_OP  8'b00100010
`define EXE_SUBU_OP  8'b00100011
`define EXE_ADDI_OP  8'b01010101
`define EXE_ADDIU_OP  8'b01010110
`define EXE_CLZ_OP  8'b10110000
`define EXE_CLO_OP  8'b10110001

`define EXE_MULT_OP  8'b00011000
`define EXE_MULTU_OP  8'b00011001
`define EXE_MUL_OP  8'b10101001
`define EXE_MADD_OP  8'b10100110
`define EXE_MADDU_OP  8'b10101000
`define EXE_MSUB_OP  8'b10101010
`define EXE_MSUBU_OP  8'b10101011

`define EXE_DIV_OP  8'b00011010
`define EXE_DIVU_OP  8'b00011011

`define EXE_J_OP  8'b01001111
`define EXE_JAL_OP  8'b01010000
`define EXE_JALR_OP  8'b00001001
`define EXE_JR_OP  8'b00001000
`define EXE_BEQ_OP  8'b01010001
`define EXE_BGEZ_OP  8'b01000001
`define EXE_BGEZAL_OP  8'b01001011
`define EXE_BGTZ_OP  8'b01010100
`define EXE_BLEZ_OP  8'b01010011
`define EXE_BLTZ_OP  8'b01000000
`define EXE_BLTZAL_OP  8'b01001010
`define EXE_BNE_OP  8'b01010010

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LL_OP  8'b11110000
`define EXE_LW_OP  8'b11100011
`define EXE_LWL_OP  8'b11100010
`define EXE_LWR_OP  8'b11100110
`define EXE_PREF_OP  8'b11110011
`define EXE_SB_OP  8'b11101000
`define EXE_SC_OP  8'b11111000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011
`define EXE_SWL_OP  8'b11101010
`define EXE_SWR_OP  8'b11101110
`define EXE_SYNC_OP  8'b00001111

`define EXE_MFC0_OP 8'b01011101
`define EXE_MTC0_OP 8'b01100000

`define EXE_BREAK_OP 8'b00001101
`define EXE_SYSCALL_OP 8'b00001100

`define EXE_TEQ_OP 8'b00110100
`define EXE_TEQI_OP 8'b01001000
`define EXE_TGE_OP 8'b00110000
`define EXE_TGEI_OP 8'b01000100
`define EXE_TGEIU_OP 8'b01000101
`define EXE_TGEU_OP 8'b00110001
`define EXE_TLT_OP 8'b00110010
`define EXE_TLTI_OP 8'b01000110
`define EXE_TLTIU_OP 8'b01000111
`define EXE_TLTU_OP 8'b00110011
`define EXE_TNE_OP 8'b00110110
`define EXE_TNEI_OP 8'b01001001
   
`define EXE_ERET_OP 8'b01101011

`define EXE_NOP_OP    8'b00000000

//AluSel
`define EXE_RES_NOP		 3'b000
`define EXE_RES_LOGIC		 3'b001
`define EXE_RES_SHIFT       3'b010
`define EXE_RES_MOVE        3'b011
`define EXE_RES_ARITHMETIC  3'b100
`define EXE_RES_MUL         3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE  3'b111

//div
`define DivFree		     2'b00
`define DivByZero		     2'b01
`define DivOn		         2'b10
`define DivEnd		         2'b11
`define DivResultReady		 1'b1
`define DivResultNotReady   1'b0
`define DivStart		     1'b1
`define DivStop     		 1'b0

//********************		与指令存储器ROM有关的宏定义		********************
`define InstAddrBus		 31:0				//ROM的地址总线宽度
`define InstBus			 31:0				//ROM的数据总线宽度
`define InstMemNum			 131072				//ROM的实际大小为128KB
`define InstMemNumLog2		 17					//ROM实际使用的地址线宽度

//********************		与通用寄存器Regfile有关的宏定义		********************
`define RegAddrBus			 4:0				//Regfile模块的地址线宽度
`define RegBus				 31:0				//Regfile模块的数据线宽度
`define DoubleRegBus        63:0
`define RegWidth			 32					//通用寄存器的宽度
`define DoubleRegWidth		 64					//两倍的通用寄存器的数据线宽度
`define RegNum				 32					//通用寄存器的数量
`define RegNumLog2			 5					//寻址通用寄存器使用的地址位数
`define NOPRegAddr			 5'b00000

//********************		与数据存储器RAM有关的宏定义		********************
`define DataAddrBus		 31:0				//地址总线宽度
`define DataBus     		 31:0				//数据总线宽度
`define DataMemNum			 134217728				//RAM的实际大小为128KB
`define DataMemNumLog2		 27					//RAM实际使用的地址线宽度
`define ByteWidth           7:0                //一个字节的宽度，是8bit 

//********************		CP0中各个寄存器的地址的宏定义		********************
`define CP0_REG_INDEX       5'b00000  // read/write
`define CP0_REG_RANDOM      5'b00001  // read only
`define CP0_REG_EntryLo0    5'b00010  // read/write
`define CP0_REG_EntryLo1    5'b00011  // read/write
`define CP0_REG_CONTEXT     5'b00100  // read/write
`define CP0_REG_PAGEMASK    5'b00101  // read/write
`define CP0_REG_WIRED       5'b00110  // read/write
`define CPO_REG_BADVADDR    5'b01000
`define CP0_REG_COUNT       5'b01001
`define CP0_REG_EntryHi     5'b01010  // read/write
`define CP0_REG_COMPARE     5'b01011
`define CP0_REG_STATUS      5'b01100
`define CP0_REG_CAUSE       5'b01101
`define CP0_REG_EPC         5'b01110
`define CP0_REG_PRId        5'b01111
`define CP0_REG_EBase       5'b01111
`define CP0_REG_CONFIG      5'b10000
`define CP0_REG_CONFIG1     5'b10000  // read only
`define CP0_REG_TagLo       5'b11100  // read/write
`define CP0_REG_TagHi       5'b11101  // read/write

`define EXCEPTION_INT 5'h00
`define EXCEPTION_MOD 5'h01
`define EXCEPTION_TLBL 5'h02
`define EXCEPTION_TLBS 5'h03
`define EXCEPTION_ADEL 5'h04
`define EXCEPTION_ADES 5'h05
`define EXCEPTION_SYS 5'h08
`define EXCEPTION_BP 5'h09
`define EXCEPTION_RI 5'h0a
`define EXCEPTION_CpU 5'h0b
`define EXCEPTION_OV 5'h0c
`define EXCEPTION_TR 5'h0d
`define EXCEPTION_ERET 5'h0e

//********************		与CP0有关的宏定义		********************
`define CP0_STATUS_RST      32'b00000000010000000000000000000000   
`define CP0_CONFIG_RST      32'b10000000000000000000000010000010
`define CP0_CONFIG1_RST     32'b00011110100110010100110010000000
`define CP0_RANDOM_RST      32'h15
`define CP0_PRID_RST        32'h00004220  // 龙芯开源gs232的prid
`define CP0_EBASE_RST       32'hbfc00380

//********************		与InstBuffer有关的宏定义		********************
`define InstBufferSize      32
`define InstBufferSizeLog2  5
`define Valid               1'b1
`define Invalid             1'b0

//********************		与BPU有关的宏定义		********************
`define BPBSize             64
`define BPBSizeLog2         6
`define BPBPacketWidth      34:0
`define TagWidth            23:0
`define TypeWidth           1:0
`define DirWidth            1:0
// 指令类型
`define TYPE_CALL           2'b11
`define TYPE_RET            2'b10
`define TYPE_PCR            2'b01
`define TYPE_NUL            2'b00

//********************		与CACHE指令有关的宏定义		********************
//  ICACHE
`define INDEX_INVALID       3'b000
`define INDEX_STORE_TAG     3'b010
`define HIT_INVALID         3'b100
`define RESERVED            3'b111

//  DCACHE
`define INDEX_WRITEBACK_INVALID     3'b000
`define HIT_WRITEBACK_INVALID       3'b101