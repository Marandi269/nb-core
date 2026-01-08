// 指令存储器 (Instruction Memory)
// 简化版本，使用Block RAM实现
// 实际应用中可能需要连接外部DDR或Flash

`include "defines.v"

module imem #(
    parameter MEM_SIZE = 256  // 256B指令存储器（仿真测试用）
)(
    input  wire                clk,
    input  wire [`XLEN-1:0]   addr,      // 地址
    output reg  [`ILEN-1:0]   inst       // 读出的指令
);

    // 计算需要的地址位宽
    localparam ADDR_WIDTH = $clog2(MEM_SIZE/4);  // 以字(4字节)为单位

    // 存储器数组
    reg [31:0] mem [0:MEM_SIZE/4-1];
    integer i;

    // 地址对齐到4字节边界，并截取有效位
    wire [ADDR_WIDTH-1:0] word_addr;
    assign word_addr = addr[ADDR_WIDTH+1:2];

    // 同步读取
    always @(posedge clk) begin
        inst <= mem[word_addr];
    end

    // 初始化（用于测试）- 注释掉加快编译
    // initial begin
    //     // 可以从文件加载程序
    //     // $readmemh("program.hex", mem);
    //
    //     // 或者默认填充NOP (ADDI x0, x0, 0)
    //     for (i = 0; i < MEM_SIZE/4; i = i + 1) begin
    //         mem[i] = 32'h00000013;  // NOP
    //     end
    // end

    // 支持外部加载程序（用于testbench）
    task load_program;
        input [1024*8-1:0] filename;
        begin
            $readmemh(filename, mem);
            $display("[IMEM] Loaded program from %s", filename);
        end
    endtask

endmodule
