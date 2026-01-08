// RISC-V RV64IMA 单周期CPU
// 顶层模块，连接所有组件

`include "defines.v"

module cpu_single_cycle (
    input  wire clk,
    input  wire rst_n
); /* verilator public_module */

    // PC相关信号
    wire [`XLEN-1:0] pc, pc_next;
    wire             branch_taken;
    wire [`XLEN-1:0] branch_target;

    // 指令存储器接口
    wire [`ILEN-1:0] inst;

    // 译码器输出
    wire [6:0]                opcode;
    wire [`REG_ADDR_WIDTH-1:0] rs1, rs2, rd;
    wire [2:0]                funct3;
    wire [6:0]                funct7;
    wire [`XLEN-1:0]         imm;
    wire [`ALU_OP_WIDTH-1:0] alu_op;
    wire                      alu_src;
    wire                      reg_write;
    wire                      mem_read;
    wire                      mem_write;
    wire [2:0]                mem_op;
    wire                      branch;
    wire                      jump;
    wire [1:0]                wb_src;

    // 寄存器文件信号
    wire [`XLEN-1:0] rs1_data, rs2_data;
    wire [`XLEN-1:0] rd_data;

    // ALU信号
    wire [`XLEN-1:0] alu_a, alu_b;
    wire [`XLEN-1:0] alu_result;
    wire             alu_zero;

    // 数据存储器信号
    wire [`XLEN-1:0] mem_read_data;

    // 分支判断
    wire             branch_condition;

    // ========== 程序计数器 ==========
    pc u_pc (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (1'b0),          // 单周期不需要暂停
        .branch_taken   (branch_taken),
        .branch_target  (branch_target),
        .pc             (pc),
        .pc_next        (pc_next)
    );

    // ========== 指令存储器 ==========
    imem #(
        .MEM_SIZE(8192)
    ) u_imem (
        .clk    (clk),
        .addr   (pc),
        .inst   (inst)
    );

    // ========== 指令译码器 ==========
    decoder u_decoder (
        .inst       (inst),
        .opcode     (opcode),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .funct3     (funct3),
        .funct7     (funct7),
        .imm        (imm),
        .alu_op     (alu_op),
        .alu_src    (alu_src),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_op     (mem_op),
        .branch     (branch),
        .jump       (jump),
        .wb_src     (wb_src)
    );

    // ========== 寄存器文件 ==========
    regfile u_regfile (
        .clk        (clk),
        .rst_n      (rst_n),
        .rs1_addr   (rs1),
        .rs1_data   (rs1_data),
        .rs2_addr   (rs2),
        .rs2_data   (rs2_data),
        .rd_wen     (reg_write),
        .rd_addr    (rd),
        .rd_data    (rd_data)
    );

    // ========== ALU输入选择 ==========
    // ALU_A: 对于AUIPC指令使用PC，其他使用rs1_data
    assign alu_a = (opcode == `OPCODE_AUIPC) ? pc : rs1_data;

    // ALU_B: 根据alu_src选择rs2_data或立即数
    assign alu_b = alu_src ? imm : rs2_data;

    // ========== ALU ==========
    alu u_alu (
        .a          (alu_a),
        .b          (alu_b),
        .alu_op     (alu_op),
        .result     (alu_result),
        .zero       (alu_zero)
    );

    // ========== 数据存储器 ==========
    dmem #(
        .MEM_SIZE(65536)
    ) u_dmem (
        .clk        (clk),
        .rst_n      (rst_n),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_op     (mem_op),
        .addr       (alu_result),
        .write_data (rs2_data),
        .read_data  (mem_read_data)
    );

    // ========== 写回数据选择 ==========
    assign rd_data = (wb_src == 2'b00) ? alu_result :      // ALU结果
                     (wb_src == 2'b01) ? mem_read_data :    // 内存数据
                     (wb_src == 2'b10) ? (pc + 4) :         // PC+4 (用于JAL/JALR)
                     0;

    // ========== 分支控制 ==========
    // 根据指令类型判断是否分支
    assign branch_condition = (funct3 == `FUNCT3_BEQ)  ? alu_zero :        // BEQ
                             (funct3 == `FUNCT3_BNE)  ? ~alu_zero :        // BNE
                             (funct3 == `FUNCT3_BLT)  ? alu_result[0] :    // BLT
                             (funct3 == `FUNCT3_BGE)  ? ~alu_result[0] :   // BGE
                             (funct3 == `FUNCT3_BLTU) ? alu_result[0] :    // BLTU
                             (funct3 == `FUNCT3_BGEU) ? ~alu_result[0] :   // BGEU
                             1'b0;

    assign branch_taken = jump || (branch && branch_condition);

    // 计算跳转目标
    // JAL/分支: PC + imm
    // JALR: (rs1 + imm) & ~1
    assign branch_target = (opcode == `OPCODE_JALR) ?
                          (alu_result & ~64'b1) :  // JALR: 最低位清零
                          (pc + imm);               // JAL/Branch

    // ========== 调试输出 ==========
    `ifdef DEBUG
    always @(posedge clk) begin
        if (rst_n) begin
            $display("========================================");
            $display("PC: 0x%016x", pc);
            $display("Inst: 0x%08x", inst);
            $display("Opcode: 0x%02x, rs1=%0d, rs2=%0d, rd=%0d",
                     opcode, rs1, rs2, rd);
            $display("rs1_data=0x%016x, rs2_data=0x%016x", rs1_data, rs2_data);
            $display("ALU: op=%0d, a=0x%016x, b=0x%016x, result=0x%016x",
                     alu_op, alu_a, alu_b, alu_result);
            if (reg_write)
                $display("WB: x%0d <= 0x%016x", rd, rd_data);
            if (branch_taken)
                $display("BRANCH: target=0x%016x", branch_target);
        end
    end
    `endif

endmodule
