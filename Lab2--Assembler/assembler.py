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
    output_file_name = file_name.split(".")[0] + ".mif"
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
                        data_memory_table[k[0]] = [data_address, int(k[2])]
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
    input_file.seek(0)
    output_file = open(output_file_name, "w")
    output_file.write(
"""DEPTH = 1024; 
WIDTH = 32; 
ADDRESS_RADIX = HEX; 
DATA_RADIX = HEX; 
CONTENT 
BEGIN\n\n""")
    for line in file:
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
            if mode == DATA:
                continue
            elif mode == TEXT:
                k = re.findall(r"\w+", line)
                b = ""
                if k:
                    K = k[0].upper()
                    if K in instruction_set.keys():
                        b = instruction_set[K]["opcode"]
                        for i in instruction_set[K]["operands"]:
                            if i[0] == rdest:
                                b += format(int(k[1]), '05b')
                            elif i[0] == rsrc1:
                                b += format(int(k[2]), '05b')
                            elif i[0] == rsrc2:
                                b += format(int(k[3]), '05b')
                            elif i[0] == imm:
                                b += format(int(k[3]), '016b')
                            elif i[0] == addr_offset:
                                b += format(int(k[3]), '016b')
                            elif i[0] == addr_base:
                                b += format(int(k[2]), '05b')
                            elif i[0] == addr_abs:
                                b += format(int(k[2]), '016b')
                            elif i[0] == unused:
                                b += format(0, '011b')
                        output_file.write(format(instruction_memory_table[K], '03x') + " : " + b + ";\n")
        
    print(data_memory_table)
    print(instruction_memory_table)