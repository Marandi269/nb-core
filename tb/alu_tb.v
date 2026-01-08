// ALU测试平台

`include "rtl/core/defines.v"

`timescale 1ns / 1ps

module alu_tb;

    reg [`XLEN-1:0] a, b;
    reg [`ALU_OP_WIDTH-1:0] alu_op;
    wire [`XLEN-1:0] result;
    wire zero;

    // 实例化ALU
    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    // 测试任务
    task test_alu;
        input [`XLEN-1:0] test_a;
        input [`XLEN-1:0] test_b;
        input [`ALU_OP_WIDTH-1:0] op;
        input [`XLEN-1:0] expected;
        input [256*8-1:0] op_name;
        begin
            a = test_a;
            b = test_b;
            alu_op = op;
            #10;
            if (result === expected) begin
                $display("[PASS] %s: 0x%016x %s 0x%016x = 0x%016x",
                         op_name, test_a, op_name, test_b, result);
            end else begin
                $display("[FAIL] %s: 0x%016x %s 0x%016x = 0x%016x (expected 0x%016x)",
                         op_name, test_a, op_name, test_b, result, expected);
            end
        end
    endtask

    initial begin
        $display("========== ALU Testbench ==========");

        // 测试加法
        test_alu(64'd10, 64'd20, `ALU_ADD, 64'd30, "ADD");
        test_alu(64'hFFFF_FFFF_FFFF_FFFF, 64'd1, `ALU_ADD, 64'd0, "ADD");

        // 测试减法
        test_alu(64'd30, 64'd10, `ALU_SUB, 64'd20, "SUB");
        test_alu(64'd0, 64'd1, `ALU_SUB, 64'hFFFF_FFFF_FFFF_FFFF, "SUB");

        // 测试逻辑运算
        test_alu(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555,
                 `ALU_AND, 64'd0, "AND");
        test_alu(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555,
                 `ALU_OR, 64'hFFFF_FFFF_FFFF_FFFF, "OR");
        test_alu(64'hAAAA_AAAA_AAAA_AAAA, 64'h5555_5555_5555_5555,
                 `ALU_XOR, 64'hFFFF_FFFF_FFFF_FFFF, "XOR");

        // 测试移位
        test_alu(64'h0000_0000_0000_0001, 64'd4, `ALU_SLL, 64'h0000_0000_0000_0010, "SLL");
        test_alu(64'h8000_0000_0000_0000, 64'd4, `ALU_SRL, 64'h0800_0000_0000_0000, "SRL");
        test_alu(64'h8000_0000_0000_0000, 64'd4, `ALU_SRA, 64'hF800_0000_0000_0000, "SRA");

        // 测试比较
        test_alu(-64'sd10, 64'sd5, `ALU_SLT, 64'd1, "SLT");
        test_alu(64'd5, -64'sd10, `ALU_SLT, 64'd0, "SLT");
        test_alu(64'd5, 64'd10, `ALU_SLTU, 64'd1, "SLTU");
        test_alu(64'hFFFF_FFFF_FFFF_FFFF, 64'd10, `ALU_SLTU, 64'd0, "SLTU");

        // 测试乘法
        test_alu(64'd10, 64'd20, `ALU_MUL, 64'd200, "MUL");
        test_alu(-64'sd10, 64'sd20, `ALU_MUL, -64'sd200, "MUL");

        // 测试除法
        test_alu(64'd100, 64'd10, `ALU_DIV, 64'd10, "DIV");
        test_alu(-64'sd100, 64'sd10, `ALU_DIV, -64'sd10, "DIV");
        test_alu(64'd100, 64'd10, `ALU_DIVU, 64'd10, "DIVU");

        // 测试取模
        test_alu(64'd107, 64'd10, `ALU_REM, 64'd7, "REM");
        test_alu(64'd107, 64'd10, `ALU_REMU, 64'd7, "REMU");

        // 测试零标志
        a = 64'd0;
        b = 64'd0;
        alu_op = `ALU_ADD;
        #10;
        if (zero)
            $display("[PASS] Zero flag works correctly");
        else
            $display("[FAIL] Zero flag should be 1");

        $display("========== ALU Test Complete ==========");
        $finish;
    end

endmodule
