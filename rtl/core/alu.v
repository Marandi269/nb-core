// 简化的ALU - 仅RV64I基础指令（无M扩展）
`include "defines.v"

module alu (
    input  wire [`XLEN-1:0]        a,
    input  wire [`XLEN-1:0]        b,
    input  wire [`ALU_OP_WIDTH-1:0] alu_op,
    output reg  [`XLEN-1:0]        result,
    output wire                     zero
);

    assign zero = (result == 0);

    always @(*) begin
        case (alu_op)
            `ALU_ADD:   result = a + b;
            `ALU_SUB:   result = a - b;
            `ALU_SLL:   result = a << b[5:0];
            `ALU_SLT:   result = ($signed(a) < $signed(b)) ? 1 : 0;
            `ALU_SLTU:  result = (a < b) ? 1 : 0;
            `ALU_XOR:   result = a ^ b;
            `ALU_SRL:   result = a >> b[5:0];
            `ALU_SRA:   result = $signed(a) >>> b[5:0];
            `ALU_OR:    result = a | b;
            `ALU_AND:   result = a & b;
            // M扩展暂时不支持，返回0
            default:    result = 0;
        endcase
    end

endmodule
