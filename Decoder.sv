module Decoder(
	output logic[3:0] byte_incr, 
	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ 
	Sysbus bus
	/* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
	,
	output logic[191:0] opcode_stream,
    output logic[255:0] mnemonic_stream,
    input logic[0:15*8-1] buffer,
	input logic[63:0] op[0:255],
	input logic[63:0] op2[0:255],
	input logic[255:0] ModRM,
	input logic[255:0] ModRM2
);

logic[0:15*8-1] buffer;
logic [3:0] rex_bits;
logic[7:0] modrm;
//logic [0:0] RR_addr;
logic [0:0] RM;
// Output strings
logic [7:0] optr;
logic [7:0] mptr;

typedef enum {
	UNDEFINED=3'b000,
	LEGACY_PREFIX=3'b001, REX_PREFIX=3'b010, OPCODE=3'b011, 
	MOD_RM=3'b100, SIB=3'b101, DISPLACEMENT=3'b110, IMMEDIATE=3'b111
} inst_field_t; 


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
		next_field_type = REX_PREFIX;
	end
endtask

task check_rex_prefix;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[7:0] ibyte;
	logic[15:0] out;
	logic[3:0] inc;

	begin
		inc = 4'd1; 
		// $display("Byte: 0x%x", buffer[inst_byte_offset*8 +: 8]);
		ibyte[7:0] = buffer[inst_byte_offset*8 +: 8];

		if (ibyte[7:4] == 4'b0100) begin
			// $display("REX prefix");
//			if (rex_bits[3] == 1'b1)
//				$display("REX: 64 bit operand size");
//			if (rex_bits[2] == 1'b1)
//				$display("REX: Mod R/M reg field");
//			if (rex_bits[1] == 1'b1)
//				$display("REX: SIB extension field present");
//			if (rex_bits[0] == 1'b1)
//				$display("REX: ModR/M or SIB or Opcode reg");
			rex_bits[3:0] = ibyte[3:0];
			inc = 4'd1;
			toascii(out,ibyte[7:0]);
			opcode_stream[191-optr*8 -: 16] = out;
			optr = optr + 3;
		end
		else begin
			// $display("Not a REX prefix");
			inc = 4'd0;
			rex_bits[3:0] = 4'b0;
		end

		next_byte_offset = inst_byte_offset + inc;
		next_field_type = OPCODE;
		if (rex_bits[3] == 0);
	end
endtask


task check_opcode;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;
	logic[15:0] out1;
	logic[15:0] out2;

	begin
		inc = 1;
        if (buffer[inst_byte_offset*8 +: 8]==8'h0f) begin
            inst_byte_offset=inst_byte_offset+1;
			inc = inc + 1;
		    //$display("Opcode 2: 0x%x", buffer[inst_byte_offset*8 +: 8]);	
		    //$display("Opcode 2: %s", op2[buffer[inst_byte_offset*8 +: 8]]);	
			toascii(out1,8'h0f);
			opcode_stream[191-optr*8 -: 16] = out1; 
			optr = optr + 3;
			toascii(out2,buffer[inst_byte_offset*8 +: 8]);	
			opcode_stream[191-optr*8 -: 16] = out2; 
			mnemonic_stream[optr*8 +: 64] = op2[buffer[inst_byte_offset*8 +: 8]] ;
			optr = optr + 3;
			mptr = mptr + 8;
			RM = ModRM2[255-buffer[inst_byte_offset*8 +: 8]];
        end
        else begin 
		    //$display("Opcode 1: 0x%x", buffer[inst_byte_offset*8 +: 8]);	
		    //$display("Opcode 1: %s", op[buffer[inst_byte_offset*8 +: 8]]);	
			toascii(out1,buffer[inst_byte_offset*8 +: 8]);	
			opcode_stream[191-optr*8 -: 16] = out1;
			mnemonic_stream[optr*8 +: 64] = op[buffer[inst_byte_offset*8 +: 8]] ;
			optr = optr + 3;
			mptr = mptr + 8;
			RM = ModRM[255-buffer[inst_byte_offset*8 +: 8]];
	    end
		if (RM) begin
			//$display("ModRM present");
			next_field_type = MOD_RM;
		end
		else begin
			//$display("ModRM absent");
			next_field_type = LEGACY_PREFIX;
		end
        next_byte_offset = inst_byte_offset + inc;
    end
endtask 


task check_modrm;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;
	logic[15:0] out1;

	begin
		inc = 1;
		modrm=buffer[inst_byte_offset*8 +: 8];
		toascii(out1,modrm);	
		opcode_stream[191-optr*8 -: 16] = out1;
		optr = optr + 3;
	/*	if(modrm[7:6] == 2'b11) begin
		//	$display("Register Register Addressing (No Memory Operand); REX.X not used");
			//RR_addr[0] = 1'b1;
		end
		else begin
		//	$display("Memory Addressing without an SIB Byte, REX.X Not Used");
			//RR_addr[0] = 1'b0;
		end
	*/	//$display("Register Name : %x",{rex_bits[2],modrm[5:3]});
	
		if(rex_bits[2]);
		if(modrm[2:0] == 3'b100) begin
				next_field_type = SIB;
		end
		else begin
				next_field_type = LEGACY_PREFIX;
		end

		next_byte_offset = inst_byte_offset + inc;
	end
endtask


task check_sib;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;
	logic[7:0] sib;
	logic[1:0] scale;
	logic[3:0] index;
	logic[3:0] base;
	logic[2:0] num_disp_bytes;
	logic[31:0] disp;
	logic[31:0] scale_factor;
	logic[31:0] byte_off;

	begin
		inc = 1;
		byte_off[31:0]={28'b0,inst_byte_offset};
		sib = buffer[inst_byte_offset*8 +: 8];
		inc = inc + 1;

		scale[1:0] = (1 << sib[7:6]);
		index[3:0] = {rex_bits[1], sib[5:3]};
		base[3:0] = {rex_bits[0], sib[2:0]};
			
	//	 $display("scale: b%b", scale);
	//	 $display("index: b%b", index);
	//	 $display("base : b%b", base);
		if(base[3]==0);  // TO be removed

		if (modrm[7:6] == 2'b00 ) begin
			if (index[3:0] == 4'b0100 ) begin
				if (base[2:0] == 3'b101 ) begin
					num_disp_bytes[2:0] = 3'b100;
					disp[31:0] = buffer[(byte_off+32'b1)*8 +: 32]; 
					scale_factor = disp[31:0]; 
					inc = inc + num_disp_bytes;
				end
				else begin
					num_disp_bytes[2:0] = 3'b000;
					disp[31:0] = 0; 
					scale_factor[31:0] = {29'b0,base[2:0]}; 
					inc = inc + num_disp_bytes;
				end
			end
			else begin
				if (base[2:0] == 3'b101 ) begin
					num_disp_bytes[2:0] = 3'b100;
					disp[31:0] = buffer[(byte_off+32'b1)*8 +: 32]; 
					scale_factor[31:0] = (index[2:0] * scale[1:0]) + disp[31:0]; 
					inc = inc + num_disp_bytes;
				end
				else begin
					num_disp_bytes[2:0] = 3'b000;
					disp[31:0] = 32'b0; 
					scale_factor[31:0] = (index[2:0] * scale[1:0]) + {29'b0,base[2:0]}; 
					inc = inc + num_disp_bytes;
				end
			end
		end 
		else if (modrm[7:6] == 2'b01 ) begin
			if (index[3:0] == 4'b0100 ) begin
				num_disp_bytes[2:0] = 3'b001;
				disp[31:0] = {24'b0, buffer[(byte_off+32'b1)*8 +: 8]}; 
				scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]}; 
				inc = inc + num_disp_bytes;
			end
			else begin
				num_disp_bytes[2:0] = 3'b001;
				disp[31:0] = {24'b0, buffer[(byte_off+32'b1)*8 +: 8]}; 
				scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]} +(index[2:0] * scale[1:0]) ; 
				inc = inc + num_disp_bytes;
			end
		end
		else if (modrm[7:6] == 2'b10 ) begin
			if (index[3:0] == 4'b0100 ) begin
				num_disp_bytes[2:0] = 3'b100;
				disp[31:0] = buffer[(byte_off+1)*8 +: 32]; 
				scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]}; 
				inc = inc + num_disp_bytes;
			end
			else begin
				num_disp_bytes[2:0] = 3'b100;
				disp[31:0] = buffer[(byte_off+1)*8 +: 32]; 
				scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]} + (index[2:0] * scale[1:0]) ; 
				inc = inc + num_disp_bytes;
			end
		end 
		else begin

		end


		if (scale_factor == 0);

        next_byte_offset = inst_byte_offset + inc;
		next_field_type = LEGACY_PREFIX;
	//	$display("Next Byte Offset: %d , Inst_byte_offset: %d, inc:%d ",next_byte_offset,inst_byte_offset,inc);
	//	$display("Scale factor: 0x%x", scale_factor[31:0]);
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
	inst_field_t next_fld_type;

	begin

		opcode_stream[191:0] = "                        ";
		mnemonic_stream[255:0] = "                                ";
		optr[7:0] = 8'b0;
		mptr[7:0] = 8'b0;
		next_fld_type = LEGACY_PREFIX;
		offs = 0;
		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX ) begin
			check_legacy_prefix(offs2,next_fld_type,offs);
		end

		if ((next_fld_type & REX_PREFIX) == REX_PREFIX ) begin
			check_rex_prefix(offs3,next_fld_type,offs2);
		end

		if ((next_fld_type & OPCODE) == OPCODE ) begin
			check_opcode(offs4,next_fld_type,offs3);
		end

		if ((next_fld_type & MOD_RM) == MOD_RM ) begin
			check_modrm(offs5,next_fld_type,offs4);
			offs7 = offs5;
		end

		if ((next_fld_type & SIB) == SIB ) begin
			check_sib(offs6,next_fld_type,offs5);
			offs7 = offs6;
		end
		
		increment_by = offs7;
		byte_incr = increment_by;

		if (mnemonic_stream == 0);
		if (opcode_stream[191:0] == 0);
	end
endtask

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

		

endmodule
