module ALU (
    input      [31:0] data1_i, data2_i,
    input      [ 2:0] action_i,
    output reg [31:0] result_o
);
    /*
        action_i
        3'b000 : AND
        3'b001 : OR
        3'b010 : ADD
        3'b011 : SUB
        3'b100 : MUL
    */

    always @(*) begin
        case(action_i)
            3'b000 : result_o = data1_i & data2_i;
            3'b001 : result_o = data1_i | data2_i;
            3'b010 : result_o = data1_i + data2_i;
            3'b011 : result_o = data1_i - data2_i;
            3'b100 : result_o = data1_i * data2_i;
            default: result_o = 32'hffffffff; // never touch
        endcase
    end
endmodule