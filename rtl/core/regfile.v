// RISC-V 寄存器文件
// 32个64位通用寄存器，x0硬连线为0
// 支持2读1写端口

`include "defines.v"

module regfile (
    input  wire                         clk,
    input  wire                         rst_n,

    // 读端口1
    input  wire [`REG_ADDR_WIDTH-1:0]  rs1_addr,
    output reg  [`XLEN-1:0]            rs1_data,

    // 读端口2
    input  wire [`REG_ADDR_WIDTH-1:0]  rs2_addr,
    output reg  [`XLEN-1:0]            rs2_data,

    // 写端口
    input  wire                         rd_wen,      // 写使能
    input  wire [`REG_ADDR_WIDTH-1:0]  rd_addr,     // 目标寄存器
    input  wire [`XLEN-1:0]            rd_data      // 写入数据
);

    // 32个64位寄存器
    reg [`XLEN-1:0] regs [0:31] /* verilator public */;

    // 读操作 (组合逻辑)
    always @(*) begin
        // x0恒为0
        if (rs1_addr == 5'd0)
            rs1_data = 0;
        else
            rs1_data = regs[rs1_addr];
    end

    always @(*) begin
        if (rs2_addr == 5'd0)
            rs2_data = 0;
        else
            rs2_data = regs[rs2_addr];
    end

    // 写操作 (时序逻辑)
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 复位：清零所有寄存器
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= 0;
            end
        end else begin
            // x0不可写，其他寄存器在写使能时写入
            if (rd_wen && rd_addr != 5'd0) begin
                regs[rd_addr] <= rd_data;
            end
        end
    end

    // 调试：监控寄存器值（仿真时使用）
    `ifdef DEBUG
    always @(posedge clk) begin
        if (rd_wen && rd_addr != 0) begin
            $display("[REGFILE] x%0d <= 0x%016x", rd_addr, rd_data);
        end
    end
    `endif

endmodule
