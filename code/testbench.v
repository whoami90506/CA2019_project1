`define CYCLE_TIME 50            

module TestBench;

reg                Clk;
reg                Start;
integer            i, outfile, counter;
integer            stall, flush;

always #(`CYCLE_TIME/2) Clk = ~Clk;    

CPU CPU(
    .clk_i  (Clk),
    .start_i(Start)
);
  
initial begin
    counter = 0;
    stall = 0;
    flush = 0;
    
    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end
    
    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 8'b0;
    end    
        
    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end

    // initialize PC By Cheng-De Lin
    CPU.PC.pc_o = 32'b0;

    // TODO: initialize pipeline registers
    CPU.IF_ID_pc=0;
    CPU.IF_ID_instr=0;
    CPU.IF_ID_valid=0;

    CPU.ID_EX_pc=0;
    CPU.ID_EX_RS1_addr=0;
    CPU.ID_EX_RS1_data=0;
    CPU.ID_EX_RS2_addr=0;
    CPU.ID_EX_RS2_data=0;
    CPU.ID_EX_RD=0;
    CPU.ID_EX_imm=0;
    CPU.ID_EX_ALUOp=0;
    CPU.ID_EX_ALUSrc=0;
    CPU.ID_EX_MemWr=0;
    CPU.ID_EX_MemtoReg=0;
    CPU.ID_EX_RegWr=0;
    CPU.ID_EX_ALUinstr=0;
    
    CPU.EX_MEM_ALUResult=0;
    CPU.EX_MEM_RS2_data=0;
    CPU.EX_MEM_RD=0;
    CPU.EX_MEM_MemWr=0;
    CPU.EX_MEM_MemtoReg=0;
    CPU.EX_MEM_RegWr=0;
    
    CPU.MEM_WB_MemData=0;
    CPU.MEM_WB_ALUResult=0;
    CPU.MEM_WB_RD=0;
    CPU.MEM_WB_MemtoReg=0;
    CPU.MEM_WB_RegWr=0;

    //dumpvcd by Cheng-De Lin
    $dumpfile("CPU.vcd");
    $dumpvars;
    
    // Load instructions into instruction memory
    $readmemb("../testdata/instruction.txt", CPU.Instruction_Memory.memory);
    // $readmemb("../testdata/Fibonacci_instruction.txt", CPU.Instruction_Memory.memory);
    
    // Open output file
    outfile = $fopen("../testdata/output.txt") | 1;
    
    // Set Input n into data memory at 0x00
    CPU.Data_Memory.memory[0] = 8'h5;       // n = 5 for example
    
    //****************************************************
    // change initial clk from 1 to 0 by Cheng-De Lin
    //**************************************************** 
    Clk = 0;
    //Reset = 0;
    Start = 0;
    
    #(`CYCLE_TIME/4) 
    //Reset = 1;
    Start = 1;
        
    
end
  
always@(posedge Clk) begin
    // TODO: change # of cycles as you need
    if(counter == 64)    // stop after 30 cycles
        $finish;

    // TODO: put in your own signal to count stall and flush
    // if(CPU.HazardDetection.Stall_o == 1 && CPU.Control.Branch_o == 0)stall = stall + 1;
    if(CPU.ID_PCSrc == 1)flush = flush + 1;  
    if(CPU.stall == 1)stall = stall + 1;
   

    // print PC
    $fdisplay(outfile, "cycle = %d, Start = %d, Stall = %0d, Flush = %0d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);
    
    // print Registers
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0 = %d, x8  = %d, x16 = %d, x24 = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "x1 = %d, x9  = %d, x17 = %d, x25 = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "x2 = %d, x10 = %d, x18 = %d, x26 = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "x3 = %d, x11 = %d, x19 = %d, x27 = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "x4 = %d, x12 = %d, x20 = %d, x28 = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "x5 = %d, x13 = %d, x21 = %d, x29 = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "x6 = %d, x14 = %d, x22 = %d, x30 = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "x7 = %d, x15 = %d, x23 = %d, x31 = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    $fdisplay(outfile, "Data Memory: 0x00 = %10d", {CPU.Data_Memory.memory[3] , CPU.Data_Memory.memory[2] , CPU.Data_Memory.memory[1] , CPU.Data_Memory.memory[0] });
    $fdisplay(outfile, "Data Memory: 0x04 = %10d", {CPU.Data_Memory.memory[7] , CPU.Data_Memory.memory[6] , CPU.Data_Memory.memory[5] , CPU.Data_Memory.memory[4] });
    $fdisplay(outfile, "Data Memory: 0x08 = %10d", {CPU.Data_Memory.memory[11], CPU.Data_Memory.memory[10], CPU.Data_Memory.memory[9] , CPU.Data_Memory.memory[8] });
    $fdisplay(outfile, "Data Memory: 0x0c = %10d", {CPU.Data_Memory.memory[15], CPU.Data_Memory.memory[14], CPU.Data_Memory.memory[13], CPU.Data_Memory.memory[12]});
    $fdisplay(outfile, "Data Memory: 0x10 = %10d", {CPU.Data_Memory.memory[19], CPU.Data_Memory.memory[18], CPU.Data_Memory.memory[17], CPU.Data_Memory.memory[16]});
    $fdisplay(outfile, "Data Memory: 0x14 = %10d", {CPU.Data_Memory.memory[23], CPU.Data_Memory.memory[22], CPU.Data_Memory.memory[21], CPU.Data_Memory.memory[20]});
    $fdisplay(outfile, "Data Memory: 0x18 = %10d", {CPU.Data_Memory.memory[27], CPU.Data_Memory.memory[26], CPU.Data_Memory.memory[25], CPU.Data_Memory.memory[24]});
    $fdisplay(outfile, "Data Memory: 0x1c = %10d", {CPU.Data_Memory.memory[31], CPU.Data_Memory.memory[30], CPU.Data_Memory.memory[29], CPU.Data_Memory.memory[28]});
	
    $fdisplay(outfile, "\n");
    
    counter = counter + 1;
    
      
end

  
endmodule
