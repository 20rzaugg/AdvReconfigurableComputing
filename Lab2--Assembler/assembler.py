import re
import sys
import os
from assembler_dictionaries import *

mode = 0
DATA = 1
TEXT = 2

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
    # create memory map
    for line in input_file:
        # remove comments
        line = line.strip()
        if line:
            if line[0] == ';' or line[0] == '\n':
                continue
            if ".DATA" in line.upper():
                mode = DATA
                continue
            elif ".TEXT" in line.upper():
                mode = TEXT
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
                        b = instruction_set[K]["opcode"]
                        arg = 1
                        for i in instruction_set[K]["operands"]:
                            if i[0] == reg:
                                if k[arg].upper() in register_set.keys():
                                    b += register_set[k[arg].upper()]
                                    arg += 1
                                else:
                                    print("Error: Invalid register name\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                    exit(1)
                            elif i[0] == imm:
                                if k[arg] in data_memory_table.keys():
                                    b += format(data_memory_table[k[arg]][0], '016b')
                                    arg += 1
                                else:
                                    try:
                                        x = int(k[arg])
                                        if x >= 0 and x < 65536:
                                            b += format(x, '016b')
                                            arg += 1
                                        else:
                                            print("Error: Immediate out of range\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                            exit(1)
                                    except ValueError:
                                        print("Error: Unknown variable immediate\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                        exit(1)
                            elif i[0] == addr_abs:
                                if k[arg].upper() in instruction_memory_table.keys():
                                    b += format(instruction_memory_table[k[arg].upper()], '0{}b'.format(i[1]))
                                    arg += 1
                                else:
                                    try:
                                        x = int(k[arg])
                                        if x >= 0 and x < 2097152:
                                            b += format(x, '021b')
                                            arg += 1
                                        else:
                                            print("Error: Address out of range\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                            exit(1)
                                    except ValueError:
                                        print("Error: Unknown variable address\nline "+str(line_number) + ": " + line.replace('\t\t',' '))
                                        exit(1)
                            elif i[0] == addr_offset:
                                if k[arg] in data_memory_table.keys():
                                    b += format(data_memory_table[k[arg]][0], '016b')
                                    arg += 1
                                else:
                                    try:
                                        x = int(k[arg])
                                        if x >= 0 and x < 65536:
                                            b += format(x, '016b')
                                            arg += 1
                                    except ValueError:
                                        print("Error: Unknown variable address\nline "+str(line_number) + ": " + line)
                                        exit(1)
                            elif i[0] == unused:
                                b += '0'*i[1]
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
