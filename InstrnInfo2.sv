module InstrnInfo2(inst_info2);
output logic[22:0] inst_info2[255];

initial begin

// numop(2),op1(2),op2(2),sizeop1(2),sizeop2(2),op1regno(4),op2regnum(4), ...GRP(5)    

inst_info2[0] = 23'b00000000000000000000000; // "Grp6"
inst_info2[1] = 23'b00000000000000000000000; // "Grp7"
inst_info2[2] = 23'b00000000000000000000000; // "LAR"
inst_info2[3] = 23'b00000000000000000000000; // "LSL"
inst_info2[4] = 23'b00000000000000000000000; // "NULL"
inst_info2[5] = 23'b00000000000000000000000; // "SYSCALL"
inst_info2[6] = 23'b00000000000000000000000; // "CLTS"
inst_info2[7] = 23'b00000000000000000000000; // "SYSRET"
inst_info2[8] = 23'b00000000000000000000000; // "INVD"
inst_info2[9] = 23'b00000000000000000000000; // "WBINVD"
inst_info2[10] = 23'b00000000000000000000000; // "NULL"
inst_info2[11] = 23'b00000000000000000000000; // "Iinst_info2"
inst_info2[12] = 23'b00000000000000000000000; // "NULL"
inst_info2[13] = 23'b00000000000000000000000; // "pfw"
inst_info2[14] = 23'b00000000000000000000000; // "NULL"
inst_info2[15] = 23'b00000000000000000000000; // "NULL"
inst_info2[16] = 23'b00000000000000000000000; // "VEC"
inst_info2[17] = 23'b00000000000000000000000; // "VEC"
inst_info2[18] = 23'b00000000000000000000000; // "VEC"
inst_info2[19] = 23'b00000000000000000000000; // "VEC"
inst_info2[20] = 23'b00000000000000000000000; // "VEC"
inst_info2[21] = 23'b00000000000000000000000; // "VEC"
inst_info2[22] = 23'b00000000000000000000000; // "VEC"
inst_info2[23] = 23'b00000000000000000000000; // "VEC"
inst_info2[24] = 23'b00000000000000000000000; // "pfgrp16"
inst_info2[25] = 23'b00000000000000000000000; // "NULL"
inst_info2[26] = 23'b00000000000000000000000; // "NULL"
inst_info2[27] = 23'b00000000000000000000000; // "NULL"
inst_info2[28] = 23'b00000000000000000000000; // "NULL"
inst_info2[29] = 23'b00000000000000000000000; // "NULL"
inst_info2[30] = 23'b00000000000000000000000; // "NULL"
inst_info2[31] = 23'b00000000000000000000000; // "NOP"
inst_info2[32] = 23'b00000000000000000000000; // "MOV"
inst_info2[33] = 23'b00000000000000000000000; // "MOV"
inst_info2[34] = 23'b00000000000000000000000; // "MOV"
inst_info2[35] = 23'b00000000000000000000000; // "MOV"
inst_info2[36] = 23'b00000000000000000000000; // "NULL"
inst_info2[37] = 23'b00000000000000000000000; // "NULL"
inst_info2[38] = 23'b00000000000000000000000; // "NULL"
inst_info2[39] = 23'b00000000000000000000000; // "NULL"
inst_info2[40] = 23'b00000000000000000000000; // "VEC"
inst_info2[41] = 23'b00000000000000000000000; // "VEC"
inst_info2[42] = 23'b00000000000000000000000; // "VEC"
inst_info2[43] = 23'b00000000000000000000000; // "VEC"
inst_info2[44] = 23'b00000000000000000000000; // "VEC"
inst_info2[45] = 23'b00000000000000000000000; // "VEC"
inst_info2[46] = 23'b00000000000000000000000; // "VEC"
inst_info2[47] = 23'b00000000000000000000000; // "VEC"
inst_info2[48] = 23'b00000000000000000000000; // "WRMSR"
inst_info2[49] = 23'b00000000000000000000000; // "RDTSC"
inst_info2[50] = 23'b00000000000000000000000; // "RDMSR"
inst_info2[51] = 23'b00000000000000000000000; // "RDPMC"
inst_info2[52] = 23'b00000000000000000000000; // "SYSENTER"
inst_info2[53] = 23'b00000000000000000000000; // "SYSEXIT"
inst_info2[54] = 23'b00000000000000000000000; // "NULL"
inst_info2[55] = 23'b00000000000000000000000; // "GETSEC"
inst_info2[56] = 23'b00000000000000000000000; // "ESC3"
inst_info2[57] = 23'b00000000000000000000000; // "NULL"
inst_info2[58] = 23'b00000000000000000000000; // "ESC3"
inst_info2[59] = 23'b00000000000000000000000; // "NULL"
inst_info2[60] = 23'b00000000000000000000000; // "NULL"
inst_info2[61] = 23'b00000000000000000000000; // "NULL"
inst_info2[62] = 23'b00000000000000000000000; // "NULL"
inst_info2[63] = 23'b00000000000000000000000; // "NULL"
inst_info2[64] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[65] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[66] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[67] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[68] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[69] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[70] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[71] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[72] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[73] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[74] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[75] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[76] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[77] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[78] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[79] = 23'b00000000000000000000000; // "CMOVcc"
inst_info2[80] = 23'b00000000000000000000000; // "VEC"
inst_info2[81] = 23'b00000000000000000000000; // "VEC"
inst_info2[82] = 23'b00000000000000000000000; // "VEC"
inst_info2[83] = 23'b00000000000000000000000; // "VEC"
inst_info2[84] = 23'b00000000000000000000000; // "VEC"
inst_info2[85] = 23'b00000000000000000000000; // "VEC"
inst_info2[86] = 23'b00000000000000000000000; // "VEC"
inst_info2[87] = 23'b00000000000000000000000; // "VEC"
inst_info2[88] = 23'b00000000000000000000000; // "VEC"
inst_info2[89] = 23'b00000000000000000000000; // "VEC"
inst_info2[90] = 23'b00000000000000000000000; // "VEC"
inst_info2[91] = 23'b00000000000000000000000; // "VEC"
inst_info2[92] = 23'b00000000000000000000000; // "VEC"
inst_info2[93] = 23'b00000000000000000000000; // "VEC"
inst_info2[94] = 23'b00000000000000000000000; // "VEC"
inst_info2[95] = 23'b00000000000000000000000; // "VEC"
inst_info2[96] = 23'b00000000000000000000000; // "VEC"
inst_info2[97] = 23'b00000000000000000000000; // "VEC"
inst_info2[98] = 23'b00000000000000000000000; // "VEC"
inst_info2[99] = 23'b00000000000000000000000; // "VEC"
inst_info2[100] = 23'b00000000000000000000000; // "VEC"
inst_info2[101] = 23'b00000000000000000000000; // "VEC"
inst_info2[102] = 23'b00000000000000000000000; // "VEC"
inst_info2[103] = 23'b00000000000000000000000; // "VEC"
inst_info2[104] = 23'b00000000000000000000000; // "VEC"
inst_info2[105] = 23'b00000000000000000000000; // "VEC"
inst_info2[106] = 23'b00000000000000000000000; // "VEC"
inst_info2[107] = 23'b00000000000000000000000; // "VEC"
inst_info2[108] = 23'b00000000000000000000000; // "VEC"
inst_info2[109] = 23'b00000000000000000000000; // "VEC"
inst_info2[110] = 23'b00000000000000000000000; // "movd"
inst_info2[111] = 23'b00000000000000000000000; // "movq"
inst_info2[112] = 23'b00000000000000000000000; // "VEC"
inst_info2[113] = 23'b00000000000000000000000; // "VEC"
inst_info2[114] = 23'b00000000000000000000000; // "VEC"
inst_info2[115] = 23'b00000000000000000000000; // "VEC"
inst_info2[116] = 23'b00000000000000000000000; // "VEC"
inst_info2[117] = 23'b00000000000000000000000; // "VEC"
inst_info2[118] = 23'b00000000000000000000000; // "VEC"
inst_info2[119] = 23'b00000000000000000000000; // "VEC"
inst_info2[120] = 23'b00000000000000000000000; // "VEC"
inst_info2[121] = 23'b00000000000000000000000; // "VEC"
inst_info2[122] = 23'b00000000000000000000000; // "VEC"
inst_info2[123] = 23'b00000000000000000000000; // "VEC"
inst_info2[124] = 23'b00000000000000000000000; // "VEC"
inst_info2[125] = 23'b00000000000000000000000; // "VEC"
inst_info2[126] = 23'b00000000000000000000000; // "movd"
inst_info2[127] = 23'b00000000000000000000000; // "movq"
inst_info2[128] = 23'b00000000000000000000000; // "J"
inst_info2[129] = 23'b00000000000000000000000; // "J"
inst_info2[130] = 23'b00000000000000000000000; // "J"
inst_info2[131] = 23'b00000000000000000000000; // "J"
inst_info2[132] = 23'b00000000000000000000000; // "J"
inst_info2[133] = 23'b00000000000000000000000; // "J"
inst_info2[134] = 23'b00000000000000000000000; // "J"
inst_info2[135] = 23'b00000000000000000000000; // "J"
inst_info2[136] = 23'b00000000000000000000000; // "J"
inst_info2[137] = 23'b00000000000000000000000; // "J"
inst_info2[138] = 23'b00000000000000000000000; // "J"
inst_info2[139] = 23'b00000000000000000000000; // "J"
inst_info2[140] = 23'b00000000000000000000000; // "J"
inst_info2[141] = 23'b00000000000000000000000; // "J"
inst_info2[142] = 23'b00000000000000000000000; // "J"
inst_info2[143] = 23'b00000000000000000000000; // "J"
inst_info2[144] = 23'b00000000000000000000000; // "SET"
inst_info2[145] = 23'b00000000000000000000000; // "SET"
inst_info2[146] = 23'b00000000000000000000000; // "SET"
inst_info2[147] = 23'b00000000000000000000000; // "SET"
inst_info2[148] = 23'b00000000000000000000000; // "SET"
inst_info2[149] = 23'b00000000000000000000000; // "SET"
inst_info2[150] = 23'b00000000000000000000000; // "SET"
inst_info2[151] = 23'b00000000000000000000000; // "SET"
inst_info2[152] = 23'b00000000000000000000000; // "SET"
inst_info2[153] = 23'b00000000000000000000000; // "SET"
inst_info2[154] = 23'b00000000000000000000000; // "SET"
inst_info2[155] = 23'b00000000000000000000000; // "SET"
inst_info2[156] = 23'b00000000000000000000000; // "SET"
inst_info2[157] = 23'b00000000000000000000000; // "SET"
inst_info2[158] = 23'b00000000000000000000000; // "SET"
inst_info2[159] = 23'b00000000000000000000000; // "SET"
inst_info2[160] = 23'b00000000000000000000000; // "PUSH"
inst_info2[161] = 23'b00000000000000000000000; // "POP"
inst_info2[162] = 23'b00000000000000000000000; // "CPUID"
inst_info2[163] = 23'b00000000000000000000000; // "BT"
inst_info2[164] = 23'b00000000000000000000000; // "SHLD"
inst_info2[165] = 23'b00000000000000000000000; // "SHLD"
inst_info2[166] = 23'b00000000000000000000000; // "NULL"
inst_info2[167] = 23'b00000000000000000000000; // "NULL"
inst_info2[168] = 23'b00000000000000000000000; // "PUSH"
inst_info2[169] = 23'b00000000000000000000000; // "POP"
inst_info2[170] = 23'b00000000000000000000000; // "RSM"
inst_info2[171] = 23'b00000000000000000000000; // "BTS"
inst_info2[172] = 23'b00000000000000000000000; // "SHRD"
inst_info2[173] = 23'b00000000000000000000000; // "SHRD"
inst_info2[174] = 23'b00000000000000000000000; // "Grp15"
inst_info2[175] = 23'b00000000000000000000000; // "IMUL"
inst_info2[176] = 23'b00000000000000000000000; // "CMPXCHG"
inst_info2[177] = 23'b00000000000000000000000; // "CMPXCHG"
inst_info2[178] = 23'b00000000000000000000000; // "LSS"
inst_info2[179] = 23'b00000000000000000000000; // "BTR"
inst_info2[180] = 23'b00000000000000000000000; // "LFS"
inst_info2[181] = 23'b00000000000000000000000; // "LGS"
inst_info2[182] = 23'b00000000000000000000000; // "MOVZX"
inst_info2[183] = 23'b00000000000000000000000; // "MOVZX"
inst_info2[184] = 23'b00000000000000000000000; // "JMPE"
inst_info2[185] = 23'b00000000000000000000000; // "Grp10"
inst_info2[186] = 23'b00000000000000000000000; // "Grp8"
inst_info2[187] = 23'b00000000000000000000000; // "BTC"
inst_info2[188] = 23'b00000000000000000000000; // "BSF"
inst_info2[189] = 23'b00000000000000000000000; // "BSR"
inst_info2[190] = 23'b00000000000000000000000; // "MOVSX"
inst_info2[191] = 23'b00000000000000000000000; // "MOVSX"
inst_info2[192] = 23'b00000000000000000000000; // "XADD"
inst_info2[193] = 23'b00000000000000000000000; // "XADD"
inst_info2[194] = 23'b00000000000000000000000; // "VEC"
inst_info2[195] = 23'b00000000000000000000000; // "VEC"
inst_info2[196] = 23'b00000000000000000000000; // "VEC"
inst_info2[197] = 23'b00000000000000000000000; // "VEC"
inst_info2[198] = 23'b00000000000000000000000; // "VEC"
inst_info2[199] = 23'b00000000000000000000000; // "Grp9"
inst_info2[200] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[201] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[202] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[203] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[204] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[205] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[206] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[207] = 23'b00000000000000000000000; // "BSWAP"
inst_info2[208] = 23'b00000000000000000000000; // "VEC"
inst_info2[209] = 23'b00000000000000000000000; // "VEC"
inst_info2[210] = 23'b00000000000000000000000; // "VEC"
inst_info2[211] = 23'b00000000000000000000000; // "VEC"
inst_info2[212] = 23'b00000000000000000000000; // "VEC"
inst_info2[213] = 23'b00000000000000000000000; // "VEC"
inst_info2[214] = 23'b00000000000000000000000; // "VEC"
inst_info2[215] = 23'b00000000000000000000000; // "VEC"
inst_info2[216] = 23'b00000000000000000000000; // "VEC"
inst_info2[217] = 23'b00000000000000000000000; // "VEC"
inst_info2[218] = 23'b00000000000000000000000; // "VEC"
inst_info2[219] = 23'b00000000000000000000000; // "VEC"
inst_info2[220] = 23'b00000000000000000000000; // "VEC"
inst_info2[221] = 23'b00000000000000000000000; // "VEC"
inst_info2[222] = 23'b00000000000000000000000; // "VEC"
inst_info2[223] = 23'b00000000000000000000000; // "VEC"
inst_info2[224] = 23'b00000000000000000000000; // "VEC"
inst_info2[225] = 23'b00000000000000000000000; // "VEC"
inst_info2[226] = 23'b00000000000000000000000; // "VEC"
inst_info2[227] = 23'b00000000000000000000000; // "VEC"
inst_info2[228] = 23'b00000000000000000000000; // "VEC"
inst_info2[229] = 23'b00000000000000000000000; // "VEC"
inst_info2[230] = 23'b00000000000000000000000; // "VEC"
inst_info2[231] = 23'b00000000000000000000000; // "VEC"
inst_info2[232] = 23'b00000000000000000000000; // "VEC"
inst_info2[233] = 23'b00000000000000000000000; // "VEC"
inst_info2[234] = 23'b00000000000000000000000; // "VEC"
inst_info2[235] = 23'b00000000000000000000000; // "VEC"
inst_info2[236] = 23'b00000000000000000000000; // "VEC"
inst_info2[237] = 23'b00000000000000000000000; // "VEC"
inst_info2[238] = 23'b00000000000000000000000; // "VEC"
inst_info2[239] = 23'b00000000000000000000000; // "VEC"
inst_info2[240] = 23'b00000000000000000000000; // "VEC"
inst_info2[241] = 23'b00000000000000000000000; // "VEC"
inst_info2[242] = 23'b00000000000000000000000; // "VEC"
inst_info2[243] = 23'b00000000000000000000000; // "VEC"
inst_info2[244] = 23'b00000000000000000000000; // "VEC"
inst_info2[245] = 23'b00000000000000000000000; // "VEC"
inst_info2[246] = 23'b00000000000000000000000; // "VEC"
inst_info2[247] = 23'b00000000000000000000000; // "VEC"
inst_info2[248] = 23'b00000000000000000000000; // "VEC"
inst_info2[249] = 23'b00000000000000000000000; // "VEC"
inst_info2[250] = 23'b00000000000000000000000; // "VEC"
inst_info2[251] = 23'b00000000000000000000000; // "VEC"
inst_info2[252] = 23'b00000000000000000000000; // "VEC"
inst_info2[253] = 23'b00000000000000000000000; // "VEC"
inst_info2[254] = 23'b00000000000000000000000; // "VEC"
inst_info2[255] = 23'b00000000000000000000000; // "NULL"

if (inst_info2[1] == 0);
end

endmodule
