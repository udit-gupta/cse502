module Core (
	input[63:0] entry
,	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ Sysbus bus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
);
	enum { fetch_idle, fetch_waiting, fetch_active } fetch_state;
	logic[63:0] fetch_rip;
	logic[0:2*64*8-1] decode_buffer; // NOTE: buffer bits are left-to-right in increasing order
	logic[5:0] fetch_skip;
	logic[6:0] fetch_offset, decode_offset;
	logic[63:0] current_addr = entry[63:0];
	typedef enum { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15 } regname;
	logic[63:0] xreg[16];

	function logic mtrr_is_mmio(logic[63:0] physaddr);
		mtrr_is_mmio = ((physaddr > 640*1024 && physaddr < 1024*1024));
	endfunction

	logic send_fetch_req;
	always_comb begin
		if (fetch_state != fetch_idle) begin
			send_fetch_req = 0; // hack: in theory, we could try to send another request at this point
		end else if (bus.reqack) begin
			send_fetch_req = 0; // hack: still idle, but already got ack (in theory, we could try to send another request as early as this)
		end else begin
			send_fetch_req = (fetch_offset - decode_offset < 7'd32);
		end
	end

	assign bus.respack = bus.respcyc; // always able to accept response

	always @ (posedge bus.clk)
		if (bus.reset) begin

			fetch_state <= fetch_idle;
			fetch_rip <= entry & ~63;
			fetch_skip <= entry[5:0];
			fetch_offset <= 0;

			xreg[RAX] <= 64'hdeadbeefdeadbeef ; 
			xreg[RCX] <= 64'hdeadbeefdeadbeef ; 
			xreg[RDX] <= 64'hdeadbeefdeadbeef ; 
			xreg[RBX] <= 64'hdeadbeefdeadbeef ; 
			xreg[RSP] <= 64'hdeadbeefdeadbeef ; 
			xreg[RBP] <= 64'hdeadbeefdeadbeef ; 
			xreg[RSI] <= 64'hdeadbeefdeadbeef ; 
			xreg[RDI] <= 64'hdeadbeefdeadbeef ; 
			xreg[R8]  <= 64'hdeadbeefdeadbeef ; 
			xreg[R9]  <= 64'hdeadbeefdeadbeef ; 
			xreg[R10] <= 64'hdeadbeefdeadbeef ; 
			xreg[R11] <= 64'hdeadbeefdeadbeef ; 
			xreg[R12] <= 64'hdeadbeefdeadbeef ; 
			xreg[R13] <= 64'hdeadbeefdeadbeef ; 
			xreg[R14] <= 64'hdeadbeefdeadbeef ; 
			xreg[R15] <= 64'hdeadbeefdeadbeef ; 

		end else begin // !bus.reset

			bus.reqcyc <= send_fetch_req;
			bus.req <= fetch_rip & ~63;
			bus.reqtag <= { bus.READ, bus.MEMORY, 8'b0 };

			if (bus.respcyc) begin
				assert(!send_fetch_req) else $fatal;
				fetch_state <= fetch_active;
				fetch_rip <= fetch_rip + 8;
				if (fetch_skip > 0) begin
					fetch_skip <= fetch_skip - 8;
				end else begin
					decode_buffer[fetch_offset*8 +: 64] <= bus.resp;
					//$display("fill at %d: %x [%x]", fetch_offset, bus.resp, decode_buffer);
					fetch_offset <= fetch_offset + 8;
				end
			end else begin
				if (fetch_state == fetch_active) begin
					fetch_state <= fetch_idle;
				end else if (bus.reqack) begin
					assert(fetch_state == fetch_idle) else $fatal;
					fetch_state <= fetch_waiting;
				end
			end

		end

	wire[0:(128+15)*8-1] decode_bytes_repeated = { decode_buffer, decode_buffer[0:15*8-1] }; // NOTE: buffer bits are left-to-right in increasing order
	wire[0:15*8-1] decode_bytes = decode_bytes_repeated[decode_offset*8 +: 15*8]; // NOTE: buffer bits are left-to-right in increasing order
	wire can_decode = (fetch_offset - decode_offset >= 7'd15);

	function logic opcode_inside(logic[7:0] value, low, high);
		opcode_inside = (value >= low && value <= high);
	endfunction

	logic[3:0] bytes_decoded_this_cycle;

	typedef logic[63:0] mystring;
	mystring op[0:255];
	mystring op2[0:255];
	logic [255:0] ModRM;
	logic [255:0] ModRM2;
	logic[359:0] opcode_stream;
	logic[255:0] mnemonic_stream;
	logic[22:0] inst_info[255];
	logic[63:0] oper1;
	logic[63:0] oper2;
	logic[7:0] oper;
	logic[63:0] alu_res;
	logic[63:0] src_vl;
	logic[63:0] dest_vl;
	logic[1:0] src_sz;
	logic[1:0] dest_sz;
	logic[7:0] opern;
	logic[1:0] numop;

	typedef enum {
		REGISTER,
		MEOMORY,
		IMM
	} operand_t;

	operand_t src_ty;
	operand_t dest_ty;
	Opcodes opc(op,ModRM);
	Opcodes2 opc2(op2,ModRM2);
	InstrnInfo iinfo(inst_info);


	//Decoder D(bytes_decoded_this_cycle, bus, opcode_stream, mnemonic_stream, current_addr, decode_bytes,op,op2,ModRM,ModRM2);
	ALU alu(alu_res,oper1,oper2,oper);
	Decoder2 D(bytes_decoded_this_cycle, opcode_stream, mnemonic_stream, current_addr, decode_bytes,op,op2,ModRM,ModRM2,inst_info);

	always_comb begin
		//$display("can_decode: %x, decode_offset: %x, fetch_offset: %x", can_decode, decode_offset, fetch_offset);
		if (can_decode) begin : decode_block
			// cse502 : Decoder here
			// remove the following line. It is only here to allow successful compilation in the absence of your code.
//			if (decode_bytes == 0) ;
			bytes_decoded_this_cycle = 0;
	//		$display("\n");
	//		$display("Buffer =>: 0x%x", decode_bytes);
			//bytes_decoded_this_cycle = 4'b1111;

			if (decode_bytes[0:119] == 120'b0 ) begin 
				$finish;
			end
			else begin 

			D.decode(bytes_decoded_this_cycle,opern,numop,src_ty,dest_ty,src_vl,dest_vl,src_sz,dest_sz);
	//		$display("bytes_decoded_this_cycle : %d", bytes_decoded_this_cycle); 
	//		$display("bytes_decoded_this_cycle : %d", bytes_decoded_this_cycle); 
		

			if (ModRM[255:0] == 0);
			if (ModRM2[255:0] == 0);
			if (inst_info[22:0] == 0);
			if (mnemonic_stream[255:0] == 0);
			if (opcode_stream[359:0] == 0);
			if (alu_res[63:0] == 0);
			if (src_vl == 0);
			if (dest_vl == 0);
			if (src_ty == 0);
			if (dest_ty == 0);
			if (src_sz == 0);
			if (dest_sz == 0);
			if (opern == 0);
			if (numop == 0);

			// cse502 : following is an example of how to finish the simulation
	//		$display("decode_bytes: %x", decode_bytes);
	//		$display("fetch_state: %x", fetch_idle);
			//if (decode_bytes == 0 && fetch_state == fetch_idle) $finish;
			//if (decode_bytes[0:119] == 120'b0 || fetch_state == fetch_idle) $finish;
			//if (decode_bytes[0:119] == 120'b0 ) $finish;
			end
		end else begin
			bytes_decoded_this_cycle = 0;
		end
	end

	always @ (posedge bus.clk)
		if (bus.reset) begin

			decode_offset <= 0;
			decode_buffer <= 0;
			current_addr <= entry;
			oper1 <= 0;
			oper2 <= 0;
			oper <= 0;

		end else begin // !bus.reset

			decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
			current_addr <= current_addr + { 60'b0, bytes_decoded_this_cycle };
//			$display("Buffer =>: 0x%x", decode_bytes);
//			$display("Offset after: %x", decode_offset);
//			$display(" < ---------------------------------------------------------------------------------------------- > ");
			oper <= 8'h2A;
			oper1 <= 64'd12;
			oper2 <= 64'd23;
				
			//$display("%x: %s %s", current_addr[63:0], opcode_stream[359:0],mnemonic_stream[255:0]); 
			//$display("ALU Result: %b", alu_res);
		end

	// cse502 : Use the following as a guide to print the Register File contents.
	final begin
		$display("RAX = %x", xreg[RAX]);
		$display("RBX = %x", xreg[RBX]);
		$display("RCX = %x", xreg[RCX]);
		$display("RDX = %x", xreg[RDX]);
		$display("RSI = %x", xreg[RSI]);
		$display("RDI = %x", xreg[RDI]);
		$display("RBP = %x", xreg[RBP]);
		$display("RSP = %x", xreg[RSP]);
		$display("R8 = %x", xreg[R8]);
		$display("R9 = %x", xreg[R9]);
		$display("R10 = %x", xreg[R10]);
		$display("R11 = %x", xreg[R11]);
		$display("R12 = %x", xreg[R12]);
		$display("R13 = %x", xreg[R13]);
		$display("R14 = %x", xreg[R14]);
		$display("R15 = %x", xreg[R15]);
	end
endmodule
