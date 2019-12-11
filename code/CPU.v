module CPU (
    input clk_i, 
    input start_i
);

/******************** 
      registers 
********************/
/* 
1. remember to initialize the reg in testbench.
2. feel free to change the n_* from wire to reg, 
   but also remember to remove the assign below and add combinational always block below.
*/

// IF/ID
reg  [31:0] IF_ID_pc, IF_ID_instr;
reg         IF_ID_valid; // for PCSrc to flush the instuction in IF && check if start
wire [31:0] n_IF_ID_pc, n_IF_ID_instr; 
wire        n_IF_ID_valid;

// ID/EX
reg  [31:0] ID_EX_pc;
reg  [ 4:0] ID_EX_RS1_addr, ID_EX_RS2_addr, ID_EX_RD;
reg  [31:0] ID_EX_RS1_data, ID_EX_RS2_data;
reg  [11:0] ID_EX_imm;
reg  [ 1:0] ID_EX_ALUOp;
reg         ID_EX_ALUSrc, ID_EX_MemWr, ID_EX_Branch, ID_EX_MemtoReg, ID_EX_RegWr;
reg  [ 4:0] ID_EX_ALUinstr;
wire [31:0] n_ID_EX_pc;
wire [ 4:0] n_ID_EX_RS1_addr, n_ID_EX_RS2_addr, n_ID_EX_RD;
wire [31:0] n_ID_EX_RS1_data, n_ID_EX_RS2_data;
wire [11:0] n_ID_EX_imm;
wire [ 1:0] n_ID_EX_ALUOp;
wire        n_ID_EX_ALUSrc, n_ID_EX_MemWr, n_ID_EX_Branch, n_ID_EX_MemtoReg, n_ID_EX_RegWr;
wire [ 4:0] n_ID_EX_ALUinstr;

// EX/MEM
reg  [31:0] EX_MEM_pc, EX_MEM_ALUResult, EX_MEM_RS2_data;
reg  [ 4:0] EX_MEM_RD;
reg         EX_MEM_MemWr, EX_MEM_Branch, EX_MEM_MemtoReg, EX_MEM_RegWr;
wire [31:0] n_EX_MEM_pc, n_EX_MEM_ALUResult, n_EX_MEM_RS2_data;
wire [ 4:0] n_EX_MEM_RD;
wire        n_EX_MEM_MemWr, n_EX_MEM_Branch, n_EX_MEM_MemtoReg, n_EX_MEM_RegWr;

// MEM/WB
reg  [31:0] MEM_WB_MemData, MEM_WB_ALUResult;
reg  [ 4:0] MEM_WB_RD;
reg         MEM_WB_MemtoReg, MEM_WB_RegWr;
wire [31:0] n_MEM_WB_MemData, n_MEM_WB_ALUResult;
wire [ 4:0] n_MEM_WB_RD;
wire        n_MEM_WB_MemtoReg, n_MEM_WB_RegWr;

/*********************** 
      connecting wire 
************************/
// module output
wire [31:0] PC_pc;
wire [31:0] InstrMem_instr;
wire [31:0] Reg_RS1_data, Reg_RS2_data;
wire [ 1:0] Ctr_ALUOp;
wire        Ctr_ALUSrc, Ctr_MemWr, Ctr_Branch, Ctr_MemtoReg, Ctr_RegWr;
wire [11:0] ImmGen_imm;
wire [ 2:0] ALUCtr_action;
wire [31:0] ALUResult;
wire [31:0] MemData;

// pure wire
wire [31:0] IF_next_pc;

wire [4:0] ID_RS1_addr, ID_RS2_addr, ID_RD;
wire [6:0] ID_Opcode;
wire [4:0] ID_ALUCtr_instr_in;

wire [31:0] EX_imm_ext, EX_imm_ext_shift, EX_branch_pc;
wire [31:0] EX_ALU_in2;

wire MEM_PCSrc;

