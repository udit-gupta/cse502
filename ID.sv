module ID(
	output logic[3:0] byte_incr, 
	output logic[359:0] opcode_stream,
    output logic[255:0] mnemonic_stream,
	input logic[63:0] current_addr,
    input logic[0:15*8-1] buffer,
	input logic[63:0] op[0:255],
	input logic[63:0] op2[0:255],
	input logic[255:0] ModRM,
	input logic[255:0] ModRM2,
	input logic[23:0] inst_info[256]
);

// 'State' for the current instruction 
//logic signed[31:0] displacement;


logic[31:0] disp;
logic[31:0] scale_factor;

logic[15:0] id_requests=16'b0;
logic[15:0] id_provides=16'b0;
logic[2:0] dispsize;
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
////logic [0:0] RR_addr;
logic [0:0] RM;
//// Output strings
logic [7:0] optr;
logic [7:0] mptr;
logic [1:0] num_inst_bytes;

logic[63:0] grpop;
logic[0:0] grpflag;
logic[63:0] dest_val_sw;
logic[63:0] src_val_sw;
//logic[63:0] t1 = 64'hAABBCCDD11223344;
//logic[63:0] t2 = 64'b0;

//typedef enum {
//	UNDEFINED=3'b000,
//	LEGACY_PREFIX=3'b001, REX_PREFIX=3'b010, OPCODE=3'b011, 
//	MOD_RM=3'b100, SIB=3'b101, DISPLACEMENT=3'b110, IMMEDIATE=3'b111
//} inst_field_t; 


typedef enum {
	UNDEFINED=7'b0,
	LEGACY_PREFIX=7'b1, REX_PREFIX=7'b10, OPCODE=7'b100, 
	MOD_RM=7'b1000, SIB=7'b10000, DISPLACEMENT=7'b100000, IMMEDIATE=7'b1000000
} inst_field_t; 

typedef logic[63:0] mystring;

typedef enum {
	REGISTER,
	MEMORY,
	IMM
} operand_t;


typedef enum { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15 } regname;

// TODO: Legacy prefix : no actions defined: low prioirity 


task decode_instr;
    output logic[3:0] next_byte_offset;
	output logic[1:0] num_op;
	output operand_t src_type;
	output operand_t dest_type;
	output logic[63:0] src_val;
	output logic[63:0] dest_val;
	output logic[1:0] src_size;
	output logic[1:0] dest_size;
	input logic[3:0]  inst_byte_offset;
	//output inst_field_t next_field_type;    
    logic[0:0] flag1; 
    logic[0:0] flag2; 
    logic[23:0] instr_info=inst_info[instr];
    logic[3:0] incr1; 
    logic[3:0] incr2; 
    logic[3:0] incr; 
    logic[7:0] ibyte; 
	logic[15:0] idbyte;
	logic[31:0] iqbyte;
	logic[15:0] out;
    logic[31:0] bo;
	logic[23:0] opstr;
   
	logic[0:0] no_src_regs;


//	logic[31:0] out2;
//	logic[63:0] out3;
//	logic[127:0] out4;

    begin        
        no_src_regs=instr_info[23];
		incr1 = 4'b0; 
		incr2 = 4'b0; 
        flag1=1'b0;
        flag2=1'b0;
        bo[31:0] = 32'b0;
        bo[3:0] = inst_byte_offset[3:0];
      //  $display("Instruction Info: %b %x",inst_info[instr],instr);   
        
//        case(instr_info[22:21])
//            2'b00: $display("zero operands");
//            2'b01: $display("one operand");
//            2'b10: $display("two operand");
//            2'b11: $display("three operand");
//            default: $display("Error in operand recognition !!");
//        endcase

		// endianswap(t2[63:0],t1[63:0]);
		// $display("t1: %x", t1[63:0]);
		// $display("t2: %x", t2[63:0]);

		num_op[1:0] = instr_info[22:21];
//		$display("Number of operands %d", num_op[1:0]);
         
