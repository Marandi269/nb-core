// RISC-V RV64IMA ALU (算术逻辑单元)
// 支持基础运算、移位、比较、乘除法

`include "defines.v"

module alu (
    input  wire [`XLEN-1:0]        a,          // 操作数A
    input  wire [`XLEN-1:0]        b,          // 操作数B
    input  wire [`ALU_OP_WIDTH-1:0] alu_op,    // ALU操作码
    output reg  [`XLEN-1:0]        result,     // 运算结果
    output wire                     zero        // 结果为0标志
);

    // 零标志
    assign zero = (result == 0);

    // 64位乘法的128位结果
    wire signed [`XLEN*2-1:0] mul_result_signed;
    wire [`XLEN*2-1:0] mul_result_unsigned;
    wire signed [`XLEN*2-1:0] mul_result_su;  // signed x unsigned

    assign mul_result_signed = $signed(a) * $signed(b);
    assign mul_result_unsigned = a * b;
    assign mul_result_su = $signed(a) * $signed({1'b0, b});

    // ALU主逻辑
    always @(*) begin
        case (alu_op)
            `ALU_ADD:   result = a + b;
            `ALU_SUB:   result = a - b;
            `ALU_SLL:   result = a << b[5:0];  // 只使用低6位作为移位量 (RV64)
            `ALU_SLT:   result = ($signed(a) < $signed(b)) ? 1 : 0;
            `ALU_SLTU:  result = (a < b) ? 1 : 0;
            `ALU_XOR:   result = a ^ b;
            `ALU_SRL:   result = a >> b[5:0];
            `ALU_SRA:   result = $signed(a) >>> b[5:0];
            `ALU_OR:    result = a | b;
            `ALU_AND:   result = a & b;

            // M扩展 - 乘法（简化实现，直接使用*运算符）
            `ALU_MUL:   result = mul_result_signed[`XLEN-1:0];  // 低64位
            `ALU_MULH:  result = mul_result_signed[`XLEN*2-1:`XLEN]; // 高64位
            `ALU_MULHSU: result = mul_result_su[`XLEN*2-1:`XLEN];
            `ALU_MULHU: result = mul_result_unsigned[`XLEN*2-1:`XLEN];

            // M扩展 - 除法（简化实现）
            // 注意：实际硬件中需要多周期除法器
            `ALU_DIV:   result = (b == 0) ? {`XLEN{1'b1}} :
                                 (a == {1'b1, {(`XLEN-1){1'b0}}} && b == {`XLEN{1'b1}}) ? a :
                                 $signed(a) / $signed(b);
            `ALU_DIVU:  result = (b == 0) ? {`XLEN{1'b1}} : a / b;
            `ALU_REM:   result = (b == 0) ? a :
                                 (a == {1'b1, {(`XLEN-1){1'b0}}} && b == {`XLEN{1'b1}}) ? 0 :
                                 $signed(a) % $signed(b);
            `ALU_REMU:  result = (b == 0) ? a : a % b;

            default:    result = 0;
        endcase
    end

endmodule