wire [31:0] WB_Data;

/*********************** 
      wire assignment
************************/
assign IF_next_pc = MEM_PCSrc ? EX_MEM_pc : PC_pc + 32'd4;

assign n_IF_ID_pc    = PC_pc;
assign n_IF_ID_instr = InstrMem_instr;
assign n_IF_ID_valid    = ~MEM_PCSrc & start_i;

assign ID_RS1_addr        = IF_ID_instr[19:15];
assign ID_RS2_addr        = IF_ID_instr[24:20];
assign ID_RD              = IF_ID_instr[11: 7];
assign ID_Opcode          = IF_ID_instr[6:0];
assign ID_ALUCtr_instr_in = {IF_ID_instr[30], IF_ID_instr[25], IF_ID_instr[14:12]};

assign n_ID_EX_pc       = IF_ID_pc;
assign n_ID_EX_RS1_addr = ID_RS1_addr;
assign n_ID_EX_RS2_addr = ID_RS2_addr;
assign n_ID_EX_RD       = ID_RD;
assign n_ID_EX_RS1_data = Reg_RS1_data;
assign n_ID_EX_RS2_data = Reg_RS2_data;
assign n_ID_EX_imm      = ImmGen_imm;
assign n_ID_EX_ALUOp    = Ctr_ALUOp;
assign n_ID_EX_ALUSrc   = Ctr_ALUSrc;
assign n_ID_EX_MemWr    = Ctr_MemWr  & ~MEM_PCSrc & IF_ID_valid;
assign n_ID_EX_Branch   = Ctr_Branch & ~MEM_PCSrc & IF_ID_valid;
assign n_ID_EX_MemtoReg = Ctr_MemtoReg;
assign n_ID_EX_RegWr    = Ctr_RegWr  & ~MEM_PCSrc & IF_ID_valid;
assign n_ID_EX_ALUinstr = ID_ALUCtr_instr_in;

