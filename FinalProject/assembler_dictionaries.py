dest_reg = 0
src_reg1 = 1
src_reg2 = 2
src_reg3 = 3
imm = 4

instruction_set = {
     "NOOP":  { "opcode": "00000000",
                    "operands": []
                 },
     "LW":    {
                     "opcode": "10000001",
                     "operands": [dest_reg, src_reg2, src_reg1]
                 },
     "LWP":    {
                     "opcode": "10000000",
                     "operands": [dest_reg, imm, src_reg1]
                 },
     "SW":    {
                     "opcode": "00000101",
                     "operands": [imm, src_reg1, src_reg3]
                 },
     "SWP":    {
                     "opcode": "00000100",
                     "operands": [src_reg2, src_reg1, src_reg3]
                 },
     "ADD":   {
                     "opcode": "10000100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "ADDI":  {
                     "opcode": "10000101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "ADDU":  {
                     "opcode": "10000110",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "ADDUI": {
                     "opcode": "10000111",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SUB":   {
                     "opcode": "10001000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SUBI":  {
                     "opcode": "10001001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SUBU":  {
                     "opcode": "10001010",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SUBUI": {
                     "opcode": "10001011",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "AND":   {
                     "opcode": "10001100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "ANDI":  {
                     "opcode": "10001101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "OR":    {
                     "opcode": "10010000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "ORI":   {
                     "opcode": "10010001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "XOR":   {
                     "opcode": "10010100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "XORI":  {
                     "opcode": "10010101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SLL":   {
                     "opcode": "10011000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SLLI":  {
                     "opcode": "10011001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SRL":   {
                     "opcode": "10011100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SRLI":  {
                     "opcode": "10011101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SRA":   {
                     "opcode": "10100000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SRAI":  {
                     "opcode": "10100001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SLT":   {
                     "opcode": "10101100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SLTI":  {
                     "opcode": "10101101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SLTU":  {
                     "opcode": "10101110",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SLTUI": {
                     "opcode": "10101111",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SGT":   {
                     "opcode": "10100100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SGTI":  {
                     "opcode": "10100101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SGTU":  {
                     "opcode": "10100110",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SGTUI": {
                     "opcode": "10100111",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SLE":   {
                     "opcode": "10110000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SLEI":  {
                     "opcode": "10110001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SLEU":  {
                     "opcode": "10110010",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SLEUI": {
                     "opcode": "10110011",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SGE":   {
                     "opcode": "10101000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SGEI":  {
                     "opcode": "10101001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SGEU":  {
                     "opcode": "10101010",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SGEUI": {
                     "opcode": "10101011",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SEQ":   {
                     "opcode": "10110100",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SEQI":  {
                     "opcode": "10110101",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "SNE":   {
                     "opcode": "10111000",
                     "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "SNEI":  {
                     "opcode": "10111001",
                     "operands": [dest_reg, src_reg1, imm]
                 },
     "BEQZ":  {
                     "opcode": "00110101",
                     "operands": [src_reg1, imm]
                 },
     "BNEZ":  {
                     "opcode": "00111001",
                     "operands": [src_reg1, imm]
                 },
     "J":     {
                     "opcode": "00111101",
                     "operands": [imm]
                 },
     "JR":    {
                     "opcode": "00111100",
                     "operands": [src_reg2]
                 },
     "JAL":   {
                     "opcode": "10111101",
                     "operands": [imm]
                 },
     "JALR":  {
                     "opcode": "10111100",
                     "operands": [src_reg2]
                 },
     "PCH":   {
                    "opcode": "01000000",
                    "operands": [src_reg1]
                 },
     "PD":   {
                    "opcode": "01000100",
                    "operands": [src_reg1]
                 },
     "PDU":   {
                    "opcode": "01000110",
                    "operands": [src_reg1]
                 },
     "GD":    {
                    "opcode": "11000000",
                    "operands": [dest_reg]
                 },
     "GDU":   {
                    "opcode": "11000010",
                    "operands": [dest_reg]
                 },
     "TCLR":   {
                    "opcode": "01100000",
                    "operands": []
                 },
     "TSRT":   {
                    "opcode": "01100100",
                    "operands": []
                 },
     "TSTP":   {
                    "opcode": "01101000",
                    "operands": []
                 },
     "LCM":   {
                    "opcode": "11100000",
                    "operands": [dest_reg, src_reg1, src_reg2]
                 },
     "LCMI":   {
                    "opcode": "11100001",
                    "operands": [dest_reg, src_reg1, imm]
                 }
}

register_set = {
    "R0" : "000000",
    "R1" : "000001",
    "R2" : "000010",
    "R3" : "000011",
    "R4" : "000100",
    "R5" : "000101",
    "R6" : "000110",
    "R7" : "000111",
    "R8" : "001000",
    "R9" : "001001",
    "R10": "001010",
    "R11": "001011",
    "R12": "001100",
    "R13": "001101",
    "R14": "001110",
    "R15": "001111",
    "R16": "010000",
    "R17": "010001",
    "R18": "010010",
    "R19": "010011",
    "R20": "010100",
    "R21": "010101",
    "R22": "010110",
    "R23": "010111",
    "R24": "011000",
    "R25": "011001",
    "R26": "011010",
    "R27": "011011",
    "R28": "011100",
    "R29": "011101",
    "R30": "011110",
    "R31": "011111",
    "R32": "100000",
    "R33": "100001",
    "R34": "100010",
    "R35": "100011",
    "R36": "100100",
    "R37": "100101",
    "R38": "100110",
    "R39": "100111",
    "R40": "101000",
    "R41": "101001",
    "R42": "101010",
    "R43": "101011",
    "R44": "101100",
    "R45": "101101",
    "R46": "101110",
    "R47": "101111",
    "R48": "110000",
    "R49": "110001",
    "R50": "110010",
    "R51": "110011",
    "R52": "110100",
    "R53": "110101",
    "R54": "110110",
    "R55": "110111",
    "R56": "111000",
    "R57": "111001",
    "R58": "111010",
    "R59": "111011",
    "R60": "111100",
    "R61": "111101",
    "R62": "111110",
    "R63": "111111"
}