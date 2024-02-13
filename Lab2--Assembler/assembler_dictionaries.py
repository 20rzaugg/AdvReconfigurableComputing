unused = -1
reg = 0
imm = 1
addr_abs = 2
addr_offset = 3

instruction_set = {
     "NOOP":  { "opcode": "000000",
                    "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "LW":    {
                     "opcode": "000001",
                     "operands": [(reg, 5),(reg, 5),(addr_offset, 16)]
                 },
     "SW":    {
                     "opcode": "000010",
                     "operands": [(reg, 5),(reg, 5),(addr_offset, 16)] #TODO fix these?
                 },
     "ADD":   {
                     "opcode": "000011",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "ADDI":  {
                     "opcode": "000100",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "ADDU":  {
                     "opcode": "000101",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "ADDUI": {
                     "opcode": "000110",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SUB":   {
                     "opcode": "000111",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "SUBI":  {
                     "opcode": "001000",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SUBU":  {
                     "opcode": "001001",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "SUBUI": {
                     "opcode": "001010",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "AND":   {
                     "opcode": "001011",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "ANDI":  {
                     "opcode": "001100",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "OR":    {
                     "opcode": "001101",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "ORI":   {
                     "opcode": "001110",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "XOR":   {
                     "opcode": "001111",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "XORI":  {
                     "opcode": "010000",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SLL":   {
                     "opcode": "010001",
                     "operands": [(reg, 5),(reg, 5),(reg, 5),(unused, 11)]
                 },
     "SLLI":  {
                     "opcode": "010010",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SRL":   {
                     "opcode": "010011",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SRLI":  {
                     "opcode": "010100",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SRA":   {
                     "opcode": "010101",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SRAI":  {
                     "opcode": "010110",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SLT":   {
                     "opcode": "010111",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SLTI":  {
                     "opcode": "011000",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SLTU":  {
                     "opcode": "011001",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SLTUI": {
                     "opcode": "011010",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SGT":   {
                     "opcode": "011011",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SGTI":  {
                     "opcode": "011100",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SGTU":  {
                     "opcode": "011101",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SGTUI": {
                     "opcode": "011110",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SLE":   {
                     "opcode": "011111",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SLEI":  {
                     "opcode": "100000",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SLEU":  {
                     "opcode": "100001",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SLEUI": {
                     "opcode": "100010",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SGE":   {
                     "opcode": "100011",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SGEI":  {
                     "opcode": "100100",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SGEU":  {
                     "opcode": "100101",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SGEUI": {
                     "opcode": "100110",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SEQ":   {
                     "opcode": "100111",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SEQI":  {
                     "opcode": "101000",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "SNE":   {
                     "opcode": "101001",
                     "operands": [(reg, 5),(reg, 5),(reg, 5), (unused, 11)]
                 },
     "SNEI":  {
                     "opcode": "101010",
                     "operands": [(reg, 5),(reg, 5),(imm, 16)]
                 },
     "BEQZ":  {
                     "opcode": "101011",
                     "operands": [(reg, 5),(unused, 5),(addr_abs, 16)]
                 },
     "BNEZ":  {
                     "opcode": "101100",
                     "operands": [(reg, 5),(unused, 5),(addr_abs, 16)] #TODO fix these bitorders
                 },
     "J":     {
                     "opcode": "101101",
                     "operands": [(unused, 10),(addr_abs, 16)]
                 },
     "JR":    {
                     "opcode": "101110",
                     "operands": [(reg, 5),(unused, 21)]
                 },
     "JAL":   {
                     "opcode": "101111",
                     "operands": [(unused, 10),(addr_abs, 16)]
                 },
     "JALR":  {
                     "opcode": "110000",
                     "operands": [(reg, 5),(unused, 21)]
                 }
}

register_set = {
    "R0": "00000",
    "R1": "00001",
    "R2": "00010",
    "R3": "00011",
    "R4": "00100",
    "R5": "00101",
    "R6": "00110",
    "R7": "00111",
    "R8": "01000",
    "R9": "01001",
    "R10": "01010",
    "R11": "01011",
    "R12": "01100",
    "R13": "01101",
    "R14": "01110",
    "R15": "01111",
    "R16": "10000",
    "R17": "10001",
    "R18": "10010",
    "R19": "10011",
    "R20": "10100",
    "R21": "10101",
    "R22": "10110",
    "R23": "10111",
    "R24": "11000",
    "R25": "11001",
    "R26": "11010",
    "R27": "11011",
    "R28": "11100",
    "R29": "11101",
    "R30": "11110",
    "R31": "11111"
}