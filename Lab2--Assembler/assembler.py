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
    # create memory map
    
    for line in input_file:
        # remove comments
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
            
    print(data_memory_table)
    print(instruction_memory_table)