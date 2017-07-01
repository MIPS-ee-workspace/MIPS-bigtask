# Dictionary data for MIPS Parser

regnum_dict = {
    'zero': 0,  'at': 1,    'v': 2, 
    'a': 4,     't': 8,     's': 16, 
    'k': 26,    'gp': 28,   'sp': 29, 
    'fp': 30,   'ra': 31
}


inst_syntax_dict = { # OpName omitted
    'R': ['rd', 'rs', 'rt'],
    'ShiftR': ['rd', 'rt', 'shamt'],
    'I': ['rt', 'rs', 'imm'],
    'MEMI': ['rt', 'imm', 'rs'],
    'LI': ['rt', 'imm'],
    'J': ['target'],
    'JR': ['rs'],
    'JALR': ['rs', 'rd']
}


op_parse_dict = { 
    # Contains non-trivial information only(note that all R-type instructions have OpCode = 0)
    'nop': {'type': 'R'},
    'lw': {'type': 'MEMI', 'OpCode': '0x23'},
    'sw': {'type': 'MEMI', 'OpCode': '0x2b'},
    'lui': {'type': 'LI', 'OpCode': '0x0f'},
    'add': {'type': 'R', 'funct': '0x20'},
    'addu': {'type': 'R', 'funct': '0x21'},
    'sub': {'type': 'R', 'funct': '0x22'},
    'subu': {'type': 'R', 'funct': '0x23'},
    'addi': {'type': 'I', 'OpCode': '0x08'},
    'addiu': {'type': 'I', 'OpCode': '0x09'},
    'and': {'type': 'R', 'funct': '0x24'},
    'or': {'type': 'R', 'funct': '0x25'}, 
    'xor': {'type': 'R', 'funct': '0x26'},
    'nor': {'type': 'R', 'funct': '0x27'},
    'andi': {'type': 'I', 'OpCode': '0x0c'}, 
    'sll': {'type': 'ShiftR', 'funct': '0x00'},
    'srl': {'type': 'ShiftR', 'funct': '0x02'},
    'sra': {'type': 'ShiftR', 'funct': '0x03'},
    'slt': {'type': 'R', 'funct': '0x2a'},
    'sltu': {'type': 'R', 'funct': '0x2b'},
    'slti': {'type': 'I', 'OpCode': '0x0a'},
    'sltiu': {'type': 'I', 'OpCode': '0x0b'},
    'beq': {'type': 'I', 'OpCode': '0x04'},
    'bne': {'type': 'I', 'OpCode': '0x05'},
    'j': {'type': 'J', 'OpCode': '0x02'},
    'jal': {'type': 'J', 'OpCode': '0x03'},
    'jr': {'type': 'JR', 'funct': '0x08'},
    'jalr': {'type': 'JR', 'funct': '0x09'}
}


inst_bin_format_dict = {
    'R': [['OpCode', 6], ['rs', 5], ['rt', 5], ['rd', 5], ['shamt', 5], ['funct', 6]],
    'I': [['OpCode', 6], ['rs', 5], ['rt', 5], ['imm', 16]],
    'J': [['OpCode', 6], ['target', 26]]
}
inst_bin_format_dict['ShiftR'] = inst_bin_format_dict['R']
inst_bin_format_dict['JR'] = inst_bin_format_dict['R']
inst_bin_format_dict['JALR'] = inst_bin_format_dict['R']
inst_bin_format_dict['LI'] = inst_bin_format_dict['I']
inst_bin_format_dict['MEMI'] = inst_bin_format_dict['I']