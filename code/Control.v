module Control(
    input        start_i,
    input  [6:0] opcode_i,
    output       ALUSrc_o,
    output [1:0] ALUOp_o,
    output       MemWr_o,
    output       Branch_o,
    output       MemtoReg_o,
    output       RegWr_o
);
    assign ALUSrc_o   = ~opcode_i[6] & (~opcode_i[5] | ~opcode_i[4]);          // sd, ld, addi
    assign ALUOp_o    = {opcode_i[4], opcode_i[6] || opcode_i[5:4] == 2'b01};  // R-format:10, addi:11, ld/sd:00, beq:01
    assign MemWr_o    = opcode_i[6:4] == 3'b010 && start_i;                    // sd
    assign Branch_o   = opcode_i[6] & start_i;                                 // beq
    assign MemtoReg_o = opcode_i[5:4] == 2'b00;                                // ld
    assign RegWr_o    = (opcode_i[4] | ~opcode_i[5]) & start_i;                // R-format, addi, ld
endmodule