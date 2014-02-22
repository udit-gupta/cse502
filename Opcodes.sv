module Opcodes(op,ModRM);

typedef logic[63:0] mystring;
output mystring op[0:255];

output logic[255:0] ModRM = 256'b1111000011110000111100001111000011110000111100001111000011110000000000000000000000000000000000000001000000010000000000000000000011111111111110110000000000000000000000000000000000000000000000001100001100000000111100000000000000000000000000000000001100000000;

initial begin

	//opcode mnemonics

op[0] =   "        " ;
op[1] =   "        " ;
op[2] =   "        " ;
op[3] =   "        " ;
op[4] =   "        " ;
op[5] =   "        " ;
op[6] =   "PUSH    " ;
op[7] =   "POP     " ;
op[8] =   "OR      " ;
op[9] =   "OR      " ;
op[10] =  "OR      " ;
op[11] =  "OR      " ;
op[12] =  "OR      " ;
op[13] =  "OR      " ;
op[14] =  "PUSH    " ;
op[15] =  "ESC_OP  " ;
op[16] =  "ADC     " ;
op[17] =  "ADC     " ;
op[18] =  "ADC     " ;
op[19] =  "ADC     " ;
op[20] =  "ADC     " ;
op[21] =  "ADC     " ;
op[22] =  "PUSH    " ;
op[23] =  "POP     " ;
op[24] =  "SBB     " ;
op[25] =  "SBB     " ;
op[26] =  "SBB     " ;
op[27] =  "SBB     " ;
op[28] =  "SBB     " ;
op[29] =  "SBB     " ;
op[30] =  "PUSH    " ;
op[31] =  "POP     " ;
op[32] =  "AND     " ;
op[33] =  "AND     " ;
op[34] =  "AND     " ;
op[35] =  "AND     " ;
op[36] =  "AND     " ;
op[37] =  "AND     " ;
op[38] =  "PFX_ES  " ;
op[39] =  "DAA     " ;
op[40] =  "SUB     " ;
op[41] =  "SUB     " ;
op[42] =  "SUB     " ;
op[43] =  "SUB     " ;
op[44] =  "SUB     " ;
op[45] =  "SUB     " ;
op[46] =  "PFX_CS  " ;
op[47] =  "DAS     " ;
op[48] =  "XOR     " ;
op[49] =  "XOR     " ;
op[50] =  "XOR     " ;
op[51] =  "XOR     " ;
op[52] =  "XOR     " ;
op[53] =  "XOR     " ;
op[54] =  "PFX_SS  " ;
op[55] =  "AAA     " ;
op[56] =  "CMP     " ;
op[57] =  "CMP     " ;
op[58] =  "CMP     " ;
op[59] =  "CMP     " ;
op[60] =  "CMP     " ;
op[61] =  "CMP     " ;
op[62] =  "PFX_DS  " ;
op[63] =  "AAS     " ;
op[64] =  "REX     " ;
op[65] =  "REX     " ;
op[66] =  "REX     " ;
op[67] =  "REX     " ;
op[68] =  "REX     " ;
op[69] =  "REX     " ;
op[70] =  "REX     " ;
op[71] =  "REX     " ;
op[72] =  "REX     " ;
op[73] =  "REX     " ;
op[74] =  "REX     " ;
op[75] =  "REX     " ;
op[76] =  "REX     " ;
op[77] =  "REX     " ;
op[78] =  "REX     " ;
op[79] =  "REX     " ;
op[80] =  "PUSH    " ;
op[81] =  "PUSH    " ;
op[82] =  "PUSH    " ;
op[83] =  "PUSH    " ;
op[84] =  "PUSH    " ;
op[85] =  "PUSH    " ;
op[86] =  "PUSH    " ;
op[87] =  "PUSH    " ;
op[88] =  "POP     " ;
op[89] =  "POP     " ;
op[90] =  "POP     " ;
op[91] =  "POP     " ;
op[92] =  "POP     " ;
op[93] =  "POP     " ;
op[94] =  "POP     " ;
op[95] =  "POP     " ;
op[96] =  "PUSHA   " ;
op[97] =  "POPA    " ;
op[98] =  "BOUND   " ;
op[99] =  "MOVSXD  " ;
op[100] = "PF_FS   " ;
op[101] = "PF_GS   " ;
op[102] = "PF_OP   " ;
op[103] = "PF_A    " ;
op[104] = "PUSH    " ;
op[105] = "IMUL    " ;
op[106] = "PUSH    " ;
op[107] = "IMUL    " ;
op[108] = "INS     " ;
op[109] = "INS     " ;
op[110] = "OUTS    " ;
op[111] = "OUTS    " ;
op[112] = "J       " ;
op[113] = "J       " ;
op[114] = "J       " ;
op[115] = "J       " ;
op[116] = "J       " ;
op[117] = "J       " ;
op[118] = "J       " ;
op[119] = "J       " ;
op[120] = "J       " ;
op[121] = "J       " ;
op[122] = "J       " ;
op[123] = "J       " ;
op[124] = "J       " ;
op[125] = "J       " ;
op[126] = "J       " ;
op[127] = "J       " ;
op[128] = "        " ;
op[129] = "        " ;
op[130] = "        " ;
op[131] = "        " ;
op[132] = "TEST    " ;
op[133] = "TEST    " ;
op[134] = "XCHG    " ;
op[135] = "XCHG    " ;
op[136] = "MOV     " ;
op[137] = "MOV     " ;
op[138] = "MOV     " ;
op[139] = "MOV     " ;
op[140] = "MOV     " ;
op[141] = "LEA     " ;
op[142] = "MOV     " ;
op[143] = "POP     " ;
op[144] = "NOP     " ;
op[145] = "XCHG    " ;
op[146] = "XCHG    " ;
op[147] = "XCHG    " ;
op[148] = "XCHG    " ;
op[149] = "XCHG    " ;
op[150] = "XCHG    " ;
op[151] = "XCHG    " ;
op[152] = "CBW     " ;
op[153] = "CWD     " ;
op[154] = "CALL    " ;
op[155] = "WAIT    " ;
op[156] = "PUSHF   " ;
op[157] = "POPF    " ;
op[158] = "SAHF    " ;
op[159] = "LAHF    " ;
op[160] = "MOV     " ;
op[161] = "MOV     " ;
op[162] = "MOV     " ;
op[163] = "MOV     " ;
op[164] = "MOVS    " ;
op[165] = "MOVS    " ;
op[166] = "CMPS    " ;
op[167] = "CMPS    " ;
op[168] = "TEST    " ;
op[169] = "TEST    " ;
op[170] = "STOS    " ;
op[171] = "STOS    " ;
op[172] = "LODS    " ;
op[173] = "LODS    " ;
op[174] = "SCAS    " ;
op[175] = "SCAS    " ;
op[176] = "MOV     " ;
op[177] = "MOV     " ;
op[178] = "MOV     " ;
op[179] = "MOV     " ;
op[180] = "MOV     " ;
op[181] = "MOV     " ;
op[182] = "MOV     " ;
op[183] = "MOV     " ;
op[184] = "MOV     " ;
op[185] = "MOV     " ;
op[186] = "MOV     " ;
op[187] = "MOV     " ;
op[188] = "MOV     " ;
op[189] = "MOV     " ;
op[190] = "MOV     " ;
op[191] = "MOV     " ;
op[192] = "GRP2    " ;
op[193] = "GRP2    " ;
op[194] = "RET     " ;
op[195] = "RETQ    " ;
op[196] = "LES     " ;
op[197] = "LDS     " ;
op[198] = "MOV     " ;
op[199] = "MOV     " ;
op[200] = "ENTER   " ;
op[201] = "LEAVE   " ;
op[202] = "RET     " ;
op[203] = "RET     " ;
op[204] = "INT3    " ;
op[205] = "INT     " ;
op[206] = "INTO    " ;
op[207] = "IRET    " ;
op[208] = "SF_GRP2 " ;
op[209] = "SF_GRP2 " ;
op[210] = "SF_GRP2 " ;
op[211] = "SF_GRP2 " ;
op[212] = "AAM     " ;
op[213] = "        " ;
op[214] = "AAD     " ;
op[215] = "XLAT    " ;
op[216] = "ESC     " ;
op[217] = "ESC     " ;
op[218] = "ESC     " ;
op[219] = "ESC     " ;
op[220] = "ESC     " ;
op[221] = "ESC     " ;
op[222] = "ESC     " ;
op[223] = "ESC     " ;
op[224] = "LOOPNE  " ;
op[225] = "LOOPE   " ;
op[226] = "LOOP    " ;
op[227] = "JRCXZ   " ;
op[228] = "IN      " ;
op[229] = "IN      " ;
op[230] = "OUT     " ;
op[231] = "OUT     " ;
op[232] = "CALL    " ;
op[233] = "JMP     " ;
op[234] = "JMP     " ;
op[235] = "JMP     " ;
op[236] = "IN      " ;
op[237] = "IN      " ;
op[238] = "OUT     " ;
op[239] = "OUT     " ;
op[240] = "LOCK    " ;
op[241] = "        " ;
op[242] = "REPNE   " ;
op[243] = "REPE    " ;
op[244] = "HLT     " ;
op[245] = "CMC     " ;
op[246] = "GRP3    " ;
op[247] = "GRP3    " ;
op[248] = "CLC     " ;
op[249] = "STC     " ;
op[250] = "CLI     " ;
op[251] = "STI     " ;
op[252] = "CLD     " ;
op[253] = "STD     " ;
op[254] = "INC     " ;
op[255] = "DEC     " ;

if (op[1] == 0);
if (ModRM == 0);


end

endmodule
