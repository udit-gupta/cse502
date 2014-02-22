module Decoder(
	output logic[3:0] byte_incr, 
	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ 
	Sysbus bus
	/* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
	,
	output logic[191:0] opcode_stream,
    output logic[255:0] mnemonic_stream,
	input logic[63:0] current_addr,
    input logic[0:15*8-1] buffer,
	input logic[63:0] op[0:255],
	input logic[63:0] op2[0:255],
	input logic[255:0] ModRM,
	input logic[255:0] ModRM2
);

logic signed[31:0] displacement;
logic[4:0] dispsize;
logic[31:0] ereg;
logic[31:0] greg;
logic[1:0] mod;
logic[2:0] reg1;
logic[2:0] rm;
//logic[255:0] immediate;
logic[0:15*8-1] buffer;
logic[7:0] instr;
logic [3:0] rex_bits;
logic[7:0] modrm;
//logic [0:0] RR_addr;
logic [0:0] RM;
// Output strings
logic [7:0] optr;
logic [7:0] mptr;
logic [1:0] num_inst_bytes;

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
		next_field_type = REX_PREFIX | OPCODE;
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
			num_inst_bytes[1:0] = 2'b10;
			instr[7:0] = buffer[inst_byte_offset*8 +: 8];
			toascii(out1,8'h0f);
			opcode_stream[191-optr*8 -: 16] = out1; 
			optr = optr + 3;
			toascii(out2,buffer[inst_byte_offset*8 +: 8]);	
			opcode_stream[191-optr*8 -: 16] = out2; 
			mnemonic_stream[255-mptr*8 -: 64] = op2[buffer[inst_byte_offset*8 +: 8]] ;
			optr = optr + 3;
			mptr = mptr + 8;
			RM = ModRM2[255-buffer[inst_byte_offset*8 +: 8]];
        end
        else begin 
		    //$display("Opcode 1: 0x%x", buffer[inst_byte_offset*8 +: 8]);	
		    //$display("Opcode 1: %s", op[buffer[inst_byte_offset*8 +: 8]]);	
			num_inst_bytes[1:0] = 2'b01;
			instr[7:0] = buffer[inst_byte_offset*8 +: 8];
			toascii(out1,buffer[inst_byte_offset*8 +: 8]);	
			opcode_stream[191-optr*8 -: 16] = out1;
			mnemonic_stream[255-mptr*8 -: 64] = op[buffer[inst_byte_offset*8 +: 8]] ;
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
	
        mod[1:0]=modrm[7:6];
        reg1[2:0]=modrm[5:3];
        rm[2:0]=modrm[2:0];

		case({rex_bits[2],reg1[2:0]}) 
            4'b0000: ereg[31:0]="%rax";
            4'b0001: ereg[31:0]="%rcx";
            4'b0010: ereg[31:0]="%rdx";
            4'b0011: ereg[31:0]="%rbx";
            4'b0100: ereg[31:0]="%rsp";
            4'b0101: ereg[31:0]="%rbp";
            4'b0110: ereg[31:0]="%rsi";
            4'b0111: ereg[31:0]="%rdi";
            4'b1000: ereg[31:0]="%r8";
            4'b1001: ereg[31:0]="%r9";
            4'b1010: ereg[31:0]="%r10";
            4'b1011: ereg[31:0]="%r11";
            4'b1100: ereg[31:0]="%r12";
            4'b1101: ereg[31:0]="%r13";
            4'b1110: ereg[31:0]="%r14";
            4'b1111: ereg[31:0]="%r15";
            default: ;
        endcase

		case({rex_bits[0],rm[2:0]}) 
            4'b0000: greg[31:0]="%rax";
            4'b0001: greg[31:0]="%rcx";
            4'b0010: greg[31:0]="%rdx";
            4'b0011: greg[31:0]="%rbx";
            4'b0100: greg[31:0]="%rsp";
            4'b0101: greg[31:0]="%rbp";
            4'b0110: greg[31:0]="%rsi";
            4'b0111: greg[31:0]="%rdi";
            4'b1000: greg[31:0]="%r8";
            4'b1001: greg[31:0]="%r9";
            4'b1010: greg[31:0]="%r10";
            4'b1011: greg[31:0]="%r11";
            4'b1100: greg[31:0]="%r12";
            4'b1101: greg[31:0]="%r13";
            4'b1110: greg[31:0]="%r14";
            4'b1111: greg[31:0]="%r15";
            default: ;
        endcase

        if(mod[1:0]==2'b00) begin
            if(rm[2:0]==3'b110) begin
                dispsize[4:0]=5'd16;
            end
            else begin
                dispsize[4:0]=5'd16;
            end
        end
        else if(mod[1:0]==2'b01) begin
            dispsize[4:0]=5'd8;
        end
        else if(mod[1:0]==2'b10) begin
            dispsize[4:0]=5'd16;
        end
        else begin
            dispsize[4:0]=5'd0;
        end

		if(reg1[2:0]==3'b000);   // 
		if(rex_bits[2:0]==3'b000);   // 
        
        
        next_field_type=LEGACY_PREFIX;
		if(mod[1:0]!=2'b11 && modrm[2:0] == 3'b100) begin
				next_field_type = next_field_type | SIB;
		end
    /*    if(dispsize[4:0]!=5'd0) begin
				$display("bye");
				next_field_type = next_field_type | DISPLACEMENT;
        end 
	*/	
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
	logic[15:0] out1;

	begin
		inc = 1;
		byte_off[31:0]={28'b0,inst_byte_offset};
		sib = buffer[inst_byte_offset*8 +: 8];
		toascii(out1,sib);	
		opcode_stream[191-optr*8 -: 16] = out1;
		optr = optr + 3;
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


task check_disp;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;
	logic[15:0] disp16_bytes;
	logic[7:0] disp8_bytes;
	logic[7:0] disp_opcode;
	logic[15:0] out1;
    
    begin
        inc=0;
		disp_opcode = buffer[inst_byte_offset*8 +: 8];
		toascii(out1,disp_opcode);	
		opcode_stream[191-optr*8 -: 16] = out1;
        if(dispsize==5'd16) begin
			optr = optr + 6;
            disp16_bytes[15:0]=$signed(buffer[inst_byte_offset*8 +: 16]);
            displacement[31:0] ={ {16{disp16_bytes[15]}} , disp16_bytes[15:0] };
            inc = inc + 4;
            next_byte_offset = inst_byte_offset + inc;
        end
        else if(dispsize==5'd8) begin
			optr = optr + 3;
            disp8_bytes[7:0]=$signed(buffer[inst_byte_offset*8 +: 8]);
            displacement[31:0] ={ {24{disp8_bytes[7]}} , disp8_bytes[7:0] };
            inc = inc + 1;
            next_byte_offset = inst_byte_offset + inc;
        end
        
        next_field_type=IMMEDIATE | LEGACY_PREFIX;
       //if(next_field_type[2:0]==3'b000) ;
       if(displacement[31:0]==32'd0) ;

    end    
endtask

task decode_instr;
	logic [63:0] immediate;
	logic [7:0] imm64_bytes;
	logic [63:0] imm;
	logic [7:0] imm_1byte;
	logic [15:0] out1;
	logic [15:0] out2;
	begin
		case (instr[7:0])
			8'h00: ;
			8'h01: ;
			8'h02: ;
			8'h03: ;
			8'h04: ;
			8'h05: ;
			8'h06: ;
			8'h07: ;
			8'h08: ;
			8'h09: ;
			8'h0a: ;
			8'h0b: ;
			8'h0c: ;
			8'h0d: ;
			8'h0e: ;
			8'h0f: ;
			8'h10: ;
			8'h11: ;
			8'h12: ;
			8'h13: ;
			8'h14: ;
			8'h15: ;
			8'h16: ;
			8'h17: ;
			8'h18: ;
			8'h19: ;
			8'h1a: ;
			8'h1b: ;
			8'h1c: ;
			8'h1d: ;
			8'h1e: ;
			8'h1f: ;
			8'h20: ;
			8'h21: ;
			8'h22: ;
			8'h23: ;
			8'h24: ;
			8'h25: ;
			8'h26: ;
			8'h27: ;
			8'h28: ;
			8'h29: ;
			8'h2a: ;
			8'h2b: ;
			8'h2c: ;
			8'h2d: ;
			8'h2e: ;
			8'h2f: ;
			8'h30: ;
			8'h31: 
				begin
					mptr = mptr + 4;
					mnemonic_stream[255-mptr*8 -: 32] = ereg[31:0];  
					mptr = mptr + 4;
					mnemonic_stream[255-mptr*8 -: 8] = ",";
					mptr = mptr + 1;
					mnemonic_stream[255-mptr*8 -: 32] = greg[31:0];
					mptr = mptr + 4;
					if (dispsize[4:0] != 5'b0) begin
					
					end 
				end
			8'h32: ;
			8'h33: ;
			8'h34: ;
			8'h35: ;
			8'h36: ;
			8'h37: ;
			8'h38: ;
			8'h39: ;
			8'h3a: ;
			8'h3b: ;
			8'h3c: ;
			8'h3d: ;
			8'h3e: ;
			8'h3f: ;
			8'h40: ;
			8'h41: ;
			8'h42: ;
			8'h43: ;
			8'h44: ;
			8'h45: ;
			8'h46: ;
			8'h47: ;
			8'h48: ;
			8'h49: ;
			8'h4a: ;
			8'h4b: ;
			8'h4c: ;
			8'h4d: ;
			8'h4e: ;
			8'h4f: ;
			8'h50: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rax"; 
						mptr = mptr + 5;
					end		
			8'h51: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rcx"; 
						mptr = mptr + 5;
					end		
			8'h52:
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rdx"; 
						mptr = mptr + 5;
					end		
			8'h53: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rbx"; 
						mptr = mptr + 5;
					end		
			8'h54:
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rsp"; 
						mptr = mptr + 5;
					end		
			8'h55:  
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rbp"; 
						mptr = mptr + 5;
					end		
			8'h56:
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rsi"; 
						mptr = mptr + 5;
					end		
			8'h57: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rdi"; 
						mptr = mptr + 5;
					end		
			8'h58: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rax"; 
						mptr = mptr + 5;
					end		
			8'h59:
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rcx"; 
						mptr = mptr + 5;
					end		
			8'h5a: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rdx"; 
						mptr = mptr + 5;
					end		
			8'h5b:
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rbx"; 
						mptr = mptr + 5;
					end		
			8'h5c:  
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rsp"; 
						mptr = mptr + 5;
					end		
			8'h5d:
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rbp"; 
						mptr = mptr + 5;
					end		
			8'h5e: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rsi"; 
						mptr = mptr + 5;
					end		
			8'h5f: 
					begin
						mnemonic_stream[255-mptr*8 -: 40] = " %rdi"; 
						mptr = mptr + 5;
					end		
			8'h60: ;
			8'h61: ;
			8'h62: ;
			8'h63: ;
			8'h64: ;
			8'h65: ;
			8'h66: ;
			8'h67: ;
			8'h68: ;
			8'h69: ;
			8'h6a: ;
			8'h6b: ;
			8'h6c: ;
			8'h6d: ;
			8'h6e: ;
			8'h6f: ;
			8'h70: 
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "O";
						mptr = mptr + 1;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h71:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NO";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h72: 
					begin
						mnemonic_stream[255-mptr*8 -: 24] = "NAE";
						mptr = mptr + 3;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h73: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "AE";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h74:
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "E";
						mptr = mptr + 1;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h75: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NE";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h76:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NA";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h77:
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "A";
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h78:
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "S";
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h79:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NS";
						mptr = mptr + 2;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h7a:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "PE";
						mptr = mptr + 2;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h7b: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "PO";
						mptr = mptr + 2;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h7c: 
					begin
						mnemonic_stream[255-mptr*8 -: 24] = "NGE";
						mptr = mptr + 3;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h7d: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "GE";
						mptr = mptr + 2;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h7e:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "LE";
						mptr = mptr + 2;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h7f:
					begin
						mnemonic_stream[255-mptr*8 -: 24] = "NLE";
						mptr = mptr + 3;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h80: ;
			8'h81: ;
			8'h82: ;
			8'h83: 
				begin
					case(reg1[2:0])
						3'b000: 
						mnemonic_stream[255-mptr*8 -: 24] = "ADD";
						3'b001:
						mnemonic_stream[255-mptr*8 -: 24] = "OR";
						3'b010:
						mnemonic_stream[255-mptr*8 -: 24] = "ADC";
						3'b011:
						mnemonic_stream[255-mptr*8 -: 24] = "SBB";
						3'b100:
						mnemonic_stream[255-mptr*8 -: 24] = "AND";
						3'b101:
						mnemonic_stream[255-mptr*8 -: 24] = "SUB";
						3'b110:
						mnemonic_stream[255-mptr*8 -: 24] = "XOR";
						3'b111:
						mnemonic_stream[255-mptr*8 -: 24] = "CMP";
					endcase
					mptr = mptr + 3;
					mptr = mptr + 1;
					mnemonic_stream[255-mptr*8 -: 32] = ereg[31:0];  
					mptr = mptr + 4;
					mnemonic_stream[255-mptr*8 -: 8] = ",";
					mptr = mptr + 1;
			
					//mnemonic_stream[255-mptr*8 -: 16]=out2[15:0];
					//mptr = mptr + 3;
					
					
            		imm64_bytes[7:0]=$signed(buffer[byte_incr*8 +: 8]);
            		immediate[63:0] ={ {56{imm64_bytes[7]}} , imm64_bytes[7:0] };

					for(int i=0;i<8;i++) begin
						toascii(out2,immediate[8*i +: 8]);
						$display("%s %d",out2,i);
						mnemonic_stream[255-mptr*8 -: 16]=out2[15:0];
						mptr = mptr + 2;
					end
					

					imm_1byte[7:0] =  buffer[byte_incr*8 +: 8];
					toascii(out1,imm_1byte);
					opcode_stream[191-optr*8 -: 16] = out1[15:0];
					optr = optr + 3;
					byte_incr = byte_incr + 1;
			end
			8'h84: ;
			8'h85: ;
			8'h86: ;
			8'h87: ;
			8'h88: ;
			8'h89: 
				begin
					mptr = mptr + 4;
					mnemonic_stream[255-mptr*8 -: 32] = ereg[31:0];  
					mptr = mptr + 4;
					mnemonic_stream[255-mptr*8 -: 8] = ",";
					mptr = mptr + 1;
					mnemonic_stream[255-mptr*8 -: 32] = greg[31:0];
					mptr = mptr + 4;
					if (dispsize[4:0] != 5'b0) begin
					
					end 
				end
			8'h8a: ;
			8'h8b: ;
			8'h8c: ;
			8'h8d: ;
			8'h8e: ;
			8'h8f: ;
/* NOP */	8'h90: ;
			8'h91: ;
			8'h92: ;
			8'h93: ;
			8'h94: ;
			8'h95: ;
			8'h96: ;
			8'h97: ;
			8'h98: ;
			8'h99: ;
			8'h9a: ;
			8'h9b: ;
			8'h9c: ;
			8'h9d: ;
			8'h9e: ;
			8'h9f: ;
			8'ha0: ;
			8'ha1: ;
			8'ha2: ;
			8'ha3: ;
			8'ha4: ;
			8'ha5: ;
			8'ha6: ;
			8'ha7: ;
			8'ha8: ;
			8'ha9: ;
			8'haa: ;
			8'hab: ;
			8'hac: ;
			8'had: ;
			8'hae: ;
			8'haf: ;
			8'hb0: ;
			8'hb1: ;
			8'hb2: ;
			8'hb3: ;
			8'hb4: ;
			8'hb5: ;
			8'hb6: ;
			8'hb7: ;
			8'hb8: ;
			8'hb9: ;
			8'hba: ;
			8'hbb: ;
			8'hbc: ;
			8'hbd: ;
			8'hbe: ;
			8'hbf: ;
			8'hc0: ;
			8'hc1: ;
			8'hc2: ;
/* retq */  8'hc3: ;
			8'hc4: ;
			8'hc5: ;
			8'hc6: ;
			8'hc7: ;
			8'hc8: ;
			8'hc9: ;
			8'hca: ;
			8'hcb: ;
			8'hcc: ;
			8'hcd: ;
			8'hce: ;
			8'hcf: ;
			8'hd0: ;
			8'hd1: ;
			8'hd2: ;
			8'hd3: ;
			8'hd4: ;
			8'hd5: ;
			8'hd6: ;
			8'hd7: ;
			8'hd8: ;
			8'hd9: ;
			8'hda: ;
			8'hdb: ;
			8'hdc: ;
			8'hdd: ;
			8'hde: ;
			8'hdf: ;
			8'he0: ;
			8'he1: ;
			8'he2: ;
			8'he3: ;
			8'he4: ;
			8'he5: ;
			8'he6: ;
			8'he7: ;
			8'he8: ;
			8'he9: ;
			8'hea: ;
			8'heb: ;
			8'hec: ;
			8'hed: ;
			8'hee: ;
			8'hef: ;
			8'hf0: ;
			8'hf1: ;
			8'hf2: ;
			8'hf3: ;
			8'hf4: ;
			8'hf5: ;
			8'hf6: ;
			8'hf7: ;
			8'hf8: ;
			8'hf9: ;
			8'hfa: ;
			8'hfb: ;
			8'hfc: ;
			8'hfd: ;
			8'hfe: ;
			8'hff: ;

		endcase
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
		offs2=offs;
		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX ) begin
			check_legacy_prefix(offs2,next_fld_type,offs);
		end

		offs3=offs2;
		if ((next_fld_type & REX_PREFIX) == REX_PREFIX ) begin
			check_rex_prefix(offs3,next_fld_type,offs2);
		end

		offs4=offs3;
		if ((next_fld_type & OPCODE) == OPCODE ) begin
			check_opcode(offs4,next_fld_type,offs3);
		end

		offs5=offs4;
		if ((next_fld_type & MOD_RM) == MOD_RM ) begin
			check_modrm(offs5,next_fld_type,offs4);
		end
		offs6=offs5;

		if ((next_fld_type & SIB) == SIB ) begin
			check_sib(offs7,next_fld_type,offs6);
		end
		offs7=offs6;

		if ((next_fld_type & DISPLACEMENT) == DISPLACEMENT) begin
			check_disp(offs8,next_fld_type,offs7);
		end
		offs8=offs7;
		
        increment_by = offs8;
		byte_incr = increment_by;
	
		if (num_inst_bytes == 2'b01)
			decode_instr();
		else
			decode_instr2();

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

		
task decode_instr2;
	logic [63:0] imm;
	begin
		case (instr[7:0])
			8'h00: ;
			8'h01: ;
			8'h02: ;
			8'h03: ;
			8'h04: ;
/*SYSCALL*/ 8'h05: ; 
			8'h06: ;
			8'h07: ;
			8'h08: ;
			8'h09: ;
			8'h0a: ;
			8'h0b: ;
			8'h0c: ;
			8'h0d: ;
			8'h0e: ;
			8'h0f: ;
			8'h10: ;
			8'h11: ;
			8'h12: ;
			8'h13: ;
			8'h14: ;
			8'h15: ;
			8'h16: ;
			8'h17: ;
			8'h18: ;
			8'h19: ;
			8'h1a: ;
			8'h1b: ;
			8'h1c: ;
			8'h1d: ;
			8'h1e: ;
			8'h1f: ;
			8'h20: ;
			8'h21: ;
			8'h22: ;
			8'h23: ;
			8'h24: ;
			8'h25: ;
			8'h26: ;
			8'h27: ;
			8'h28: ;
			8'h29: ;
			8'h2a: ;
			8'h2b: ;
			8'h2c: ;
			8'h2d: ;
			8'h2e: ;
			8'h2f: ;
			8'h30: ;
			8'h31: ;
			8'h32: ;
			8'h33: ;
			8'h34: ;
			8'h35: ;
			8'h36: ;
			8'h37: ;
			8'h38: ;
			8'h39: ;
			8'h3a: ;
			8'h3b: ;
			8'h3c: ;
			8'h3d: ;
			8'h3e: ;
			8'h3f: ;
			8'h40: ;
			8'h41: ;
			8'h42: ;
			8'h43: ;
			8'h44: ;
			8'h45: ;
			8'h46: ;
			8'h47: ;
			8'h48: ;
			8'h49: ;
			8'h4a: ;
			8'h4b: ;
			8'h4c: ;
			8'h4d: ;
			8'h4e: ;
			8'h4f: ;
			8'h50: ; 
			8'h51: ;
			8'h52: ;
			8'h53: ;
			8'h54: ;
			8'h55: ; 
			8'h56: ;
			8'h57: ;
			8'h58: ;
			8'h59: ;
			8'h5a: ;
			8'h5b: ;
			8'h5c: ; 
			8'h5d: ;
			8'h5e: ;
			8'h5f: ;
			8'h60: ;
			8'h61: ;
			8'h62: ;
			8'h63: ;
			8'h64: ;
			8'h65: ;
			8'h66: ;
			8'h67: ;
			8'h68: ;
			8'h69: ;
			8'h6a: ;
			8'h6b: ;
			8'h6c: ;
			8'h6d: ;
			8'h6e: ;
			8'h6f: ;
			8'h70: ;
			8'h71: ;
			8'h72: ;
			8'h73: ;
			8'h74: ;
			8'h75: ;
			8'h76: ;
			8'h77: ;
			8'h78: ;
			8'h79: ;
			8'h7a: ;
			8'h7b: ;
			8'h7c: ;
			8'h7d: ;
			8'h7e: ;
			8'h7f: ;
			8'h80: 
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "O";
						mptr = mptr + 1;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i>= 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*(i+1)-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h81:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NO";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h82: 
					begin
						mnemonic_stream[255-mptr*8 -: 24] = "NAE";
						mptr = mptr + 3;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h83: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "AE";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h84:
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "E";
						mptr = mptr + 1;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h85: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NE";
						mptr = mptr + 2;
						mptr = mptr + 1;

						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h86:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NA";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h87:
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "A";
						mptr = mptr + 1;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h88:
					begin
						mnemonic_stream[255-mptr*8 -: 8] = "S";
						mptr = mptr + 1;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h89:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "NS";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h8a:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "PE";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end		
			8'h8b: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "PO";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h8c: 
					begin
						mnemonic_stream[255-mptr*8 -: 24] = "NGE";
						mptr = mptr + 3;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h8d: 
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "GE";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h8e:
					begin
						mnemonic_stream[255-mptr*8 -: 16] = "LE";
						mptr = mptr + 2;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
			8'h8f:
					begin
						mnemonic_stream[255-mptr*8 -: 24] = "NLE";
						mptr = mptr + 3;
						mptr = mptr + 1;
						imm[63:0] = current_addr[63:0] + 64'd4;
						for (int i=8 ; i> 0 ; i--) begin
							toascii(mnemonic_stream[255-mptr*8 -: 16],imm[8*i-1 -: 8]);
							mptr = mptr + 2;
						end
					end
        	8'h90: ;
			8'h91: ;
			8'h92: ;
			8'h93: ;
			8'h94: ;
			8'h95: ;
			8'h96: ;
			8'h97: ;
			8'h98: ;
			8'h99: ;
			8'h9a: ;
			8'h9b: ;
			8'h9c: ;
			8'h9d: ;
			8'h9e: ;
			8'h9f: ;
			8'ha0: ;
			8'ha1: ;
			8'ha2: ;
			8'ha3: ;
			8'ha4: ;
			8'ha5: ;
			8'ha6: ;
			8'ha7: ;
			8'ha8: ;
			8'ha9: ;
			8'haa: ;
			8'hab: ;
			8'hac: ;
			8'had: ;
			8'hae: ;
			8'haf: ;
			8'hb0: ;
			8'hb1: ;
			8'hb2: ;
			8'hb3: ;
			8'hb4: ;
			8'hb5: ;
			8'hb6: ;
			8'hb7: ;
			8'hb8: ;
			8'hb9: ;
			8'hba: ;
			8'hbb: ;
			8'hbc: ;
			8'hbd: ;
			8'hbe: ;
			8'hbf: ;
			8'hc0: ;
			8'hc1: ;
			8'hc2: ;
            8'hc3: ;
			8'hc4: ;
			8'hc5: ;
			8'hc6: ;
			8'hc7: ;
			8'hc8: ;
			8'hc9: ;
			8'hca: ;
			8'hcb: ;
			8'hcc: ;
			8'hcd: ;
			8'hce: ;
			8'hcf: ;
			8'hd0: ;
			8'hd1: ;
			8'hd2: ;
			8'hd3: ;
			8'hd4: ;
			8'hd5: ;
			8'hd6: ;
			8'hd7: ;
			8'hd8: ;
			8'hd9: ;
			8'hda: ;
			8'hdb: ;
			8'hdc: ;
			8'hdd: ;
			8'hde: ;
			8'hdf: ;
			8'he0: ;
			8'he1: ;
			8'he2: ;
			8'he3: ;
			8'he4: ;
			8'he5: ;
			8'he6: ;
			8'he7: ;
			8'he8: ;
			8'he9: ;
			8'hea: ;
			8'heb: ;
			8'hec: ;
			8'hed: ;
			8'hee: ;
			8'hef: ;
			8'hf0: ;
			8'hf1: ;
			8'hf2: ;
			8'hf3: ;
			8'hf4: ;
			8'hf5: ;
			8'hf6: ;
			8'hf7: ;
			8'hf8: ;
			8'hf9: ;
			8'hfa: ;
			8'hfb: ;
			8'hfc: ;
			8'hfd: ;
			8'hfe: ;
			8'hff: ;

		endcase
	end

endtask

endmodule
