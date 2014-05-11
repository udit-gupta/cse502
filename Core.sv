module Core (
	input[63:0] entry,
	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ Sysbus bus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
);


//logic[63:0] block_offset;
//logic[6:0] offset;  ///
//wire[0:2*64*8-1] mem_buffer_repeated; ///

//    enum { fetch_idle, fetch_waiting, fetch_active } fetch_state;
	logic[63:0] fetch_rip;
	logic[0:2*64*8-1] decode_buffer; // NOTE: buffer bits are left-to-right in increasing order
//	logic[5:0] fetch_skip;
	logic[6:0] fetch_offset, decode_offset;
	logic[63:0] current_addr = entry[63:0];
	typedef enum { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15 } regname;
	reg[63:0] xreg[16];
	reg[63:0] wb_regx[16];

	function logic mtrr_is_mmio(logic[63:0] physaddr);
		mtrr_is_mmio = ((physaddr > 640*1024 && physaddr < 1024*1024));
	endfunction

	logic send_fetch_req;

/*
    always_comb begin
		if (fetch_state != fetch_idle) begin
			send_fetch_req = 0; // hack: in theory, we could try to send another request at this point
		end else if (bus.reqack) begin
			send_fetch_req = 0; // hack: still idle, but already got ack (in theory, we could try to send another request as early as this)
		end else begin
*/	assign send_fetch_req = 1;//(fetch_offset - decode_offset < 7'd32);
//		end
//	end

