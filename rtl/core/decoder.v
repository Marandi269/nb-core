// RISC-V RV64IMA 指令译码器
// 解析指令，生成控制信号

`include "defines.v"

module decoder (
    input  wire [`ILEN-1:0]          inst,        // 32位指令

    // 解析出的字段
    output wire [6:0]                 opcode,
    output wire [`REG_ADDR_WIDTH-1:0] rs1,
    output wire [`REG_ADDR_WIDTH-1:0] rs2,
    output wire [`REG_ADDR_WIDTH-1:0] rd,
    output wire [2:0]                 funct3,
    output wire [6:0]                 funct7,

    // 立即数
    output reg  [`XLEN-1:0]          imm,

    // 控制信号
    output reg  [`ALU_OP_WIDTH-1:0]  alu_op,      // ALU操作
    output reg                        alu_src,     // ALU源选择：0=rs2, 1=imm
    output reg                        reg_write,   // 寄存器写使能
    output reg                        mem_read,    // 内存读
    output reg                        mem_write,   // 内存写
    output reg  [2:0]                 mem_op,      // 内存操作类型
    output reg                        branch,      // 分支指令
    output reg                        jump,        // 跳转指令
    output reg  [1:0]                 wb_src       // 写回源：00=ALU, 01=MEM, 10=PC+4
);

    // 解析指令字段
    assign opcode = inst[6:0];
    assign rd     = inst[11:7];
    assign funct3 = inst[14:12];
    assign rs1    = inst[19:15];
    assign rs2    = inst[24:20];
    assign funct7 = inst[31:25];

    // 立即数扩展
    always @(*) begin
        case (opcode)
            // I型: 12位立即数符号扩展
            `OPCODE_OP_IMM, `OPCODE_OP_IMM_32, `OPCODE_LOAD, `OPCODE_JALR:
                imm = {{52{inst[31]}}, inst[31:20]};

            // S型: store指令
            `OPCODE_STORE:
                imm = {{52{inst[31]}}, inst[31:25], inst[11:7]};

            // B型: 分支指令
            `OPCODE_BRANCH:
                imm = {{51{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};

            // U型: LUI, AUIPC
            `OPCODE_LUI, `OPCODE_AUIPC:
                imm = {{32{inst[31]}}, inst[31:12], 12'b0};

            // J型: JAL
            `OPCODE_JAL:
                imm = {{43{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};

            default:
                imm = 0;
        endcase
    end

    // 控制信号生成
    always @(*) begin
        // 默认值
        alu_op = `ALU_NOP;
        alu_src = 0;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        mem_op = `MEM_NOP;
        branch = 0;
        jump = 0;
        wb_src = 2'b00;

        case (opcode)
            // R型算术逻辑指令
            `OPCODE_OP, `OPCODE_OP_32: begin
                alu_src = 0;  // 使用rs2
                reg_write = 1;
                wb_src = 2'b00;  // 写回ALU结果

                // 根据funct3和funct7选择ALU操作
                if (funct7 == `FUNCT7_MULDIV) begin
                    // M扩展：乘除法
                    case (funct3)
                        `FUNCT3_MUL:    alu_op = `ALU_MUL;
                        `FUNCT3_MULH:   alu_op = `ALU_MULH;
                        `FUNCT3_MULHSU: alu_op = `ALU_MULHSU;
                        `FUNCT3_MULHU:  alu_op = `ALU_MULHU;
                        `FUNCT3_DIV:    alu_op = `ALU_DIV;
                        `FUNCT3_DIVU:   alu_op = `ALU_DIVU;
                        `FUNCT3_REM:    alu_op = `ALU_REM;
                        `FUNCT3_REMU:   alu_op = `ALU_REMU;
                        default:        alu_op = `ALU_NOP;
                    endcase
                end else begin
                    // 基础算术逻辑
                    case (funct3)
                        `FUNCT3_ADD_SUB: alu_op = (funct7 == `FUNCT7_SUB) ? `ALU_SUB : `ALU_ADD;
                        `FUNCT3_SLL:     alu_op = `ALU_SLL;
                        `FUNCT3_SLT:     alu_op = `ALU_SLT;
                        `FUNCT3_SLTU:    alu_op = `ALU_SLTU;
                        `FUNCT3_XOR:     alu_op = `ALU_XOR;
                        `FUNCT3_SR:      alu_op = (funct7 == `FUNCT7_SRA) ? `ALU_SRA : `ALU_SRL;
                        `FUNCT3_OR:      alu_op = `ALU_OR;
                        `FUNCT3_AND:     alu_op = `ALU_AND;
                        default:         alu_op = `ALU_NOP;
                    endcase
                end
            end

            // I型立即数算术指令
            `OPCODE_OP_IMM, `OPCODE_OP_IMM_32: begin
                alu_src = 1;  // 使用立即数
                reg_write = 1;
                wb_src = 2'b00;

                case (funct3)
                    `FUNCT3_ADD_SUB: alu_op = `ALU_ADD;  // ADDI
                    `FUNCT3_SLT:     alu_op = `ALU_SLT;
                    `FUNCT3_SLTU:    alu_op = `ALU_SLTU;
                    `FUNCT3_XOR:     alu_op = `ALU_XOR;
                    `FUNCT3_OR:      alu_op = `ALU_OR;
                    `FUNCT3_AND:     alu_op = `ALU_AND;
                    `FUNCT3_SLL:     alu_op = `ALU_SLL;
                    `FUNCT3_SR:      alu_op = (funct7 == `FUNCT7_SRA) ? `ALU_SRA : `ALU_SRL;
                    default:         alu_op = `ALU_NOP;
                endcase
            end

            // Load指令
            `OPCODE_LOAD: begin
                alu_op = `ALU_ADD;  // 地址 = rs1 + imm
                alu_src = 1;
                reg_write = 1;
                mem_read = 1;
                wb_src = 2'b01;  // 写回内存数据

                case (funct3)
                    `FUNCT3_LB:  mem_op = `MEM_LB;
                    `FUNCT3_LH:  mem_op = `MEM_LH;
                    `FUNCT3_LW:  mem_op = `MEM_LW;
                    `FUNCT3_LD:  mem_op = `MEM_LD;
                    default:     mem_op = `MEM_NOP;
                endcase
            end

            // Store指令
            `OPCODE_STORE: begin
                alu_op = `ALU_ADD;  // 地址 = rs1 + imm
                alu_src = 1;
                mem_write = 1;

                case (funct3)
                    `FUNCT3_SB:  mem_op = `MEM_SB;
                    `FUNCT3_SH:  mem_op = `MEM_SH;
                    `FUNCT3_SW:  mem_op = `MEM_SW;
                    `FUNCT3_SD:  mem_op = `MEM_LD;  // 使用LD的编码
                    default:     mem_op = `MEM_NOP;
                endcase
            end

            // 分支指令
            `OPCODE_BRANCH: begin
                alu_src = 0;
                branch = 1;

                // 根据funct3选择比较类型
                case (funct3)
                    `FUNCT3_BEQ:  alu_op = `ALU_SUB;   // 相等判断
                    `FUNCT3_BNE:  alu_op = `ALU_SUB;
                    `FUNCT3_BLT:  alu_op = `ALU_SLT;   // 有符号比较
                    `FUNCT3_BGE:  alu_op = `ALU_SLT;
                    `FUNCT3_BLTU: alu_op = `ALU_SLTU;  // 无符号比较
                    `FUNCT3_BGEU: alu_op = `ALU_SLTU;
                    default:      alu_op = `ALU_NOP;
                endcase
            end

            // JAL: 无条件跳转
            `OPCODE_JAL: begin
                jump = 1;
                reg_write = 1;
                wb_src = 2'b10;  // 写回PC+4
            end

            // JALR: 寄存器跳转
            `OPCODE_JALR: begin
                alu_op = `ALU_ADD;
                alu_src = 1;
                jump = 1;
                reg_write = 1;
                wb_src = 2'b10;  // 写回PC+4
            end

            // LUI: 加载高位立即数
            `OPCODE_LUI: begin
                alu_op = `ALU_ADD;
                alu_src = 1;
                reg_write = 1;
                wb_src = 2'b00;
                // imm已经是正确的值，ALU加0即可
            end

            // AUIPC: PC + 立即数
            `OPCODE_AUIPC: begin
                alu_op = `ALU_ADD;
                alu_src = 1;
                reg_write = 1;
                wb_src = 2'b00;
                // 需要在顶层将PC传入ALU
            end

            default: begin
                // 非法指令，保持默认值
            end
        endcase
    end

endmodule
