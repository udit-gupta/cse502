module Decoder2(
	output logic[3:0] byte_incr, 
	output logic[191:0] opcode_stream,
    output logic[255:0] mnemonic_stream,
	input logic[63:0] current_addr,
    input logic[0:15*8-1] buffer
);


// 'State' for the current instruction 
//logic signed[31:0] displacement;
//logic[4:0] dispsize;
//logic[31:0] ereg;
//logic[31:0] greg;
//logic[1:0] mod;
//logic[2:0] reg1;
//logic[2:0] rm;
//logic[255:0] immediate;
logic[0:15*8-1] buffer;
logic[7:0] instr;
//logic [3:0] rex_bits;
//logic[7:0] modrm;
////logic [0:0] RR_addr;
//logic [0:0] RM;
//// Output strings
logic [7:0] optr;
logic [7:0] mptr;
//logic [1:0] num_inst_bytes;

typedef enum {
	UNDEFINED=3'b000,
	LEGACY_PREFIX=3'b001, REX_PREFIX=3'b010, OPCODE=3'b011, 
	MOD_RM=3'b100, SIB=3'b101, DISPLACEMENT=3'b110, IMMEDIATE=3'b111
} inst_field_t; 



// TODO: Legacy prefix : no actions defined: low prioirity 

task check_legacy_prefix;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;

	begin
		inc = 4'd1;
//		$display("Byte: 0x%x", buffer[inst_byte_offset*8 +: 8]);
		case (buffer[inst_byte_offset*8 +: 8])
			8'hF0: /* $display("Group 1: lock prefix") */ ;
			8'hF2: /* $display("Group 1: REPNE/REPNZ") */ ;
			8'hF3: /* $display("Group 1: REPE/REPZ") */ ;
			8'h2E: /* $display("Group 2: CS segement override prefix / branch not taken") */ ;
			8'h36: /* $display("Group 2: SS segment override prefix") */ ;
			8'h3E: /* $display("Group 2: DS segment override prefix") */ ;
			8'h26: /* $display("Group 2: ES segment override prefix / branch taken hint") */ ;
			8'h64: /* $display("Group 2: FS segment override prefix") */ ;
			8'h65: /* $display("Group 2: GS segment override prefix") */ ;
			8'h66: /* $display("Group 3: operand size override prefix") */ ;
			8'h67: /* $display("Group 4: address override prefix") */ ;
			default: begin
				/* $display("Not a legacy instruction prefix") */ ;
				inc = 4'd0;
			end
		endcase

		next_byte_offset = inst_byte_offset + inc;
		next_field_type = REX_PREFIX | OPCODE;
	end
endtask


//task check_rex_prefix;
//	output logic[3:0] next_byte_offset;
//	output inst_field_t next_field_type;
//	input logic[3:0] inst_byte_offset;
////	logic[7:0] ibyte;
////	logic[15:0] out;
////	logic[3:0] inc;
//
//	begin
//		// Suppress the warnings
//		if (next_byte_offset[3:0] == 0);
//	end
//endtask


//task check_opcode;
//	output logic[3:0] next_byte_offset;
//	output inst_field_t next_field_type;
//	input logic[3:0] inst_byte_offset;
////	logic[3:0] inc;
////	logic[15:0] out1;
////	logic[15:0] out2;
//
//	begin
//		
//	end
//
//endtask
//
//
//task check_modrm;
//	output logic[3:0] next_byte_offset;
//	output inst_field_t next_field_type;
//	input logic[3:0] inst_byte_offset;
////	logic[3:0] inc;
////	logic[15:0] out1;
//
//endtask



