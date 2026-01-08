// 程序计数器 (Program Counter)
// 管理指令地址的顺序执行和跳转

`include "defines.v"

module pc (
    input  wire                clk,
    input  wire                rst_n,

    input  wire                stall,        // 暂停信号
    input  wire                branch_taken, // 分支跳转
    input  wire [`XLEN-1:0]   branch_target,// 跳转目标地址

    output reg  [`XLEN-1:0]   pc,           // 当前PC
    output wire [`XLEN-1:0]   pc_next       // 下一个PC
);

    // PC初始值（通常是程序入口地址）
    parameter PC_INIT = 64'h8000_0000;

    // 计算下一个PC
    assign pc_next = branch_taken ? branch_target : (pc + 4);

    // PC更新
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= PC_INIT;
        end else if (!stall) begin
            pc <= pc_next;
        end
        // 如果stall=1，PC保持不变
    end

    `ifdef DEBUG
    always @(posedge clk) begin
        if (!stall && rst_n) begin
            $display("[PC] PC: 0x%016x -> 0x%016x (branch=%b)",
                     pc, pc_next, branch_taken);
        end
    end
    `endif

endmodule
