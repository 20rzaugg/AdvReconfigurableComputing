import re
import sys
import os
from assembler_dictionaries import *

mode = 0
DATA = 1
TEXT = 2
CONST = 3

instruction_address = 0
data_address = 0
instruction_memory_table = {}
data_memory_table = {}

if __name__ == "__main__":
    # file name in commandline argument
    file_name = sys.argv[1]
    input_file = open(file_name, "r")
    # output file name
    text_output_file_name = file_name.split(".")[0] + "_text.mif"
    data_output_file_name = file_name.split(".")[0] + "_data.mif"
    line_number = 1
    # create memory map
    for line in input_file:
        # remove comments
        line = line.strip()
        if line:
            if line[0] == ';' or line[0] == '\n':
                line_number += 1
                continue
            if ".DATA" in line.upper():
                mode = DATA
                line_number += 1
                continue
            elif ".TEXT" in line.upper():
                mode = TEXT
                line_number += 1
                continue
            elif ".CONST" in line.upper():
                mode = CONST
                line_number += 1
                continue
            # parse line into command arguments
            else:
                if mode == DATA:
                    k = re.findall(r"\w+", line)
                    if k:
                        data_memory_table[k[0]] = [data_address, k[2:]]
                        data_address += int(k[1])
                elif mode == TEXT:
                    k = re.findall(r"\w+", line)
                    if k:
                        K = k[0].upper()
                        if K in instruction_set.keys():
                            instruction_address += 1
                        else:
                            instruction_memory_table[K] = instruction_address
                elif mode == CONST:
                    k = re.findall(r"\w+", line)
                    if k:
                        s = re.findall(r'".+"', line)[0][1:-1]
                        s = s.replace("\\n","\n")
                        s = s.replace("\\t","\t")
                        if len(s) != int(k[1]):
                            print("Error: String length does not match\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                            exit(1)
                        else:
                            m = []
                            for i in s:
                                m.append(ord(i))
                            m.append(0)
                            data_memory_table[k[0]] = [data_address, m]
                            data_address += int(k[1]) + 1
            line_number += 1

    mode = 0
    line_number = 1
    input_file.seek(0)
    output_file = open(text_output_file_name, "w")
    output_file.write(
"""DEPTH = 1024; 
WIDTH = 32; 
ADDRESS_RADIX = HEX; 
DATA_RADIX = HEX; 
CONTENT 
BEGIN\n\n""")
    instruction_address = 0
    for line in input_file:
        line = line.strip()
        if line:
            if line[0] == ';' or line[0] == '\n':
                line_number += 1
                continue
            if ".DATA" in line.upper():
                line_number += 1
                mode = DATA
                continue
            elif ".TEXT" in line.upper():
                line_number += 1
                mode = TEXT
                continue
            if mode == DATA:
                line_number += 1
                continue
            elif mode == TEXT:
                k = re.findall(r"\w+", line)
                b = ""
                if k:
                    K = k[0].upper()
                    if K in instruction_set.keys():
                        b = "00000000000000000000000000000000"
                        b = instruction_set[K]["opcode"] + b[6:]
                        arg = 1
                        for i in instruction_set[K]["operands"]:
                            if i[0] == dest_reg:
                                if k[arg].upper() in register_set.keys():
                                    b = b[0:6] + register_set[k[arg].upper()] + b[11:]
                                    arg += 1
                                else:
                                    print("Error: Invalid register name\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                    exit(1)
                            elif i[0] == src_reg1:
                                if k[arg].upper() in register_set.keys():
                                    b = b[0:11] + register_set[k[arg].upper()] + b[16:]
                                    arg += 1
                                else:
                                    print("Error: Invalid register name\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                    exit(1)
                            elif i[0] == src_reg2:
                                if k[arg].upper() in register_set.keys():
                                    b = b[0:16] + register_set[k[arg].upper()] + b[21:]
                                    arg += 1
                                else:
                                    print("Error: Invalid register name\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                    exit(1)
                            elif i[0] == imm:
                                if k[arg] in data_memory_table.keys():
                                    b = b[0:16] + format(data_memory_table[k[arg]][0], '016b')
                                    arg += 1
                                elif k[arg].upper() in instruction_memory_table.keys():
                                    b = b[0:16] + format(instruction_memory_table[k[arg].upper()], '016b')
                                    arg += 1
                                else:
                                    try:
                                        x = int(k[arg])
                                        if x >= 0 and x < 65536:
                                            b = b[0:16] + format(x, '016b')
                                            arg += 1
                                        else:
                                            print("Error: Immediate out of range\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                            exit(1)
                                    except ValueError:
                                        print("Error: Unknown variable immediate\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                        exit(1)
                            else:
                                pass
                        x = format(int(b,2),'08X')
                        a = format(instruction_address, '03X')
                        output_file.write(a + " : " + x + ";\t\t-- " + line.replace('\t\t',' ') + "\n")
                        instruction_address += 1
        line_number += 1
    output_file.write("\nEND;\n")
    input_file.close()
    output_file.close()
    output_file = open(data_output_file_name, "w")
    data_memory_address = 0
    output_file.write(
"""DEPTH = 1024; 
WIDTH = 32; 
ADDRESS_RADIX = HEX; 
DATA_RADIX = HEX; 
CONTENT 
BEGIN\n\n""")
    for i in data_memory_table.keys():
        index = 0
        if len(data_memory_table[i][1]) > 1:
            for x in data_memory_table[i][1]:
                a = format(data_memory_address, '03X')
                x = format(int(x),'08X')
                output_file.write(a + " : " + x + ";\t\t-- " + i + "[" + str(index) + "]\n")
                data_memory_address += 1
                index += 1
        else:
            a = format(data_memory_address, '03X')
            x = format(int(data_memory_table[i][1][0]),'08X')
            output_file.write(a + " : " + x + ";\t\t-- " + i + "\n")
            data_memory_address += 1
        
    output_file.write("\nEND;\n")
    output_file.close()
    print("Done")
