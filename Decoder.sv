module Decoder(
	output logic[3:0] byte_incr, 
	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ 
	Sysbus bus
	/* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
	,
    input logic[0:15*8-1] buffer,
	input logic[63:0] op[0:255],
	input logic[63:0] op2[0:255],
	input logic[255:0] ModRM,
	input logic[255:0] ModRM2
);

logic[0:15*8-1] buffer;
logic [3:0] rex_bits;
logic [0:0] RM;

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
		$display("Byte: 0x%x", buffer[inst_byte_offset*8 +: 8]);
		case (buffer[inst_byte_offset*8 +: 8])
			8'hF0: $display("Group 1: lock prefix");
			8'hF2: $display("Group 1: REPNE/REPNZ");
			8'hF3: $display("Group 1: REPE/REPZ");
			8'h2E: $display("Group 2: CS segement override prefix / branch not taken");
			8'h36: $display("Group 2: SS segment override prefix");
			8'h3E: $display("Group 2: DS segment override prefix");
			8'h26: $display("Group 2: ES segment override prefix / branch taken hint");
			8'h64: $display("Group 2: FS segment override prefix");
			8'h65: $display("Group 2: GS segment override prefix");
			8'h66: $display("Group 3: operand size override prefix");
			8'h67: $display("Group 4: address override prefix");
			default: begin
				$display("Not a legacy instruction prefix");
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
	logic [3:0] rex_identifier;
	logic[3:0] inc;

	begin
		inc = 4'd1; 
		$display("Byte: 0x%x", buffer[inst_byte_offset*8 +: 8]);
		ibyte = buffer[inst_byte_offset*8 +: 8];
		rex_identifier[3:0] = ibyte[7:4];
		rex_bits[3:0] = ibyte[3:0];

		if (rex_identifier == 4'b0100) begin
			$display("REX prefix");
			if (rex_bits[3] == 1'b1)
				$display("REX: 64 bit operand size");
			if (rex_bits[2] == 1'b1)
				$display("REX: Mod R/M reg field");
			if (rex_bits[1] == 1'b1)
				$display("REX: SIB extension field present");
			if (rex_bits[0] == 1'b1)
				$display("REX: ModR/M or SIB or Opcode reg");
		end
		else begin
			$display("Not a REX prefix");
			inc = 4'd0;
		end

		next_byte_offset = inst_byte_offset + inc;
		next_field_type = OPCODE;
	end
endtask


task check_opcode;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;

	begin
		inc = 1;
        if (buffer[inst_byte_offset*8 +: 8]==8'h0f) begin
            inst_byte_offset=inst_byte_offset+1;
			inc = inc + 1;
		    $display("Opcode 2: 0x%x", buffer[inst_byte_offset*8 +: 8]);	
		    $display("Opcode 2: %s", op2[buffer[inst_byte_offset*8 +: 8]]);	
			RM = ModRM2[255-buffer[inst_byte_offset*8 +: 8]];
        end
        else begin 
		    $display("Opcode 1: 0x%x", buffer[inst_byte_offset*8 +: 8]);	
		    $display("Opcode 1: %s", op[buffer[inst_byte_offset*8 +: 8]]);	
			RM = ModRM[255-buffer[inst_byte_offset*8 +: 8]];
	    end
		if (RM) begin
			$display("ModRM present");
			next_field_type = MOD_RM;
		end
		else begin
			$display("ModRM absent");
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
	logic[7:0] modrm;

	begin
		inc = 1;
		modrm=buffer[inst_byte_offset*8 +: 8];
		if(modrm[7:6] == 2'b11) begin
			$display("Register Register Addressing (No Memory Operand); REX.X not used");
		end
		else begin
			$display("Memory Addressing without an SIB Byte, REX.X Not Used");
		end
		$display("Register Name : %x",{rex_bits[2],modrm[5:3]});
		
		if(modrm[2:0] == 3'b100) begin
				next_field_type = SIB;
				$display("/hello1");
		end
		else begin
				next_field_type = LEGACY_PREFIX;
				$display("/hello2");
		end

		$display("/hello3");
		next_byte_offset = inst_byte_offset + inc;
	end
endtask


task check_sib;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;
	logic[3:0] inc;

	begin
		inc = 1;
		$display("check sib");
        next_byte_offset = inst_byte_offset + inc;
		next_field_type = LEGACY_PREFIX;
		$display("Next Byte Offset: %d , Inst_byte_offset: %d, inc:%d ",next_byte_offset,inst_byte_offset,inc);
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
		next_fld_type = LEGACY_PREFIX;
//		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX )
//			check_legacy_prefix(increment_by,next_fld_type,inst_byte_off);
//		if ((next_fld_type & REX_PREFIX) == REX_PREFIX )
//			check_rex_prefix(increment_by,next_fld_type,inst_byte_off+increment_by);
//		if ((next_fld_type & OPCODE) == OPCODE )
//			check_opcode(increment_by,next_fld_type,inst_byte_off+increment_by);	
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
			offs7=offs5;
		end

		if ((next_fld_type & SIB) == SIB ) begin
			$display("First run");
			check_sib(offs6,next_fld_type,offs5);
			$display("Second run");
			offs7=offs6;
		end
		
		increment_by = offs7;
		byte_incr = increment_by;
	end
endtask

endmodule
