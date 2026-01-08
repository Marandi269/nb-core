// RISC-V RV64IMA 定义文件
// 包含指令编码、操作码、功能码等常量定义

`ifndef DEFINES_V
`define DEFINES_V

// 数据宽度
`define XLEN 64
`define ILEN 32          // 指令长度
`define REG_ADDR_WIDTH 5 // 寄存器地址宽度 (32个寄存器)

// 指令格式 - Opcode (inst[6:0])
`define OPCODE_LOAD    7'b0000011
`define OPCODE_STORE   7'b0100011
`define OPCODE_BRANCH  7'b1100011
`define OPCODE_JALR    7'b1100111
`define OPCODE_JAL     7'b1101111
`define OPCODE_OP_IMM  7'b0010011
`define OPCODE_OP      7'b0110011
`define OPCODE_OP_IMM_32 7'b0011011  // RV64I 32位立即数运算
`define OPCODE_OP_32   7'b0111011    // RV64I 32位寄存器运算
`define OPCODE_AUIPC   7'b0010111
`define OPCODE_LUI     7'b0110111
`define OPCODE_SYSTEM  7'b1110011
`define OPCODE_AMO     7'b0101111    // 原子操作 (A扩展)

// Funct3 - 算术逻辑指令
`define FUNCT3_ADD_SUB 3'b000
`define FUNCT3_SLL     3'b001
`define FUNCT3_SLT     3'b010
`define FUNCT3_SLTU    3'b011
`define FUNCT3_XOR     3'b100
`define FUNCT3_SR      3'b101  // SRL/SRA
`define FUNCT3_OR      3'b110
`define FUNCT3_AND     3'b111

// Funct3 - 分支指令
`define FUNCT3_BEQ     3'b000
`define FUNCT3_BNE     3'b001
`define FUNCT3_BLT     3'b100
`define FUNCT3_BGE     3'b101
`define FUNCT3_BLTU    3'b110
`define FUNCT3_BGEU    3'b111

// Funct3 - Load/Store
`define FUNCT3_LB      3'b000
`define FUNCT3_LH      3'b001
`define FUNCT3_LW      3'b010
`define FUNCT3_LD      3'b011  // RV64I
`define FUNCT3_LBU     3'b100
`define FUNCT3_LHU     3'b101
`define FUNCT3_LWU     3'b110  // RV64I
`define FUNCT3_SB      3'b000
`define FUNCT3_SH      3'b001
`define FUNCT3_SW      3'b010
`define FUNCT3_SD      3'b011  // RV64I

// Funct3 - 乘除法 (M扩展)
`define FUNCT3_MUL     3'b000
`define FUNCT3_MULH    3'b001
`define FUNCT3_MULHSU  3'b010
`define FUNCT3_MULHU   3'b011
`define FUNCT3_DIV     3'b100
`define FUNCT3_DIVU    3'b101
`define FUNCT3_REM     3'b110
`define FUNCT3_REMU    3'b111

// Funct7
`define FUNCT7_ADD     7'b0000000
`define FUNCT7_SUB     7'b0100000
`define FUNCT7_SRL     7'b0000000
`define FUNCT7_SRA     7'b0100000
`define FUNCT7_MULDIV  7'b0000001  // M扩展

// ALU 操作码 (内部使用)
`define ALU_OP_WIDTH 5

`define ALU_ADD   5'd0
`define ALU_SUB   5'd1
`define ALU_SLL   5'd2
`define ALU_SLT   5'd3
`define ALU_SLTU  5'd4
`define ALU_XOR   5'd5
`define ALU_SRL   5'd6
`define ALU_SRA   5'd7
`define ALU_OR    5'd8
`define ALU_AND   5'd9
`define ALU_MUL   5'd10
`define ALU_MULH  5'd11
`define ALU_MULHSU 5'd12
`define ALU_MULHU 5'd13
`define ALU_DIV   5'd14
`define ALU_DIVU  5'd15
`define ALU_REM   5'd16
`define ALU_REMU  5'd17
`define ALU_NOP   5'd31

// 内存操作类型
`define MEM_OP_WIDTH 3
`define MEM_NOP   3'd0
`define MEM_LB    3'd1
`define MEM_LH    3'd2
`define MEM_LW    3'd3
`define MEM_LD    3'd4
`define MEM_SB    3'd5
`define MEM_SH    3'd6
`define MEM_SW    3'd7

`endif // DEFINES_V
