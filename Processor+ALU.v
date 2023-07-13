// Shourya Trikha (210994)
// Prashant Kumar (210750)

module pro_alu(clk);
 
input clk;

reg [31:0] PC; //programme counter
reg [31:0] IR;//fetched Instruction 
reg [31:0] A; //source register 1(IR[25:21])-->used in 32 bits
reg [31:0] B; //source register 2(IR[20:16])-->used in 32 bits
reg [31:0] Imm; //Immediate value(IR[15:0])--->used in 32 bits

//instructions are divided into 'type' classes:
// RR_ALU(Register to register operation)
// RM_ALU(register to memory operation)
// LOAD, STORE, BRANCH, HALT
reg [2:0] type; 

reg [31:0] ALUOut; //output by ALU for each instruction
reg cond; //'condition check' for 'BRANCH' type instruction
reg [31:0] LMD; //loading memory data for 'LOAD' type instructions
reg [31:0] Reg [0:31]; // Register bank (32 x 32)
reg [31:0] Mem [0:511]; // Memory 512 x 32 
  


  //defining parameters for opcodes of instructions
  parameter ADD=6'b000000,
            SUB=6'b000001,
            AND=6'b000010,
            OR=6'b000011,
            SLT=6'b000100,
            MUL=6'b000101,
            HLT=6'b111111,
            LW=6'b001000,
            SW=6'b001001,
            ADDI=6'b001010,
            SUBI=6'b001011,
            SLTI=6'b001100,
            BNE=6'b001101,
            BEQ=6'b001110;

//defining parameters for 'types' 
parameter RR_ALU=3'b000,
          RM_ALU=3'b001,
          LOAD=3'b010,
          STORE=3'b011,
          BRANCH=3'b100,
          HALT=3'b101;

reg HALTED;       
reg TAKEN_BRANCH;

integer k;

//registers instantiation
initial
begin
for (k=0; k<32; k++)
Reg[k] = k;
end

//input store
initial
begin
  
  Mem[40] <= 32'd5;
  Mem[41] <= 32'd40;
  Mem[42] <= 32'd30;
  Mem[43] <= 32'd35;
  Mem[44] <= 32'd55;
  Mem[45] <= 32'd12;
  Mem[46] <= 32'd60;
  Mem[47] <= 32'd43;
  Mem[48] <= 32'd33;
  Mem[49] <= 32'd100;

end

//instruction store
initial
begin

Mem[0] <= 32'b00101000000000010000000000101000; // ADDI r1,r0,40 //initial address 1111110110
Mem[1] <= 32'b00101000000000100000000000000000; // ADDI r2,r0,0 //counter for loop 1
Mem[2] <= 32'b00101000000000110000000000001001; // ADDI r3,r0,9 //no. of inputs
Mem[3] <= 32'b00101000000001000000000000000000; // ADDI r4,r0,0 //counter for loop 2
Mem[4] <= 32'b00000000001001000010100000000000; //ADD r5 ,r1, r4// LOOP COUNTER VARIAB
Mem[5] <= 32'b00100000101001100000000000000000; // LW R6,0(R5)
Mem[6] <= 32'b00100000101001110000000000000001; // LW R7,1(R5)
Mem[7] <= 32'b00010000110001110100000000000000; // slt r8,r6,r7
Mem[8] <= 32'b00110101000000000000000000000011; //bne r8,r0,3
Mem[9] <= 32'b00100100101001110000000000000000; //sw r7, 0(r5)
Mem[10] <= 32'b00100100101001100000000000000001; //sw r6,1(r5)
Mem[11] <= 32'b00101000100001000000000000000001; //addi r4, r4,1
Mem[12] <= 32'b00000100011000100100100000000000; //sub r9,r3,r2
Mem[13] <= 32'b00110100100010011111111111110111; //bne r4,r9,-9
Mem[14] <= 32'b00101000010000100000000000000001; //addi r2,r2,1
Mem[15] <= 32'b00101000000001000000000000000000; //addi r4,r0,0
Mem[16] <= 32'b00110100010000111111111111110100; //bne r2,r3 -12

HALTED = 0;
PC = 0;
TAKEN_BRANCH = 0;

end

always @(posedge clk) 
begin
    
if(HALTED==0)
begin


#2
TAKEN_BRANCH = #2 0;

//fetching instruction
IR = #2 Mem[PC];

//assigning values to A,B and Imm
A = #2 Reg[IR[25:21]];
B = #2 Reg[IR[20:16]];
Imm = #2 {{16{IR[15]}}, {IR[15:0]}};


//giving a 'type' to instruction
case (IR[31:26])
ADD,SUB,AND,OR,SLT,MUL: type = #2 RR_ALU;
ADDI,SUBI,SLTI: type = #2 RM_ALU;
LW: type = #2 LOAD;
SW: type = #2 STORE;
BNE,BEQ: type = #2 BRANCH;
HLT: type = #2 HALT;
endcase

//ALU 
case (type)
RR_ALU: //register to register AL operations
begin
case (IR[31:26])
ADD: ALUOut = #2 A + B;
SUB: ALUOut = #2 A - B;
AND: ALUOut = #2 A & B;
OR: ALUOut = #2 A | B;
SLT: ALUOut = #2 A < B;
MUL: ALUOut = #2 A * B;
endcase
end

RM_ALU: //register to memory AL operations
begin
case (IR[31:26]) // "opcode"
ADDI: ALUOut = #2 A + $signed(Imm);
SUBI: ALUOut = #2 A - $signed(Imm);
SLTI: ALUOut = #2 A < $signed(Imm);
endcase
end

LOAD, STORE: ALUOut = #2 A + $signed(Imm);

BRANCH: 
begin
ALUOut = #2 PC + $signed(Imm);
cond = #2 (A == B); //condition for branching
end

endcase


if (((IR[31:26] == BEQ) && (cond == 1)) || ((IR[31:26] == BNE) && (cond == 0)))
//if current instruction is a 'BRANCH'type with cond = 1
begin

TAKEN_BRANCH = #2 1'b1;
PC = #2 ALUOut;
end

else

begin
// updating memory for 'STORE' type instruction
//Loading value in LMD for 'LOAD' type instruction
case (type)
LOAD: LMD = #2 Mem[ALUOut];
STORE: if (TAKEN_BRANCH == 0) 
Mem[ALUOut] = #2 B;
endcase

if(TAKEN_BRANCH==0)
begin
  //updating register values after execution of a instruction
case (type)
RR_ALU: Reg[IR[15:11]] = #2 ALUOut; // "rd"
RM_ALU: Reg[IR[20:16]] = #2 ALUOut; // "rt"
LOAD: Reg[IR[20:16]] = #2 LMD; // "rt"
HALT: HALTED = #2 1'b1;
endcase
end

PC = #2 PC + 1;

end

end
end
endmodule