//		$display("MOD: %x", mod[1:0]);
//		$display("REG: %x", reg1[2:0]);
//		$display("RM: %x", rm[2:0]);
		if (num_op[1:0] > 2'd0) begin


			case(instr_info[20:19])
				2'b00: begin 
							dest_type = REGISTER;
							dest_val[63:0] = { 60'b0, rex_bits[2], reg1[2:0] };
						//	$display("Op1:register: %x", dest_val[63:0]);
							reg_symbol(opstr[23:0], {rex_bits[2],reg1[2:0]}, instr_info[16:15],1'b0);
							mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
							mptr = mptr + 4;
					  end
			   2'b01: begin
				   		  if (mod == 2'b11) begin
							  dest_type = REGISTER;				
							  dest_val[63:0] = { 60'b0,  rex_bits[0], rm[2:0] };
							  // $display("Op1:R/M: %x", dest_val[63:0]);
							  reg_symbol(opstr[23:0],{rex_bits[0], rm[2:0]}, instr_info[16:15],1'b0);
							  mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
							  mptr = mptr + 4;
					  	  end
						  else begin
							  dest_type = MEMORY;				
							  dest_val[63:0] = { 60'b0,  rex_bits[2], rm[2:0] };
//							  $display("Op1:M: %x", dest_val[63:0]);
							  reg_symbol(opstr[23:0],{rex_bits[0], rm[2:0]}, instr_info[16:15],1'b0);
							  mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
							  mptr = mptr + 4;
						  end
					  end
				2'b10: begin
							flag1=1'b1;
		                  // $display("Op1:IMMEDIATE");
							dest_type = IMM;
                            id_provides=16'b0;
					   end
				2'b11: begin 
						  dest_type = REGISTER;
						  //$display("Op1RegNo: %b", instr_info[12:9]);
						  dest_val[63:0] = { 60'b0  , instr_info[12:9]};
					    //  $display("Op1:fixed operand %x", dest_val[63:0]);
						  reg_symbol( opstr[23:0], instr_info[12:9], instr_info[16:15],1'b0);
						  mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
						  mptr = mptr + 4;
					 end
				default: $display("Op1:Error in numop recognition !!");
			endcase
			
	end

		if (num_op[1:0] > 2'd1) begin 
			mptr =  mptr - 1;
			mnemonic_stream[255-mptr*8 -: 8] = 8'h2C;  // comma
			mptr = mptr + 1;
			case(instr_info[18:17])
				2'b00: begin
						src_type = REGISTER;
						src_val[63:0] = { 60'b0, rex_bits[2], reg1[2:0] };
					//	$display("Op2:register: %x", src_val[63:0]);
						reg_symbol(opstr[23:0], {rex_bits[2],reg1[2:0]}, instr_info[14:13],1'b1);
						mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
						mptr = mptr + 4;
					end
				2'b01: begin
				   		if (mod == 2'b11) begin
							src_type = REGISTER;
							src_val[63:0] = { 60'b0, rex_bits[0], rm[2:0] };
						// $display("Op2:R/M: %x", src_val[63:0]);
						reg_symbol(opstr[23:0] ,{rex_bits[0],rm[2:0]}, instr_info[14:13],1'b1);
							mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
							mptr = mptr + 4;
						end
						else begin
							src_type = MEMORY;
							src_val[63:0] = { 60'b0, rex_bits[2], rm[2:0] };
							$display("DISP[31:24]: %x", disp[31:24]);
							$display("DISP[23:16]: %x", disp[23:16]);
							$display("DISP[15:8]: %x", disp[15:8]);
							$display("DISP[7:0]: %x", disp[7:0]);
							reg_symbol(opstr[23:0] ,{rex_bits[0],rm[2:0]}, instr_info[14:13],1'b1);
							mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
							mptr = mptr + 4;
						end
					end
				2'b10: begin
					flag2=1'b1;
					src_type = IMMEDIATE;
                    id_requests=16'b0;
				//	$display("Op2:IMM");
				end
			   2'b11: begin
					src_type = REGISTER;
					// $display("Op2RegNo: %b", instr_info[12:9]);
					src_val[63:0] = { 60'b0, instr_info[8:5]};
			//		$display("Op2:fix operand %x", src_val[63:0]);
					reg_symbol( opstr[23:0], instr_info[12:9], instr_info[16:15],1'b1);
					mnemonic_stream[255-mptr*8 -: 24] = opstr[23:0];
					mptr = mptr + 4;
				end
				default: $display("Op2:Error in op1 recognition !!");
			endcase
		end


        if(no_src_regs==1'b1) begin
            id_requests = id_requests | id_provides;
        end

		if (num_op[1:0] > 2'd0) begin

			dest_size[1:0] = instr_info[16:15];
			case(instr_info[16:15])
				2'b00:  begin
							if(flag1==1'b1) begin
								incr1=4'd1;
								
								ibyte[7:0] = buffer[bo*8 +: 8];
							    if (ibyte[7]==1'b1) begin
								//	$display("flag 1 Inside 1");
									dest_val_sw[63:0] = { buffer[bo*8 +: 8], 56'hffffffffffffff};
								end
								else begin	
								//	$display("flag 1 Inside 0");
									dest_val_sw[63:0] = { buffer[bo*8 +: 8], 56'b0};
								end
								
								
								
							//	dest_val_sw[63:0] = { buffer[bo*8 +: 8], 56'b0};
								endianswap(dest_val[63:0],dest_val_sw[63:0]);
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


								toascii(out,dest_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


							//	mnemonic_stream[255-mptr*8 -: 16] = out;
							//	mptr = mptr + 2;
							end
			                // $display("Op1Size:8");
						end
				2'b01: begin
							if(flag1==1'b1) begin
								incr1=4'd2;
								dest_val_sw[63:0] = { buffer[bo*8 +: 16], 48'b0};
								endianswap(dest_val[63:0],dest_val_sw[63:0]);
								// 1
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-16 -: 16] = out;

								// 2
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;



								toascii(out,dest_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


							//	mnemonic_stream[255-mptr*8 -: 16] = out;

							//	mptr = mptr + 4;
							end
				//            $display("Op1Size:16");
						end
				2'b10:  begin
							if(flag1==1'b1) begin
								incr1=4'd4;

								dest_val_sw[63:0] = { buffer[bo*8 +: 32], 32'b0};
								endianswap(dest_val[63:0],dest_val_sw[63:0]);
								// 1
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-48 -: 16] = out;

								// 2
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


							//	mnemonic_stream[255-mptr*8-32 -: 16] = out;

								// 3
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-16 -: 16] = out;

								// 4
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


								toascii(out,dest_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


							//	mnemonic_stream[255-mptr*8 -: 16] = out;

							//	mptr = mptr + 8;

							end
				  //          $display("Op1Size:32");
						end
				2'b11:  begin
							if(flag1==1'b1) begin
								incr1=4'd8;

								dest_val_sw[63:0] = buffer[bo*8 +: 64];
								endianswap(dest_val[63:0],dest_val_sw[63:0]);
								// 1
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-112 -: 16] = out;

								// 2
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-96 -: 16] = out;

								// 3
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-80 -: 16] = out;

								// 4
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-64 -: 16] = out;

								// 5
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-48 -: 16] = out;

								// 6
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-32 -: 16] = out;

								// 7
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-16 -: 16] = out;
								
								// 8
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8 -: 16] = out;

							//	mptr = mptr + 16;



								toascii(out,dest_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,dest_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,dest_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

							end
					//        $display("Op1size:64");
						end
				default: $display("Op1size:Error in op1size recognition !!");
			endcase
		    // $display("Increment1 : %d", incr1);

	end

		if (num_op[1:0] > 2'd1) begin 
        
		//	mptr =  mptr - 1;
		//	mnemonic_stream[255-mptr*8 -: 8] = 8'h2C;  // comma
		//	mptr = mptr + 1;
			src_size[1:0] = instr_info[14:13];
			case(instr_info[14:13])
				2'b00:  begin
							if(flag2==1'b1) begin 
								incr2=4'd1;
								ibyte[7:0] = buffer[bo*8 +: 8];
							    if (ibyte[7]==1'b1) begin
								//	$display("Inside 1");
									src_val_sw[63:0] = { buffer[bo*8 +: 8], 56'hffffffffffffff};
								end
								else begin	
								//	$display("Inside 0");
									src_val_sw[63:0] = { buffer[bo*8 +: 8], 56'b0};
								end
								endianswap(src_val[63:0],src_val_sw[63:0]);
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;
								
								toascii(out,src_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

							end
			                //$display("Op2Size:8");
						end
				2'b01:  begin
							if(flag2==1'b1) begin 
								incr2=4'd2;
								
								idbyte[15:0] = buffer[bo*8 +: 16];
							    if (idbyte[7]==1'b1) begin
									src_val_sw[63:0] = { buffer[bo*8 +: 16], 48'hffffffffffff};
								end
								else begin	
									src_val_sw[63:0] = { buffer[bo*8 +: 16], 48'b0};
								end

								if(idbyte[15:8]==8'b0);
								if(idbyte[6:0]==7'b0);
								// dest_val[63:0] = { 48'b0,  buffer[bo*8 +: 16]};


						//		src_val_sw[63:0] = { buffer[bo*8 +: 16], 48'b0};
								endianswap(src_val[63:0],src_val_sw[63:0]);
								// 1
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-16 -: 16] = out;

								// 2
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


								//mnemonic_stream[255-mptr*8 -: 16] = out;


							//	mptr = mptr + 4;

								toascii(out,src_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

							end
			                //$display("Op2Size:16");
						end
				2'b10:  begin
							if(flag2==1'b1) begin 
								incr2=4'd4;

								//src_val_sw[63:32] = { 32'b0,  buffer[bo*8 +: 32]};
							
								iqbyte[31:0] = buffer[bo*8 +: 32];
							    if (iqbyte[7]==1'b1) begin
									src_val_sw[63:0] = { buffer[bo*8 +: 32], 32'hffffffff};
								end
								else begin	
									src_val_sw[63:0] = { buffer[bo*8 +: 32], 32'b0};
								end
								
								
							if(iqbyte[31:8]==24'b0);
								if(iqbyte[6:0]==7'b0);
								
								
							//	src_val_sw[63:0] = { buffer[bo*8 +: 32], 32'b0};
								endianswap(src_val[63:0],src_val_sw[63:0]);
								// 1
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


//								mnemonic_stream[255-mptr*8-48 -: 16] = out;
								
								// 2
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;
								

//								mnemonic_stream[255-mptr*8-32 -: 16] = out;

								// 3
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


//								mnemonic_stream[255-mptr*8-16 -: 16] = out;

								// 4
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


//								mnemonic_stream[255-mptr*8 -: 16] = out;

//								mptr = mptr + 8;


								toascii(out,src_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

							end
				            //$display("Op2Size:32");
						end
				2'b11:  begin
							if(flag2==1'b1) begin 
								incr2=4'd8;

								src_val_sw[63:0] = buffer[bo*8 +: 64];
								endianswap(src_val[63:0],src_val_sw[63:0]);
								// 1
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


							//	mnemonic_stream[255-mptr*8-112 -: 16] = out;

								// 2
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;


							//	mnemonic_stream[255-mptr*8-96 -: 16] = out;

								// 3
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-80 -: 16] = out;
								
								// 4
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-64 -: 16] = out;

							
								// 5
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-48 -: 16] = out;


								// 6
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-32 -: 16] = out;

								// 7
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8-16 -: 16] = out;

								// 8
								ibyte[7:0] = buffer[bo*8 +: 8];
								toascii(out,ibyte[7:0]);
								opcode_stream[359-optr*8 -: 16] = out;
								optr = optr + 3;
								bo = bo + 1;

							//	mnemonic_stream[255-mptr*8 -: 16] = out;

							//	mptr =  mptr + 16; 

	
								toascii(out,src_val_sw[7:0]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[15:8]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[23:16]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[31:24]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[39:32]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[47:40]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;

								toascii(out,src_val_sw[55:48]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


								toascii(out,src_val_sw[63:56]);
								mnemonic_stream[255-mptr*8 -: 16] = out;
								mptr = mptr + 2;


							end
				            //$display("Op2Size:64");
						end
				default: $display("Op2Size:Error in op2size recognition !!");
			endcase
			// $display("Increment2 : %d", incr2);

		end

     //   case(instr_info[4:0])
       //     default:$display("Group Bytes: %b", instr_info[6:1]);
           // default: $display("Error in groupno recognition !!");
     //   endcase

     	if(instr_info[4:0]==5'b0);
        incr=incr1+incr2;
        next_byte_offset=inst_byte_offset+incr;
		//next_byte_offset=next_byte_offset+{1'b0,dispsize};

	   // $display("Increment : %d", incr);
    end
endtask





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
		//	$display("REX prefix");
//			if (rex_bits[3] == 1'b1)
//				$display("REX: 64 bit operand size");
//			if (rex_bits[2] == 1'b1)
//				$display("REX: Mod R/M reg field");
//			if (rex_bits[1] == 1'b1)
//				$display("REX: SIB extension field present");
//			if (rex_bits[0] == 1'b1)
//				$display("REX: ModR/M or SIB or Opcode reg");
			rex_bits[3:0] = ibyte[3:0];
			if (rex_bits[2] == 1'b1)
				RM = 1'b1; 
			inc = 4'd1;
			toascii(out,ibyte[7:0]);
			opcode_stream[359-optr*8 -: 16] = out;
			optr = optr + 3;
		end
		else begin
//			$display("Not a REX prefix");
			inc = 4'd0;
			rex_bits[3:0] = 4'b0;
		end

		next_byte_offset = inst_byte_offset + inc;
		next_field_type = OPCODE;// | LEGACY_PREFIX;

		// To suprress errors
		if (rex_bits[3:0] == 0);
		if (RM == 0);
	end
endtask


task get_reg;

begin
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
		4'b1000: ereg[31:0]="%r8 ";
		4'b1001: ereg[31:0]="%r9 ";
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
		4'b1000: greg[31:0]="%r8 ";
		4'b1001: greg[31:0]="%r9 ";
		4'b1010: greg[31:0]="%r10";
		4'b1011: greg[31:0]="%r11";
		4'b1100: greg[31:0]="%r12";
		4'b1101: greg[31:0]="%r13";
		4'b1110: greg[31:0]="%r14";
		4'b1111: greg[31:0]="%r15";
		default: ;
	endcase

end
endtask


task reg_symbol;
	output logic[23:0] gpr;
	input logic[3:0] rnum;
	input logic[1:0] sz;
	input logic[0:0] src_or_dest;

begin
	if (sz[1:0] == 2'b11)
	begin
		case(rnum[3:0]) 
			4'b0000: gpr[23:0] = "rax";
			4'b0001: gpr[23:0] = "rcx";
			4'b0010: gpr[23:0] = "rdx";
			4'b0011: gpr[23:0] = "rbx";
			4'b0100: gpr[23:0] = "rsp";
			4'b0101: gpr[23:0] = "rbp";
			4'b0110: gpr[23:0] = "rsi";
			4'b0111: gpr[23:0] = "rdi";
			4'b1000: gpr[23:0] = "r8 ";
			4'b1001: gpr[23:0] = "r9 ";
			4'b1010: gpr[23:0] = "r10";
			4'b1011: gpr[23:0] = "r11";
			4'b1100: gpr[23:0] = "r12";
			4'b1101: gpr[23:0] = "r13";
			4'b1110: gpr[23:0] = "r14";
			4'b1111: gpr[23:0] = "r15";
			default:;
		endcase
	end

	else if (sz[1:0] == 2'b10)
	begin
		case(rnum[3:0]) 
			4'b0000: gpr[23:0] = "eax";
			4'b0001: gpr[23:0] = "ecx";
			4'b0010: gpr[23:0] = "edx";
			4'b0011: gpr[23:0] = "ebx";
			4'b0100: gpr[23:0] = "esp";
			4'b0101: gpr[23:0] = "ebp";
			4'b0110: gpr[23:0] = "esi";
			4'b0111: gpr[23:0] = "edi";
			default: ;
		endcase
	end


	else if (sz[1:0] == 2'b01)
	begin
		case(rnum[3:0]) 
			4'b0000: gpr[23:0] = "ax";
			4'b0001: gpr[23:0] = "cx";
			4'b0010: gpr[23:0] = "dx";
			4'b0011: gpr[23:0] = "bx";
			4'b0100: gpr[23:0] = "sp";
			4'b0101: gpr[23:0] = "bp";
			4'b0110: gpr[23:0] = "si";
			4'b0111: gpr[23:0] = "di";
			default: ;
		endcase
	end

	else if (sz[1:0] == 2'b00)
	begin
		case(rnum[3:0]) 
			4'b0000: gpr[23:0] = "al";
			4'b0001: gpr[23:0] = "cl";
			4'b0010: gpr[23:0] = "dl";
			4'b0011: gpr[23:0] = "bl";
			4'b0100: gpr[23:0] = "sp";
			4'b0101: gpr[23:0] = "bp";
			4'b0110: gpr[23:0] = "si";
			4'b0111: gpr[23:0] = "di";
			default: ;
		endcase
	end
   
    if(src_or_dest==1'b0) begin
        id_provides=1<<rnum[3:0];
    end
    else begin
        id_requests=1<<rnum[3:0];
    end
end
endtask

task check_grp;
	output logic[0:0] grp1flag;
	input logic[7:0]  instruction;

	if(instruction[7:0]>=8'd128 && instruction[7:0]<=8'd131) begin
		grp1flag=1'b1; 
	end
	else if(instruction[7:0]==8'hf6 || instruction[7:0]==8'hf7) begin
		grp1flag=1'b1; 
	end
	else if(instruction[7:0]==8'hfe) begin
		grp1flag=1'b1; 
	end
	else if(instruction[7:0]==8'hff) begin
		grp1flag=1'b1; 
	end
	else if(instruction[7:0]==8'hff) begin
		grp1flag=1'b1; 
	end
	else begin
		grp1flag=1'b0; 
	end

endtask

task update_opgrp; 
	output mystring grp1op;
	input logic[7:0]  instruction;

	if(instruction[7:0]>=8'd128 && instruction[7:0]<=8'd131) begin
		if(reg1[2:0]==3'b000) begin
			grp1op="ADD   ";
		end
		else if(reg1[2:0]==3'b001) begin
			grp1op="OR    ";
		end
		else if(reg1[2:0]==3'b010) begin
			grp1op="ADC   ";
		end
		else if(reg1[2:0]==3'b011) begin
			grp1op="SBB   ";
		end
		else if(reg1[2:0]==3'b100) begin
			grp1op="AND   ";
		end
		else if(reg1[2:0]==3'b101) begin
			grp1op="SUB   ";
		end
		else if(reg1[2:0]==3'b110) begin
			grp1op="XOR   ";
		end
		else if(reg1[2:0]==3'b111) begin
			grp1op="CMP   ";
		end
	end
	else if(instruction[7:0]==8'hf6 || instruction[7:0]==8'hf7) begin
		if(reg1[2:0]==3'b000) begin
			grp1op="TEST   ";
		end
		else if(reg1[2:0]==3'b001) begin
			grp1op="       ";
		end
		else if(reg1[2:0]==3'b010) begin
			grp1op="NOT   ";
		end
		else if(reg1[2:0]==3'b011) begin
			grp1op="NEG   ";
		end
		else if(reg1[2:0]==3'b100) begin
			grp1op="MUL   ";
		end
		else if(reg1[2:0]==3'b101) begin
			grp1op="IMUL   ";
		end
		else if(reg1[2:0]==3'b110) begin
			grp1op="DIV   ";
		end
		else if(reg1[2:0]==3'b111) begin
			grp1op="IDIV   ";
		end
	end
	else if(instruction[7:0]==8'hfe) begin
		if(reg1[2:0]==3'b000) begin
			grp1op="INC   ";
		end
		else if(reg1[2:0]==3'b001) begin
			grp1op="DEC   ";
		end
		else  begin
			grp1op="INVAL ";
		end
	end
	else if(instruction[7:0]==8'hff) begin
		if(reg1[2:0]==3'b000) begin
			grp1op="INC   ";
		end
		else if(reg1[2:0]==3'b001) begin
			grp1op="DEC   ";
		end
		else if(reg1[2:0]==3'b010) begin
			grp1op="CALL   ";
		end
		else if(reg1[2:0]==3'b011) begin
			grp1op="CALLF   ";
		end
		if(reg1[2:0]==3'b100) begin
			grp1op="JMPIN   ";
		end
		else if(reg1[2:0]==3'b101) begin
			grp1op="JMPF   ";
		end
		else if(reg1[2:0]==3'b110) begin
			grp1op="PUSH   ";
		end
		else if(reg1[2:0]==3'b111) begin
			grp1op="       ";
		end
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
		grpflag = 1'b0;
		RM = 1'b0;

		if (buffer[inst_byte_offset*8 +: 8]==8'h0f) begin
			inst_byte_offset=inst_byte_offset+1;
		//	inc = inc + 1;
			//$display("Opcode 2: 0x%x", buffer[inst_byte_offset*8 +: 8]);	
			//$display("Opcode 2: %s", op2[buffer[inst_byte_offset*8 +: 8]]);	
			num_inst_bytes[1:0] = 2'b10;
			instr[7:0] = buffer[inst_byte_offset*8 +: 8];
			toascii(out1,8'h0f);
			opcode_stream[359-optr*8 -: 16] = out1; 
			optr = optr + 3;
			toascii(out2,buffer[inst_byte_offset*8 +: 8]);	
			opcode_stream[359-optr*8 -: 16] = out2; 
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
			opcode_stream[359-optr*8 -: 16] = out1;

			check_grp(grpflag,instr[7:0]);
			if(grpflag==1'b0) begin
			//	$display("Eroorww !!");
				mnemonic_stream[255-mptr*8 -: 64] = op[buffer[inst_byte_offset*8 +: 8]];
				mptr = mptr + 8;
			end

			optr = optr + 3;
			RM = ModRM[255-buffer[inst_byte_offset*8 +: 8]];
		end


		if (RM == 1) begin
	//		$display("ModRM present");
			next_field_type = MOD_RM;
		end
		else begin
		//	$display("ModRM absent");
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
		opcode_stream[359-optr*8 -: 16] = out1;
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


		check_grp(grpflag,instr[7:0]);
//		$display("instr = %x \n",instr[7:0]);
		if(grpflag!=1'b0) begin
				update_opgrp(grpop,instr[7:0]);
				mnemonic_stream[255-mptr*8 -: 64] = grpop;
//				$display("Eroor !!");
				mptr = mptr + 8;
		end
		//get_reg();

		if(mod[1:0]==2'b00) begin
			if(rm[2:0]==3'b101) begin
				dispsize[2:0]=3'd4;
			end
			else begin
				dispsize[2:0]=3'd0;
			end
		end
		else if(mod[1:0]==2'b01) begin
			dispsize[2:0]=3'd1;
		end
		else if(mod[1:0]==2'b10) begin
			dispsize[2:0]=3'd4;
		end
		else begin
			dispsize[2:0]=3'd0;
		end

		if(reg1[2:0]==3'b000);   // 
		if(rex_bits[2:0]==3'b000);   // 


		next_field_type=LEGACY_PREFIX;
		//$display("MOD: %x RM: %x\n", mod[1:0], modrm[2:0]);

		if (mod[1:0] == 2'b11) begin
			// $display("if entered");
			next_field_type = next_field_type | LEGACY_PREFIX;
		end
		else begin 
			// $display("else entered");
			next_field_type = next_field_type | SIB;
		end
		next_byte_offset = inst_byte_offset + inc;


		// To suppress compilation errors
		if (ereg[31:0] == 0);
		if (greg[31:0] == 0);

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
//	logic[31:0] disp;
//	logic[31:0] scale_factor;
//	logic[31:0] byte_off;
	logic[3:0] byte_off;
	logic[15:0] out1;

	begin
		$display("check_sib called");
		inc = 0;
//		byte_off[31:0]={28'b0,inst_byte_offset} + 1;
        byte_off=inst_byte_offset;
        sib = buffer[inst_byte_offset*8 +: 8];
		//inc = inc + 1;

		scale[1:0] = (1 << sib[7:6]);
		index[3:0] = {rex_bits[1], sib[5:3]};
		base[3:0] = {rex_bits[0], sib[2:0]};
		
        if(scale[1:0]==2'b0 && index[3:0]==4'b0);
		 //$display("scale: b%b", scale);
		 //$display("index: b%b", index);
		 //$display("base : b%b", base);
		 if (base[3] == 0);


		// $display("mod: %x", mod[1:0]);
		// $display("mod: %x", modrm[7:6]);

		if ((modrm[1:0] != 2'b11) && (rm[2:0] == 3'b100 ))  begin

			// SIB present

			toascii(out1,sib);	
			opcode_stream[359-optr*8 -: 16] = out1;
			optr = optr + 3;
        end
        else begin
		    scale[1:0] = 2'b0;
		    index[3:0] = 4'b0;
		    base[3:0]  = 4'b0;
        end

        $display("MDORM Value: %x",modrm[7:0]);
        $display("DISPBUFFER Value: %x",buffer[inst_byte_offset*8 +: 64]);

        if (modrm[7:6] == 2'b00 ) begin
           // if (index[3:0] == 4'b0100 ) begin
             //   if (base[2:0] == 3'b101 ) begin
                    num_disp_bytes[2:0] = 3'b100;
                    //disp[31:0] = buffer[(byte_off+32'b1)*8 +: 32]; 
                    disp[31:0] = buffer[byte_off*8 +: 32]; 

                    //$display("disp: %x", disp[31:0]);

                    scale_factor[31:0] = disp[31:0]; 
                    inc = inc + num_disp_bytes;// + 1;
                    $display("IB1");
             //   end
             /*   else begin
                    num_disp_bytes[2:0] = 3'b000;
                    disp[31:0] = 0; 
                    scale_factor[31:0] = {29'b0,base[2:0]}; 
                    inc = inc + num_disp_bytes + 1;
                    $display("IB2");
                end
            end
            else if (base[2:0] == 3'b101 ) begin
                num_disp_bytes[2:0] = 3'b100;
                //disp[31:0] = buffer[(byte_off+32'b1)*8 +: 32]; 
                disp[31:0] = buffer[byte_off*8 +: 32]; 
                scale_factor[31:0] = (index[2:0] * scale[1:0]) + disp[31:0]; 
                inc = inc + num_disp_bytes + 1;
                $display("IB3");
            end
            else begin
                num_disp_bytes[2:0] = 3'b000;
                disp[31:0] = 32'b0; 
                scale_factor[31:0] = (index[2:0] * scale[1:0]) + {29'b0,base[2:0]}; 
                inc = inc + num_disp_bytes + 1;
                $display("IB4");
            end*/
        end 
        else if (modrm[7:6] == 2'b01 ) begin
          //  if (index[3:0] == 4'b0100 ) begin
                num_disp_bytes[2:0] = 3'b001;
                //disp[31:0] = {24'b0, buffer[(byte_off+32'b1)*8 +: 8]}; 
                disp[31:0] = {24'b0, buffer[byte_off*8 +: 8]}; 
                scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]}; 
                inc = inc + num_disp_bytes;// + 1;
                $display("IB5");
        /*    end
            else begin
                num_disp_bytes[2:0] = 3'b001;
                //disp[31:0] = {24'b0, buffer[(byte_off+32'b1)*8 +: 8]}; 
                disp[31:0] = {24'b0, buffer[byte_off*8 +: 8]}; 
                scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]} +(index[2:0] * scale[1:0]) ; 
                inc = inc + num_disp_bytes + 1;
                $display("IB6");
            end*/
        end
        else if (modrm[7:6] == 2'b10 ) begin
         //   if (index[3:0] == 4'b0100 ) begin
                num_disp_bytes[2:0] = 3'b100;
                //disp[31:0] = buffer[(byte_off+1)*8 +: 32]; 
                disp[31:0] = buffer[byte_off*8 +: 32]; 
                scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]}; 
                inc = inc + num_disp_bytes;// + 1 ;
                $display("IB7");
        /*    end
            else begin
                num_disp_bytes[2:0] = 3'b100;
                //disp[31:0] = buffer[(byte_off+1)*8 +: 32]; 
                disp[31:0] = buffer[byte_off*8 +: 32]; 
                scale_factor[31:0] = disp[31:0] + {29'b0,base[2:0]} + (index[2:0] * scale[1:0]) ; 
                inc = inc + num_disp_bytes + 1;
                $display("IB8");
            end*/
        end 
        else begin
            $display("IB9");
        end

//		end
//		else begin

//			 $display("No SIB present");
//		end

		if (scale_factor == 0);

        next_byte_offset = inst_byte_offset + inc;
        //next_byte_offset = inst_byte_offset + inc - 1;
		//	next_byte_offset = inc;
		next_field_type = IMMEDIATE | LEGACY_PREFIX;
		// $display("Next Byte Offset: %d , Inst_byte_offset: %d, inc:%d ",next_byte_offset,inst_byte_offset,inc);
		//$display("Scale factor: 0x%x", scale_factor[31:0]);
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



task decode;
//	output logic[0:0] curr_comp_flag;
	output logic[0:0] sig_id_nop; 
	output logic[15:0] id_out_req;
	output logic[15:0] id_out_prov;
	output logic[3:0] increment_by;
	output logic[7:0] operation; 
	output logic[1:0] num_op;
	output operand_t src_type;
	output operand_t dest_type;
	output logic[63:0] src_val;
	output logic[63:0] dest_val;
	output logic[1:0] src_size;
	output logic[1:0] dest_size;
//	input logic[0:0] comp_flag;


	logic[3:0] offs;
	logic[3:0] offs2;
	logic[3:0] offs3;
	logic[3:0] offs4;
//	logic[3:0] offs4b;
	logic[3:0] offs5;
	logic[3:0] offs6;
	logic[3:0] offs7;
	logic[3:0] offs8;
	inst_field_t next_fld_type;

	begin

  /*      if(buffer[0:119]==120'b0 && comp_flag==1'b1) begin
            sig_id_nop=1'b1;
        end
*/
        sig_id_nop=1'b0;
        if(buffer[0:119]==120'b0) begin
            sig_id_nop=1'b1;
            //curr_comp_flag=1'b1;
            increment_by=15;
        end

        else begin
            //curr_comp_flag=1'b0;
		$display("Start ............................................................................");

        instr[7:0] = 0;
		opcode_stream[359:0] = "                        ";
		mnemonic_stream[255:0] = "                                ";
		optr[7:0] = 8'b0;
		mptr[7:0] = 8'b0;
		next_fld_type = LEGACY_PREFIX;
		offs = 0;

		for (int j = 0 ; j < 15 ; j++) begin
            if(buffer[offs*8 +: 8]==8'b0) begin
                offs=offs+1;
            end
		end

//        increment_by=offs;

        $display("buffer is: %x",buffer[0:119]);
        $display("OFFS: %x",offs);

        offs2 = offs;
		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX ) begin
			check_legacy_prefix(offs2,next_fld_type,offs);
		end

		offs3 = offs2;
		if ((next_fld_type & REX_PREFIX) == REX_PREFIX ) begin
			check_rex_prefix(offs3,next_fld_type,offs2);
		end
/*
		offs4b = offs3;
		if ((next_fld_type & LEGACY_PREFIX) == LEGACY_PREFIX ) begin
			check_legacy_prefix(offs4b,next_fld_type,offs3);
		end
*/
		offs4 = offs3;
		if ((next_fld_type & OPCODE) == OPCODE ) begin
			check_opcode(offs4,next_fld_type,offs3);
			//$display("increment by op: %d",offs4);
		end

		offs5 = offs4;
		if ((next_fld_type & MOD_RM) == MOD_RM ) begin
			check_modrm(offs5,next_fld_type,offs4);
			//$display("increment by modrm: %d",offs5);
		end
		offs6 = offs5;
		offs7 = offs6;
		//$display("next_fld_type: %x SIB: %x", next_fld_type, SIB);
		if ((next_fld_type & SIB) == SIB ) begin
			check_sib(offs7,next_fld_type,offs6);
			// $display("increment by SIB: %d",offs7);
		end

		offs8 = offs7;
		if (num_inst_bytes == 2'b01) begin
		//	$display("One byte instr");
			decode_instr(offs8, num_op, src_type, dest_type, src_val, dest_val, src_size, dest_size, offs7);
			// $display("increment by decode_instr : %d",offs8);
		end
//		else
//			decode_instr2(offs8,offs7);
		// TODO: handle two byte opcodes



		increment_by = offs8;
	    $display("increment by %d and offs8 is %d ",increment_by,offs8);
		byte_incr = increment_by;
		operation[7:0] = instr[7:0];
		$display("%x: %s %s", current_addr[63:0], opcode_stream[359:0],mnemonic_stream[255:0]); 
//		$display("END ............................................................................");
		// To suppress errors
		if (mnemonic_stream == 0);
		if (opcode_stream[359:0] == 0);
		if (instr[7:0] == 0);
		if (optr[7:0] == 0);
		if (mptr[7:0] == 0);
		if (current_addr == 0);	
		if (num_inst_bytes == 2'b01);
		if (dispsize == 0);

        id_out_req=id_requests;
        id_out_prov=id_provides;
   
       // $display("Byte Incr: %d",byte_incr);

        end
	end
    
endtask

task endianswap;
	output logic[63:0] swapped;
	input  logic[63:0] given;

	begin
		for (int i = 1 ; i <= 32'd8 ; i++) begin
			swapped[63 - 8*i -: 8] = given[8*i +:8];  
		end
	end
endtask

endmodule
