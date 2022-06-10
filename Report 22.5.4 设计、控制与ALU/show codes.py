ctl_pcValue_mux = ['PC+4', 'aluRes', 'instIndex', 'temp', 'useDelaySlot']
ctl_aluSrc1_mux = ['rs', 'sa', 'PC']
ctl_aluSrc2_mux = ['rt', 'imm', 'HI', 'LO']
ctl_alu_mux = []
ctl_rfWriteData_mux = ['aluRes', 'DataRamReadData', 'PC+8']
ctl_rfWriteAddr_mux = ['rd', 'rt', '31']

TBD = None
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
WHITE = "\033[0m"

codes = {
    'sll': {
        'opcode': '000000', 'funct': '000000', 'rt': None,
        'pcValue': 'PC+4',
        'instRam_en': True, 'instRam_wen': False,
        'aluSrc1': 'sa', 'aluSrc2': 'rt', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'aluRes', 'rfWriteAddr': 'rd', 'rf_wen': True,
        'low_wen': False, 'high_wen': False, 'temp_wen': False
    },

    'srl': {
        'opcode': '000000', 'funct': '000010', 'rt': None,
        'pcValue': 'PC+4',
        'instRam_en': True, 'instRam_wen': False,
        'aluSrc1': 'sa', 'aluSrc2': 'rt', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'aluRes', 'rfWriteAddr': 'rd', 'rf_wen': True,
        'low_wen': False, 'high_wen': False, 'temp_wen': False
    },
    
    'sra': {
        'opcode': '000000', 'funct': '000011', 'rt': None,
        'pcValue': 'PC+4',
        'instRam_en': True, 'instRam_wen': False,
        'aluSrc1': 'sa', 'aluSrc2': 'rt', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'aluRes', 'rfWriteAddr': 'rd', 'rf_wen': True,
        'low_wen': False, 'high_wen': False, 'temp_wen': False
    },

    'sllv': {
        'opcode': '000000', 'funct': '000100', 'rt': None,
        'pcValue': 'PC+4',
        'instRam_en': True, 'instRam_wen': False,
        'aluSrc1': 'rs', 'aluSrc2': 'rt', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'aluRes', 'rfWriteAddr': 'rd', 'rf_wen': True,
        'low_wen': False, 'high_wen': False, 'temp_wen': False
    },

    'srlv': {
        'opcode': '000000', 'funct': '000110', 'rt': None,
        'pcValue': 'PC+4',
        'instRam_en': True, 'instRam_wen': False,
        'aluSrc1': 'rs', 'aluSrc2': 'rt', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'aluRes', 'rfWriteAddr': 'rd', 'rf_wen': True,
        'low_wen': False, 'high_wen': False, 'temp_wen': False
    },

    'srav': {
        'opcode': '000000', 'funct': '000111', 'rt': None,
        'pcValue': 'PC+4',
        'instRam_en': True, 'instRam_wen': False,
        'aluSrc1': 'rs', 'aluSrc2': 'rt', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'aluRes', 'rfWriteAddr': 'rd', 'rf_wen': True,
        'low_wen': False, 'high_wen': False, 'temp_wen': False
    },

    'jr': {
        'opcode': '000000', 'funct': '001000', 'rt': None,
        'pcValue': 'useDelaySlot',
        'instRam_en': False, 'instRam_wen': False,
        'aluSrc1': 'rs', 'aluSrc2': 'ignore', 'alu': TBD,
        'dataRam_en': False, 'dataRam_wen': False,
        'rfWriteData': 'unable', 'rfWriteAddr': 'unable', 'rf_wen': False,
        'low_wen': False, 'high_wen': False, 'temp_wen': True
    },

}

def onehot(value: any, li: list) -> str:
    if type(li) is not list:
        return value
    if value not in li:
        return "0" * len(li)
    index = li.index(value)
    res = "0" * index + "1" + "0" * (len(li) - index - 1)
    return res[::-1]


def kakuninn(op, func, rt):
    if op is not str:
        op = bin(op).replace('0b','')
    if func is not str:
        func = bin(func).replace('0b','')
    if rt is not str:
        rt = bin(rt).replace('0b','')
    if len(op) < 6:
        op = "0" * (6 - len(op)) + op
    if len(func) < 6:
        func = "0" * (6 - len(func)) + func
    if len(rt) < 5:
        rt = "0" * (5 - len(rt)) + rt
    name, code_dict = None, None
    for code_name, code in codes.items():
        if code['opcode'] == op \
           and (code['funct'] is None or code['funct'] == func) \
           and (code['rt'] is None or code['rt'] == rt):
            code_dict = code
            name = code_name
            break
    return name, code_dict, op, func, rt


def printing(code_name, code_dict):
    print(GREEN, end="")
    print("pcValue =", onehot(code_dict['pcValue'], ctl_pcValue_mux))
    print(YELLOW, end="")
    print("instRam_en =", onehot(code_dict['instRam_en'], None))
    print("instRam_wen =", onehot(code_dict['instRam_wen'], None))
    print(GREEN, end="")
    print("aluSrc1 =", onehot(code_dict['aluSrc1'], ctl_aluSrc1_mux))
    print("aluSrc2 =", onehot(code_dict['aluSrc2'], ctl_aluSrc2_mux))
    print("alu =", onehot(code_dict['alu'], ctl_alu_mux))
    print(YELLOW, end="")
    print("dataRam_en =", onehot(code_dict['dataRam_en'], None))
    print("dataRam_wen =", onehot(code_dict['dataRam_wen'], None))
    print(GREEN, end="")
    print("rfWriteData =", onehot(code_dict['rfWriteData'], ctl_rfWriteData_mux))
    print("rfWriteAddr =", onehot(code_dict['rfWriteAddr'], ctl_rfWriteData_mux))
    print(YELLOW, end="")
    print("rf_wen =", onehot(code_dict['rf_wen'], None))
    print("low_wen =", onehot(code_dict['low_wen'], None))
    print("high_wen =", onehot(code_dict['high_wen'], None))
    print("temp_wen =", onehot(code_dict['temp_wen'], None))
    print(WHITE, end="")


if __name__ == "__main__":
    # op = input("opcode: ")
    # func = input("funct: ")
    # rt = input("rt: ")
    last_name = None
    for op in range(64):
        for func in range(64):
            for rt in range(32):
                name, code_dictr, opr, funcr, rtr = kakuninn(op, func, rt)
                if name is None or name == last_name:
                    continue
                last_name = name
                print(RED, end="")
                print(name.upper(), opr, funcr, rtr, sep="\n")
                printing(name, code_dictr)
                input()