assign EX_imm_ext       = { {20{ID_EX_imm[11]}}, ID_EX_imm};
assign EX_imm_ext_shift = {EX_imm_ext[30:0], 1'd0};
assign EX_branch_pc     = ID_EX_pc + EX_imm_ext_shift;
assign EX_ALU_in2       = ID_EX_ALUSrc ? EX_imm_ext : ID_EX_RS2_data;

assign n_EX_MEM_pc        = EX_branch_pc;
assign n_EX_MEM_ALUResult = ALUResult;
assign n_EX_MEM_RS2_data  = ID_EX_RS2_data;
assign n_EX_MEM_RD        = ID_EX_RD;
assign n_EX_MEM_MemWr     = ID_EX_MemWr  & ~MEM_PCSrc;
assign n_EX_MEM_Branch    = ID_EX_Branch & ~MEM_PCSrc;
assign n_EX_MEM_MemtoReg  = ID_EX_MemtoReg;
assign n_EX_MEM_RegWr     = ID_EX_RegWr  & ~MEM_PCSrc;

assign MEM_PCSrc = EX_MEM_Branch && (EX_MEM_ALUResult == 32'd0);

assign n_MEM_WB_MemData   = MemData;
assign n_MEM_WB_ALUResult = EX_MEM_ALUResult;
assign n_MEM_WB_RD        = EX_MEM_RD;
assign n_MEM_WB_MemtoReg  = EX_MEM_MemtoReg;
assign n_MEM_WB_RegWr     = EX_MEM_RegWr;

assign WB_Data = MEM_WB_MemtoReg ? MEM_WB_MemData : MEM_WB_ALUResult;
/*********************** 
      always block
************************/
always @(posedge clk_i) begin
    IF_ID_pc    <= n_IF_ID_pc;
    IF_ID_instr <= n_IF_ID_instr;

    ID_EX_pc       <= n_ID_EX_pc;
    ID_EX_RS1_addr <= n_ID_EX_RS1_addr;
    ID_EX_RS1_data <= n_ID_EX_RS1_data;
    ID_EX_RS2_addr <= n_ID_EX_RS2_addr;
    ID_EX_RS2_data <= n_ID_EX_RS2_data;
    ID_EX_RD       <= n_ID_EX_RD;
    ID_EX_imm      <= n_ID_EX_imm;
    ID_EX_ALUOp    <= n_ID_EX_ALUOp;
    ID_EX_ALUSrc   <= n_ID_EX_ALUSrc;
    ID_EX_MemWr    <= n_ID_EX_MemWr;
    ID_EX_Branch   <= n_ID_EX_Branch;
    ID_EX_MemtoReg <= n_ID_EX_MemtoReg;
    ID_EX_RegWr    <= n_ID_EX_RegWr;
    ID_EX_ALUinstr <= n_ID_EX_ALUinstr;
    IF_ID_valid    <= n_IF_ID_valid;

    EX_MEM_pc        <= n_EX_MEM_pc;
    EX_MEM_ALUResult <= n_EX_MEM_ALUResult;
    EX_MEM_RS2_data  <= n_EX_MEM_RS2_data;
    EX_MEM_RD        <= n_EX_MEM_RD;
    EX_MEM_MemWr     <= n_EX_MEM_MemWr;
    EX_MEM_Branch    <= n_EX_MEM_Branch;
    EX_MEM_MemtoReg  <= n_EX_MEM_MemtoReg;
    EX_MEM_RegWr     <= n_EX_MEM_RegWr;

    MEM_WB_MemData   <= n_MEM_WB_MemData;
    MEM_WB_ALUResult <= n_MEM_WB_ALUResult;
    MEM_WB_RD        <= n_MEM_WB_RD;
    MEM_WB_MemtoReg  <= n_MEM_WB_MemtoReg;
    MEM_WB_RegWr     <= n_MEM_WB_RegWr;
end

/*********************** 
      submodule
************************/
PC PC(
    .clk_i          (clk_i),
    .rst_i          (1'b1), // reset in testbench
    .start_i        (start_i),
    .PCWrite_i      (1'b1), // set 0 for stall
    .pc_i           (IF_next_pc),
    .pc_o           (PC_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i         (PC_pc),
    .instr_o        (InstrMem_instr)
);

Registers Registers(
    .clk_i          (clk_i),
    .RS1addr_i      (ID_RS1_addr),
    .RS2addr_i      (ID_RS2_addr),
    .RDaddr_i       (MEM_WB_RD),
    .RDdata_i       (WB_Data),
    .RegWrite_i     (MEM_WB_RegWr),
    .RS1data_o      (Reg_RS1_data),
    .RS2data_o      (Reg_RS2_data)
);

Control Control(
    .opcode_i (ID_Opcode),
    .ALUSrc_o (Ctr_ALUSrc),
    .ALUOp_o (Ctr_ALUOp),
    .MemWr_o (Ctr_MemWr),
    .Branch_o (Ctr_Branch),
    .MemtoReg_o (Ctr_MemtoReg),
    .RegWr_o (Ctr_RegWr)

);

ImmGen ImmGem(
    .instr_i(IF_ID_instr),
    .imm_o  (ImmGen_imm)
);

ALUControl ALUControl(
    .op_i(ID_EX_ALUOp),
    .instr_i(ID_EX_ALUinstr),
    .action_o(ALUCtr_action)
);

ALU ALU(
    .data1_i(ID_EX_RS1_data),
    .data2_i(EX_ALU_in2),
    .action_i(ALUCtr_action),
    .result_o(ALUResult)
);

Data_Memory Data_Memory(
    .clk_i          (clk_i),
    .addr_i         (EX_MEM_ALUResult),
    .MemWrite_i     (EX_MEM_MemWr),
    .data_i         (EX_MEM_RS2_data),
    .data_o         (MemData)
);

endmodule