//	assign bus.respack = bus.respcyc; // always able to accept response

  //  assign block_offset = fetch_rip - ( fetch_rip & ~63 );
  //  assign offset[6:0]  = block_offset[6:0]; ///
 //   assign mem_buffer_repeated = { mem_buffer[0 +:64*8], 512'b0 }; ///
 //   assign fetch_buffer = mem_buffer_repeated[0*8 +: 512]; ///
	always @ (posedge bus.clk)
		if (bus.reset) begin

			fetch_rip <= entry & ~63;
		//	fetch_skip <= entry[5:0];
			fetch_offset <= 0;

		end else begin // !bus.reset

		//	bus.reqcyc <= send_fetch_req;
		//	bus.req <= fetch_rip & ~63;
		//	bus.reqtag <= { bus.READ, bus.MEMORY, 8'b0 };
        if(buf_offset2[6:0]==7'b0);
        
      //  if(block_offset[63:0]==64'b0);


        if(mem_req_completed) begin
             buf_offset <= 0;//num_bytes;
			 fetch_rip <= fetch_rip + 64;//(64-block_offset); //{57'b0, num_bytes};
        //     $display("Block Offset: %x",block_offset);
           //  fetch_buffer <= mem_buffer_repeated[offset*8 +: 64*8]; 
             decode_buffer[0 +: 64*8]  <= mem_buffer;
                
       //     assign fetch_rip = fetch_rip + block_offset; 
                $display("DDECODEBUFFER: %x",decode_buffer);
            //fetch_offset <= fetch_offset+8;
          //  temp[63:0]<=64-block_offset;
            fetch_offset <= fetch_offset+64;//temp[6:0];//num_bytes;
        //    if(mem_buffer_repeated[0:1023]==1024'b0);
        end
        
        $display("Fetch Rip : %x, num_bytes: %d, buf_offset: %d",fetch_rip,num_bytes,buf_offset);        
      //  if (bus.respcyc) begin
		//		assert(!send_fetch_req) else $fatal;
		//		fetch_state <= fetch_active;
		//		fetch_rip <= fetch_rip + 8;
		//		if (fetch_skip > 0) begin
		//			fetch_skip <= fetch_skip - 8;
				//end else begin
					//decode_buffer[fetch_offset*8 +: 64] <= bus.resp;
					//$display("fill at %d: %x [%x]", fetch_offset, bus.resp, decode_buffer);
			//		fetch_offset <= fetch_offset + 8;
			//	end
	/*		end else begin
				if (fetch_state == fetch_active) begin
					fetch_state <= fetch_idle;
				end else if (bus.reqack) begin
					assert(fetch_state == fetch_idle) else $fatal;
					fetch_state <= fetch_waiting;
				end
			end*/

		end

	wire[0:(128+15)*8-1] decode_bytes_repeated = { decode_buffer, decode_buffer[0:15*8-1] }; // NOTE: buffer bits are left-to-right in increasing order
	wire[0:15*8-1] decode_bytes = decode_bytes_repeated[decode_offset*8 +: 15*8]; // NOTE: buffer bits are left-to-right in increasing order
//	wire[0:15*8-1] decode_bytes = decode_bytes_repeated[0*8 +: 15*8]; // NOTE: buffer bits are left-to-right in increasing order
//   wire[0:15*8-1] decode_bytes = decode_buffer[decode_offset*8 +: 15*8]; // NOTE: buffer bits are left-to-right in increasing order
	wire can_decode = (fetch_offset - decode_offset >= 7'd15);


	function logic opcode_inside(logic[7:0] value, low, high);
		opcode_inside = (value >= low && value <= high);
	endfunction


	typedef enum {
		REGISTER,
		MEMORY,
		IMM
	} operand_t;

//    logic id_curr_comp_flag=1'b0;
 //   logic id_comp_flag=1'b0;

    logic[0:0]  id_out_end=1'b0;
    logic[0:0]  of_in_end=1'b0;
    logic[0:0]  of_out_end=1'b0;
    logic[0:0]  ex_in_end=1'b0;
    logic[0:0]  ex_out_end=1'b0;
    logic[0:0]  wb_in_end=1'b0;
  //  logic[0:0]  wb_out_end=1'b0;
    logic[0:0]  cl_out_nop_id_stat;
    logic[0:0]  cl_out_nop_of_stat;
    logic[0:0]  cl_out_nop_ex_stat;
    logic[0:0]  cl_out_nop_wb_stat;
    logic[15:0] id_out_request=16'b0;
    logic[15:0] id_out_provide=16'b0;
	// For ID.decode

	logic[3:0] bytes_decoded_this_cycle;
	logic[7:0] id_out_opr; 
	logic[1:0] id_out_numop;
	operand_t id_out_src_ty;
	operand_t id_out_dest_ty;
	logic[63:0] id_out_src_vl=64'hdeadbeefdeadbeef;
	logic[63:0] id_out_dest_vl=64'hdeadbeefdeadbeef;
	logic[1:0] id_out_src_sz;
	logic[1:0] id_out_dest_sz;

	// For OF.operand_fetch

	logic[3:0] of_out_dest_reg=4'hf;
	logic[7:0] of_out_opr;
	logic[63:0] of_out_opd1;
	logic[63:0] of_out_opd2;
	logic[63:0] of_inp_current_addr;
	logic[7:0] of_inp_opr;
	logic[1:0] of_inp_numop;
	logic[31:0] of_inp_src_ty;
	logic[31:0] of_inp_dest_ty;
	logic[63:0] of_inp_src_vl=64'hdeadbeefbeefdead;
	logic[63:0] of_inp_dest_vl=64'hdeadbeefbeefdead;
	logic[1:0] of_inp_src_sz;
	logic[1:0] of_inp_dest_sz;


    // For EX.alu

	logic[3:0] ex_out_dest_reg;
	logic[3:0] ex_inp_dest_reg;
	logic[63:0] ex_out_res;
	logic[7:0] ex_inp_opr;
	logic[63:0] ex_inp_opd1;
	logic[63:0] ex_inp_opd2;

    // For WB.write_back

	logic[63:0] wb_inp_res;
	logic[3:0] wb_inp_dest_reg;


	typedef logic[63:0] mystring;
	mystring opcode_str[0:255];
	mystring opcode2_str[0:255];
	logic [255:0] ModRM;
	logic [255:0] ModRM2;
	logic[359:0] opcode_stream;
	logic[255:0] mnemonic_stream;
	logic[23:0] inst_info[256];
	//logic[63:0] opr1;
	//logic[63:0] opr2;
   // logic[0:0] end_signal;


	logic[0:0] mem_req_completed=1'b0;
	logic[6:0] num_bytes;
	//logic[0:2*64*8-1] mem_buffer;
	logic[0:64*8-1] mem_buffer;
//	logic[0:64*8-1] fetch_buffer;   ////
	logic[6:0] buf_offset;
	logic[6:0] buf_offset2;
    
	Opcodes opc(opcode_str,ModRM);
	Opcodes2 opc2(opcode2_str,ModRM2);
	InstrnInfo iinfo(inst_info);

	//Decoder D(bytes_decoded_this_cycle, bus, opcode_stream, mnemonic_stream, current_addr, decode_bytes,op,op2,ModRM,ModRM2);

  //  MemArbiter Mem(bus,buf_offset2,fetch_rip,mem_buffer,send_fetch_req,mem_req_completed,num_bytes);l
	ID id(bytes_decoded_this_cycle, opcode_stream, mnemonic_stream, current_addr, decode_bytes,opcode_str,opcode2_str,ModRM,ModRM2,inst_info);
	OF of(xreg);
	EX ex();
	WB wb();

    ControlLogic cl(cl_out_nop_id_stat, cl_out_nop_of_stat, cl_out_nop_ex_stat, cl_out_nop_wb_stat, id_out_request, id_out_provide);


	initial begin
//		xreg[RAX] = 64'h0 ; 
//		xreg[RCX] = 64'h0 ; 
//		xreg[RDX] = 64'h0 ; 
//		xreg[RBX] = 64'h0 ; 
//		xreg[RSP] = 64'h0 ; 
//		xreg[RBP] = 64'h0 ; 
//		xreg[RSI] = 64'h0 ; 
//		xreg[RDI] = 64'h0 ; 
//		xreg[R8]  = 64'h0 ; 
//		xreg[R9]  = 64'h0 ; 
//		xreg[R10] = 64'h0 ; 
//		xreg[R11] = 64'h0 ; 
//		xreg[R12] = 64'h0 ; 
//		xreg[R13] = 64'h0 ; 
//		xreg[R14] = 64'h0 ; 
//		xreg[R15] = 64'h0 ; 
	end

	always_comb begin
                Mem.load(
                    buf_offset2,
                    fetch_rip,
                    mem_buffer,
                    send_fetch_req,
                    mem_req_completed,
                    num_bytes
                );
		$display("can_decode: %x, decode_offset: %x, fetch_offset: %x", can_decode, decode_offset, fetch_offset);
		if (can_decode) begin : decode_block
			// cse502 : Decoder here
			// remove the following line. It is only here to allow successful compilation in the absence of your code.
//			if (decode_bytes == 0) ;
			bytes_decoded_this_cycle = 0;
	//		$display("\n");
	//		$display("Buffer =>: 0x%x", decode_bytes);
			//bytes_decoded_this_cycle = 4'b1111;
            
            $display("Fetch OFfset:%d , Decode Offset:%d",fetch_offset,decode_offset);
            $display("Decode Buffer : %x",decode_buffer);
            $display("Decode Bytes : %x",decode_bytes);

          /*  if ((decode_bytes[0:119] == 120'b0)) begin 
		       $display("Decoded ..............!!!!!!!!!!!!!!!");
                id_end=1'b1; 
            end */
  //          else begin  
                
              //  if(end_signal==1'b1) begin
               //     $display("You !!!!!!!!!!!!");
                 //   $finish;
              //  end

                id.decode(
                 //   id_curr_comp_flag,
                    id_out_end,
                    id_out_request,
                    id_out_provide,
					bytes_decoded_this_cycle,
					id_out_opr,
					id_out_numop,
					id_out_src_ty,
					id_out_dest_ty,
					id_out_src_vl,
					id_out_dest_vl,
					id_out_src_sz,
					id_out_dest_sz
               //     id_comp_flag 
				);


               // $display("no of src regs:  %b ",id_nsrcregs);
			of.operand_fetch(
                of_out_end,
				of_out_dest_reg,
				of_out_opr,
				of_out_opd1,
				of_out_opd2,
				of_inp_current_addr,
				of_inp_opr,
				of_inp_numop,
				of_inp_src_ty,
				of_inp_dest_ty,
				of_inp_src_vl,
				of_inp_dest_vl,
				of_inp_src_sz,
				of_inp_dest_sz,
                of_in_end
			);

              //  $display("no of src regs2:  %b ",of_nsrcregs);
			ex.alu(ex_out_end,ex_out_dest_reg,ex_out_res,ex_inp_opr,ex_inp_opd1,ex_inp_opd2,ex_inp_dest_reg,ex_in_end);
		
			//wb.write_back(wb_out_end,wb_regx,wb_inp_dest_reg,wb_inp_res,wb_in_end);
			wb.write_back(wb_regx,wb_inp_dest_reg,wb_inp_res,wb_in_end);
        
	//		$display("Decod Working !!!!!!!!!!1"); 
	//		$display("bytes_decoded_this_cycle : %d", bytes_decoded_this_cycle); 
		

			if (ModRM[255:0] == 0);
			if (ModRM2[255:0] == 0);
			if (inst_info[23:0] == 0);
			if (mnemonic_stream[255:0] == 0);
			if (opcode_stream[359:0] == 0);

			if (ex_out_res == 0);

			// cse502 : following is an example of how to finish the simulation
	//		$display("decode_bytes: %x", decode_bytes);
	//		$display("fetch_state: %x", fetch_idle);
			//if (decode_bytes == 0 && fetch_state == fetch_idle) $finish;
			//if (decode_bytes[0:119] == 120'b0 || fetch_state == fetch_idle) $finish;
			//if (decode_bytes[0:119] == 120'b0 ) $finish;
//			end
		end else begin
			bytes_decoded_this_cycle = 0;
		end
	end

	always @ (posedge bus.clk)
		if (bus.reset) begin
         
			decode_offset <= 0;
			decode_buffer <= 0;
			current_addr <= entry;

	/*		xreg[RAX] <= 64'h0 ; 
			xreg[RCX] <= 64'h0 ; 
			xreg[RDX] <= 64'h0 ; 
			xreg[RBX] <= 64'h0 ; 
			xreg[RSP] <= 64'h0 ; 
			xreg[RBP] <= 64'h0 ; 
			xreg[RSI] <= 64'h0 ; 
			xreg[RDI] <= 64'h0 ; 
			xreg[R8]  <= 64'h0 ; 
			xreg[R9]  <= 64'h0 ; 
			xreg[R10] <= 64'h0 ; 
			xreg[R11] <= 64'h0 ; 
			xreg[R12] <= 64'h0 ; 
			xreg[R13] <= 64'h0 ; 
			xreg[R14] <= 64'h0 ; 
			xreg[R15] <= 64'h0 ; 
*/

  //          id_comp_flag <= 0;

			of_inp_current_addr <= 0;
			of_inp_opr <= 0;
			of_inp_numop <= 0;
			of_inp_src_ty <= 0;
			of_inp_dest_ty <= 0;
			of_inp_src_vl <= 64'hdeadbeafbeafdead;
			of_inp_dest_vl <= 64'hbeafdeaddeadbeef;
			of_inp_src_sz <= 0;
			of_inp_dest_sz <= 0;


			// OFEX pipeline registers

			ex_inp_opr <= 0;
			ex_inp_opd1 <= 0;
			ex_inp_opd2 <= 0;

			//wb_inp_dest_reg <= 0;
			//wb_inp_res <= 0;

		end else begin // !bus.reset
//            id_comp_flag <= id_curr_comp_flag;
            //                $display("... id=%x ... of=%x ...  ex=%x \n",cl_out_nop_id_stat,cl_out_nop_of_stat,cl_out_nop_ex_stat);
            //if(!(cl_out_nop_id_stat) && !(cl_out_nop_of_stat) && !(cl_out_nop_ex_stat)) begin
          //  decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
         //   current_addr <= current_addr + { 60'b0, bytes_decoded_this_cycle };

         if(!(cl_out_nop_id_stat) && !(cl_out_nop_of_stat) && !(cl_out_nop_ex_stat) && !(cl_out_nop_wb_stat)) begin

          //  $display("ID Passed !!!!!!");
                      $display("bytes_decoded_this_cycle: %d\n",bytes_decoded_this_cycle);
			    // IDOF pipeline registers

                decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
                current_addr <= current_addr + { 60'b0, bytes_decoded_this_cycle };
			    
                of_inp_current_addr <= current_addr;
			    of_inp_opr <= id_out_opr;
			    of_inp_numop <= id_out_numop;
			    of_inp_src_ty <= id_out_src_ty;
			    of_inp_dest_ty <= id_out_dest_ty;
			    of_inp_src_vl <= id_out_src_vl;
			    of_inp_dest_vl <= id_out_dest_vl;
			    of_inp_src_sz <= id_out_src_sz;
			    of_inp_dest_sz <= id_out_dest_sz;
                of_in_end <= id_out_end;
            end
/*            else begin
                decode_offset <= decode_offset - { 3'b0, bytes_decoded_this_cycle };
                current_addr <= current_addr - { 60'b0, bytes_decoded_this_cycle };
            end */
            if(!(cl_out_nop_of_stat) && !(cl_out_nop_ex_stat) && !(cl_out_nop_wb_stat)) begin
			    // OFEX pipeline registers
               // $display("OF Passed !!!!!!");

			    ex_inp_opr <= of_out_opr;
			    ex_inp_opd1 <= of_out_opd1;
			    ex_inp_opd2 <= of_out_opd2;
			    ex_inp_dest_reg <= of_out_dest_reg;
                ex_in_end<= of_out_end;
           end

            if(!(cl_out_nop_ex_stat) && !(cl_out_nop_wb_stat)) begin
              //  $display("EX Passed !!!!!!");
			 //   xreg[ex_out_dest_reg[3:0]] <= ex_out_res;
            //    wb_end <= ex_out_end;
            
			    wb_inp_dest_reg <= ex_out_dest_reg;
			    wb_inp_res <= ex_out_res;
        
                wb_in_end<= ex_out_end;
//                end_signal<=wb_out_end;    
                xreg <= wb_regx;
            end
			    // EXWB pipeline registers

			
          /*      
			    xreg[RAX] <=  xreg[RAX]; 
			    xreg[RCX] <=  xreg[RCX]; 
			    xreg[RDX] <=  xreg[RDX]; 
			    xreg[RBX] <=  xreg[RBX]; 
			    xreg[RSP] <=  xreg[RSP]; 
			    xreg[RBP] <=  xreg[RBP]; 
			    xreg[RSI] <=  xreg[RSI]; 
			    xreg[RDI] <=  xreg[RDI]; 
			    xreg[R8 ] <= xreg[R8 ] ; 
			    xreg[R9 ] <= xreg[R9 ] ; 
			    xreg[R10] <=  xreg[R10]; 
			    xreg[R11] <=  xreg[R11]; 
			    xreg[R12] <=  xreg[R12]; 
			    xreg[R13] <=  xreg[R13]; 
			    xreg[R14] <=  xreg[R14]; 
			    xreg[R15] <=  xreg[R15]; 
			    xreg[ex_out_dest_reg[3:0]] <= ex_out_res;*/
    //        end
//			$display("RAX = %x", xreg[RAX]);
//			$display("RBX = %x", xreg[RBX]);
//			$display("RCX = %x", xreg[RCX]);
//			$display("RDX = %x", xreg[RDX]);
//			$display("RSI = %x", xreg[RSI]);
//			$display("RDI = %x", xreg[RDI]);
//			$display("RBP = %x", xreg[RBP]);
//			$display("RSP = %x", xreg[RSP]);
//			$display("R8 = %x", xreg[R8]);
//			$display("R9 = %x", xreg[R9]);
//			$display("R10 = %x", xreg[R10]);
//			$display("R11 = %x", xreg[R11]);
//			$display("R12 = %x", xreg[R12]);
//			$display("R13 = %x", xreg[R13]);
//			$display("R14 = %x", xreg[R14]);
//			$display("R15 = %x", xreg[R15]);
			//$display("WB: dstreg=%x val=%x",ex_out_res[3:0], xreg[ex_out_dest_reg[3:0]][63:0]); 

//			$display("Buffer =>: 0x%x", decode_bytes);
//			$display("Offset after: %x", decode_offset);
//			$display(" < ---------------------------------------------------------------------------------------------- > ");
				
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
		$display("Endian Check %x", 32'h12345678);
	end
endmodule
