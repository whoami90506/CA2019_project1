module Forward
(
  rs_1,
  rs_2,
  EM_rd,
  MW_rd,
  EM_regw,
  MW_regw,
  forward_A,
  forward_B  
);

input  [4:0]  rs_1, rs_2, EM_rd, MW_rd;
input         EM_regw, MW_regw;
output [1:0]  forward_A, forward_B;  
reg    [1:0]  forward_A, forward_B;

always @(*) begin 
// forwardA
if (EM_regw && (EM_rd != 0) && (EM_rd == rs_1)) 
    forward_A = 2'b10;
else if (MW_regw && (MW_rd != 0) && (MW_rd == rs_1) && !(EM_regw && (EM_rd != 0) 
                 && (EM_rd == rs_1)))
    forward_A = 2'b01;
else 
    forward_A = 2'b00;


// forwardB
if (EM_regw && (EM_rd != 0) && (EM_rd == rs_2))
    forward_B = 2'b10;
else if (MW_regw && (MW_rd != 0) && (MW_rd == rs_2) && !(EM_regw && (EM_rd != 0) 
                 && (EM_rd == rs_2)))
    forward_B = 2'b01;
else
    forward_B = 2'b00;
end

endmodule