task toascii;
	output logic[15:0] O;
	input logic[7:0] V;
	logic[7:0] N1;
	logic[7:0] N2;

	begin
		case ({4'b0,V[7:4]})
			8'h0: N1[7:0] = 8'h30;
			8'h1: N1[7:0] = 8'h31;
			8'h2: N1[7:0] = 8'h32;
			8'h3: N1[7:0] = 8'h33;
			8'h4: N1[7:0] = 8'h34;
			8'h5: N1[7:0] = 8'h35;
			8'h6: N1[7:0] = 8'h36;
			8'h7: N1[7:0] = 8'h37;
			8'h8: N1[7:0] = 8'h38;
			8'h9: N1[7:0] = 8'h39;
			8'ha: N1[7:0] = 8'h61;
			8'hb: N1[7:0] = 8'h62;
			8'hc: N1[7:0] = 8'h63;
			8'hd: N1[7:0] = 8'h64;
			8'he: N1[7:0] = 8'h65;
			8'hf: N1[7:0] = 8'h66;
			default: N1[7:0] = 8'b0;
		endcase

		case ({4'b0,V[3:0]})
			8'h0: N2[7:0] = 8'h30;
			8'h1: N2[7:0] = 8'h31;
			8'h2: N2[7:0] = 8'h32;
			8'h3: N2[7:0] = 8'h33;
			8'h4: N2[7:0] = 8'h34;
			8'h5: N2[7:0] = 8'h35;
			8'h6: N2[7:0] = 8'h36;
			8'h7: N2[7:0] = 8'h37;
			8'h8: N2[7:0] = 8'h38;
			8'h9: N2[7:0] = 8'h39;
			8'ha: N2[7:0] = 8'h61;
			8'hb: N2[7:0] = 8'h62;
			8'hc: N2[7:0] = 8'h63;
			8'hd: N2[7:0] = 8'h64;
			8'he: N2[7:0] = 8'h65;
			8'hf: N2[7:0] = 8'h66;
			default: N2[7:0] = 8'b0;
		endcase

		if(N1[7:4] == 0);
		if(N2[7:4] == 0);
		O = {N1[7:0], N2[7:0]};

	end
endtask



task decode;
	output logic[3:0] increment_by;
	logic[3:0] offs;
	logic[3:0] offs2;
	logic[3:0] offs3;
	logic[3:0] offs4;
	logic[3:0] offs5;
	logic[3:0] offs6;
	logic[3:0] offs7;
	logic[3:0] offs8;
	inst_field_t next_fld_type;

	begin
		instr[7:0] = 0;
		opcode_stream[191:0] = "                        ";
		mnemonic_stream[255:0] = "                                ";
		optr[7:0] = 8'b0;
		mptr[7:0] = 8'b0;
		next_fld_type = LEGACY_PREFIX;
		offs = 0;
		offs2 = offs;
		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX ) begin
			check_legacy_prefix(offs2,next_fld_type,offs);
		end

		offs3 = offs2;
//		if ((next_fld_type & REX_PREFIX) == REX_PREFIX ) begin
//			check_rex_prefix(offs3,next_fld_type,offs2);
//		end

		offs4 = offs3;
//		if ((next_fld_type & OPCODE) == OPCODE ) begin
//			check_opcode(offs4,next_fld_type,offs3);
//		end

		offs5 = offs4;
//		if ((next_fld_type & MOD_RM) == MOD_RM ) begin
//			check_modrm(offs5,next_fld_type,offs4);
//		end
		offs6 = offs5;

//		if ((next_fld_type & SIB) == SIB ) begin
//			check_sib(offs7,next_fld_type,offs6);
//		end
		offs7 = offs6;

//		if ((next_fld_type & DISPLACEMENT) == DISPLACEMENT) begin
//			check_disp(offs8,next_fld_type,offs7);
//		end
		offs8 = offs7;
		
        increment_by = offs8;
		byte_incr = increment_by;
	
//		if (num_inst_bytes == 2'b01)
//			decode_instr();
//		else
//			decode_instr2();

		// To suppress errors
		if (mnemonic_stream == 0);
		if (opcode_stream[191:0] == 0);
		if (instr[7:0] == 0);
		if (optr[7:0] == 0);
		if (mptr[7:0] == 0);
		if (current_addr == 0);	
	end

endtask

endmodule
