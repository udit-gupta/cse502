module Decoder(
	output logic[3:0] byte_incr, 
	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ 
	Sysbus bus
	/* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
	,
    input logic[0:15*8-1] buffer_stream);

logic[0:15*8-1] buffer;

typedef enum {
	UNDEFINED=3'b000,
	LEGACY_PREFIX=3'b001, REX_PREFIX=3'b010, OPCODE=3'b011, 
	MOD_RM=3'b100, SIB=3'b101, DISPLACEMENT=3'b110, IMMEDIATE=3'b111
} inst_field_t; 

inst_field_t inst_field;

always_comb begin
	inst_field = LEGACY_PREFIX;
	//byte_incr = 4'd15;
	//$display("B: 0x%x", buffer_stream);
	//decode(byte_incr); 
	if (inst_field == LEGACY_PREFIX);
	if (buffer_stream == 0);
end

always @ (posedge bus.clk) begin
	if (bus.reset) begin
		buffer <= 0;
	end
	else begin
		buffer <= buffer_stream;
	end
end
task advance;
	output logic[3:0] incr;

	begin
		incr = 15;
		if (buffer == 0);
		if (inst_field == 0);
	end
endtask

task check_legacy_prefix;
	output logic[3:0] next_byte_offset;
	output inst_field_t next_field_type;
	input logic[3:0] inst_byte_offset;

	begin
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
			default: $display("Not a legacy instruction prefix");
		endcase

		next_byte_offset = inst_byte_offset + 1;
		next_field_type = LEGACY_PREFIX;
	end
endtask

task decode;
	output logic[3:0] increment_by;
	logic[3:0] inst_byte_off;
	inst_field_t next_fld_type;

	begin
		increment_by = 0;
		next_fld_type = LEGACY_PREFIX;
		inst_byte_off = 0;
		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX )
			check_legacy_prefix(increment_by,next_fld_type,inst_byte_off);
		byte_incr = increment_by;
	end
endtask

endmodule
