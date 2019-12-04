module HazardDetection(
    input [4:0] Rd,
    input MemRead,
    input RegWrite,
    input [4:0] rs1,
    input [4:0] rs2,
    output stall_o
);
reg stall;
assign stall_o = stall;
    
    always @(*) begin
        if (MemRead && Rd!=0 && RegWrite)begin
            if (Rd==rs1 || Rd==rs2)
                stall = 1'b1;
            else
                stall = 1'b0;
        end
        else
            stall = 1'b0;
    end
endmodule 