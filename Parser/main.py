# MIPS Parser supporting a subset of instructions
# Consult documentation for instructions supported.
# Pseudocode is not implemented currently. 
# Python 3.5+ needed. 

from dict_data import *
from re import split as resplit

def is_number(string):
    try:
        int(string, 16)
        return True
    except ValueError:
        return False

def ReadInstLn():
    line =  resplit(',|\s|\(|\)', input())
    line = [w for w in line if w]
    return line[: ([i for i in range(0, len(line)) \
        if line[i][0] == '#'] + [None])[0]]

def FillZeroLeft(num_str, min_len):
    return ((min_len - len(num_str)) * '0') + num_str

def InstCntToAddr(n):
    return n

def BinToHex(bin_str):
    ans = ''
    for i in range(0, len(bin_str), 4):
        ans += hex(int(bin_str[i: i + 4], 2))[2:]
    return ans

def NumToBin(num_str):
    if(num_str[:2] == '0x'): # hex
        return bin(int(num_str, 16))[2:]
    if(num_str[0] == '-'): # negative: only happens for I-type immediate, 16bits
        return bin(2**16 + int(num_str))[2:]
    else:
        return bin(int(num_str))[2:]

def RegnameToNum(regname):
    regname = regname.replace('$', '')   # remove $

    if(regname.isnumeric()):    # deals with numeric expression like $31, $12
        return int(regname)

    if(regname[-1].isnumeric()):   # deals with symbolic expression like $ra, $t4
        if(int(regname[-1]) < 8):  # $t8, $t9, $s8 need to be treated separately
            return regnum_dict[regname[:-1]] + int(regname[-1])
        if regname[0] == 's':
            return regnum_dict['fp']    # $s8 is equivalent to $fp
        return [24, 25][regname[-1] == '9'] # $t8, $t9

    return regnum_dict[regname]

def ParseInst(inst_line):
    op_name = inst_line[0]
    syntax = inst_syntax_dict[op_parse_dict[op_name]['type']]
    parsed_inst = {}
    for i in range(1, len(inst_line)):
        if(syntax[i - 1][0] == 'r'): # is a register name
            parsed_inst[syntax[i - 1]] = str(RegnameToNum(inst_line[i]))
        else:
            parsed_inst[syntax[i - 1]] = inst_line[i]

    parsed_inst = {**parsed_inst, **op_parse_dict[op_name]}
    return parsed_inst

def ConvertToBin(parsed_inst):
    ans = ''
    slots = inst_bin_format_dict[parsed_inst['type']]
    for i in range(0, len(slots)):
        if(slots[i][0] in parsed_inst):
            bin_str = NumToBin(parsed_inst[slots[i][0]])
            ans += FillZeroLeft(bin_str, slots[i][1])
        else:
            ans += FillZeroLeft('', slots[i][1])
    return ans




inst_cnt = 0
label_dict = {}
parsed_inst = []
bin_out = []
while(True):
    inst_line = ReadInstLn()
    if(inst_line):
        if(inst_line[0] == 'END'):
            break
        if(inst_line[0][-1] == ':'):   # label line
            label_dict[inst_line[0][:-1]] = inst_cnt
        else:
            parsed_inst.append(ParseInst(inst_line))
            inst_cnt += 1

for i in range(0, inst_cnt):
    # Deals with label, convert to binary
    if('imm' in parsed_inst[i]):
        if(not is_number(parsed_inst[i]['imm'])):
            parsed_inst[i]['imm'] = \
                str(label_dict[parsed_inst[i]['imm']] - i - 1)

    elif('target' in parsed_inst[i]):
        if(not is_number(parsed_inst[i]['target'])):
            parsed_inst[i]['target'] = \
                str(InstCntToAddr(label_dict[parsed_inst[i]['target']]))

    bin_out.append(ConvertToBin(parsed_inst[i]))

for i in range(0, inst_cnt):
    print('ROM_DATA[%d] = 32\'h%s;'%(i, BinToHex(bin_out[i])))