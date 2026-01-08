// 寄存器文件测试平台

`include "rtl/core/defines.v"

`timescale 1ns / 1ps

module regfile_tb;

    reg clk;
    reg rst_n;
    reg [`REG_ADDR_WIDTH-1:0] rs1_addr, rs2_addr, rd_addr;
    reg rd_wen;
    reg [`XLEN-1:0] rd_data;
    wire [`XLEN-1:0] rs1_data, rs2_data;
    integer i;

    // 实例化寄存器文件
    regfile uut (
        .clk(clk),
        .rst_n(rst_n),
        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data),
        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data),
        .rd_wen(rd_wen),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    // 时钟生成
    always #5 clk = ~clk;

    initial begin
        $display("========== Register File Testbench ==========");

        // 初始化
        clk = 0;
        rst_n = 0;
        rd_wen = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr = 0;
        rd_data = 0;

        // 复位
        #10 rst_n = 1;
        #10;

        // 测试1: 写入x1寄存器
        $display("[TEST] Writing to x1");
        rd_addr = 5'd1;
        rd_data = 64'hDEAD_BEEF_CAFE_BABE;
        rd_wen = 1;
        #10;
        rd_wen = 0;

        // 读取x1
        #10;
        rs1_addr = 5'd1;
        #10;
        if (rs1_data === 64'hDEAD_BEEF_CAFE_BABE)
            $display("[PASS] x1 = 0x%016x", rs1_data);
        else
            $display("[FAIL] x1 = 0x%016x (expected 0xDEADBEEFCAFEBABE)", rs1_data);

        // 测试2: x0恒为0
        $display("[TEST] x0 should always be 0");
        rd_addr = 5'd0;
        rd_data = 64'hFFFF_FFFF_FFFF_FFFF;
        rd_wen = 1;
        #10;
        rd_wen = 0;
        #10;
        rs1_addr = 5'd0;
        #10;
        if (rs1_data === 64'd0)
            $display("[PASS] x0 = 0 (immutable)");
        else
            $display("[FAIL] x0 = 0x%016x (should be 0)", rs1_data);

        // 测试3: 同时读取两个寄存器
        $display("[TEST] Dual read ports");
        rd_addr = 5'd2;
        rd_data = 64'h1111_1111_1111_1111;
        rd_wen = 1;
        #10;
        rd_addr = 5'd3;
        rd_data = 64'h2222_2222_2222_2222;
        #10;
        rd_wen = 0;
        #10;

        rs1_addr = 5'd2;
        rs2_addr = 5'd3;
        #10;
        if (rs1_data === 64'h1111_1111_1111_1111 &&
            rs2_data === 64'h2222_2222_2222_2222)
            $display("[PASS] Dual read: x2=0x%016x, x3=0x%016x", rs1_data, rs2_data);
        else
            $display("[FAIL] Dual read failed");

        // 测试4: 写入所有寄存器
        $display("[TEST] Writing all registers");
        for (i = 1; i < 32; i = i + 1) begin
            rd_addr = i;
            rd_data = i * 64'h0101_0101_0101_0101;
            rd_wen = 1;
            #10;
        end
        rd_wen = 0;
        #10;

        // 验证所有寄存器
        for (i = 1; i < 32; i = i + 1) begin
            rs1_addr = i;
            #10;
            if (rs1_data === i * 64'h0101_0101_0101_0101)
                $display("[PASS] x%0d = 0x%016x", i, rs1_data);
            else
                $display("[FAIL] x%0d = 0x%016x", i, rs1_data);
        end

        $display("========== Register File Test Complete ==========");
        $finish;
    end

endmodule
