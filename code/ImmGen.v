module ImmGen(
    input [31:0] instr_i,
    output reg [11:0] imm_o
);
    always @(*) begin
        case (instr_i[6:5])
            2'b00   : imm_o = instr_i[31 -:12];                                         // addi, lw
            2'b01   : imm_o = {instr_i[31:25], instr_i[11:7]};                          // sw
            2'b11   : imm_o = {instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8]}; // beq
            default : imm_o = 12'b0;                                                    // none
        endcase
    end
endmodule // ImmGen