module ALUControl (
    input [1:0] op_i,
    input [4:0] instr_i,
    output reg [2:0] action_o
);
    /*
        action_o
        3'b000 : AND
        3'b001 : OR
        3'b010 : ADD
        3'b011 : SUB
        3'b100 : MUL
    */
    always @(*) begin
        case(op_i)
            2'b01 : action_o = 3'b011; // beq
            2'b10 : begin // R-format
                if(instr_i[3])action_o = 3'b100; // mul
                else if (instr_i[4])action_o = 3'b011; // sub
                else if (instr_i[0])action_o = 3'b000; // and
                else if (instr_i[1])action_o = 3'b001; // or
                else action_o = 3'b010; // add
            end

            default: action_o = 3'b010; // ld, sd, addi
        endcase
    end
endmodule