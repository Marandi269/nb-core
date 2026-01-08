// 数据存储器 (Data Memory)
// 支持字节、半字、字、双字的加载和存储
// 使用Block RAM实现

`include "defines.v"

module dmem #(
    parameter MEM_SIZE = 256  // 256B数据存储器（仿真测试用）
)(
    input  wire                clk,
    input  wire                rst_n,

    // 读写控制
    input  wire                mem_read,
    input  wire                mem_write,
    input  wire [2:0]          mem_op,     // 内存操作类型

    // 地址和数据
    input  wire [`XLEN-1:0]   addr,
    input  wire [`XLEN-1:0]   write_data,
    output reg  [`XLEN-1:0]   read_data
);

    localparam ADDR_WIDTH = $clog2(MEM_SIZE);

    // 字节存储器
    reg [7:0] mem [0:MEM_SIZE-1];

    wire [ADDR_WIDTH-1:0] byte_addr;
    assign byte_addr = addr[ADDR_WIDTH-1:0];

    // 读操作
    always @(*) begin
        if (mem_read) begin
            case (mem_op)
                `MEM_LB:  // Load Byte (符号扩展)
                    read_data = {{56{mem[byte_addr][7]}}, mem[byte_addr]};

                `MEM_LH:  // Load Half (符号扩展)
                    read_data = {{48{mem[byte_addr+1][7]}},
                                 mem[byte_addr+1], mem[byte_addr]};

                `MEM_LW:  // Load Word (符号扩展)
                    read_data = {{32{mem[byte_addr+3][7]}},
                                 mem[byte_addr+3], mem[byte_addr+2],
                                 mem[byte_addr+1], mem[byte_addr]};

                `MEM_LD:  // Load Double
                    read_data = {mem[byte_addr+7], mem[byte_addr+6],
                                 mem[byte_addr+5], mem[byte_addr+4],
                                 mem[byte_addr+3], mem[byte_addr+2],
                                 mem[byte_addr+1], mem[byte_addr]};

                default:
                    read_data = 0;
            endcase
        end else begin
            read_data = 0;
        end
    end

    // 写操作
    always @(posedge clk) begin
        if (mem_write) begin
            case (mem_op)
                `MEM_SB:  // Store Byte
                    mem[byte_addr] <= write_data[7:0];

                `MEM_SH:  // Store Half
                    begin
                        mem[byte_addr]   <= write_data[7:0];
                        mem[byte_addr+1] <= write_data[15:8];
                    end

                `MEM_SW:  // Store Word
                    begin
                        mem[byte_addr]   <= write_data[7:0];
                        mem[byte_addr+1] <= write_data[15:8];
                        mem[byte_addr+2] <= write_data[23:16];
                        mem[byte_addr+3] <= write_data[31:24];
                    end

                `MEM_LD:  // Store Double (using LD encoding for SD)
                    begin
                        mem[byte_addr]   <= write_data[7:0];
                        mem[byte_addr+1] <= write_data[15:8];
                        mem[byte_addr+2] <= write_data[23:16];
                        mem[byte_addr+3] <= write_data[31:24];
                        mem[byte_addr+4] <= write_data[39:32];
                        mem[byte_addr+5] <= write_data[47:40];
                        mem[byte_addr+6] <= write_data[55:48];
                        mem[byte_addr+7] <= write_data[63:56];
                    end
            endcase
        end
    end

    // 初始化 - 注释掉加快编译
    // integer i;
    // initial begin
    //     for (i = 0; i < MEM_SIZE; i = i + 1) begin
    //         mem[i] = 8'h00;
    //     end
    // end

    `ifdef DEBUG
    always @(posedge clk) begin
        if (mem_write) begin
            $display("[DMEM] Write: addr=0x%016x, data=0x%016x, op=%0d",
                     addr, write_data, mem_op);
        end
        if (mem_read) begin
            $display("[DMEM] Read: addr=0x%016x, data=0x%016x, op=%0d",
                     addr, read_data, mem_op);
        end
    end
    `endif

endmodule
