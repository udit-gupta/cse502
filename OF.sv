module OF ( 
	input logic[63:0] regx[16]
);

typedef enum { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15 } regname;

typedef enum {
	REGISTER,
	MEMORY,
	IMM
} operand_t;

task operand_fetch;
	output logic[0:0] sig_of_nop;
	output logic[15:0] of_out_req;
	output logic[15:0] of_out_prov;
	output logic[3:0] srcreg;
	output logic[3:0] dstreg;
	output logic[7:0] oper;
	output logic[63:0] oper1;
	output logic[63:0] oper2;
	input logic[63:0] oper_curr;
	input logic[7:0] operatn;
	input logic[1:0] oper_numop;
	input logic[31:0] opsrcty;
	input logic[31:0] opdestty;
	input logic[63:0] opsrcval;
	input logic[63:0] opdestval;
	input logic[1:0] opsrcsize;
	input logic[1:0] opdestsize;
	input logic[0:0] num_src_regs;
	input logic[0:0] sig_of_in_nop;

    logic[15:0] of_requests=16'b0;
    logic[15:0] of_provides=16'b0;

    
	$display("Opdestval : %x ", opdestval[63:0]);
	$display("Opsrcval : %x ", opsrcval[63:0]);
	$display("Opsrcty : %x ", opsrcty[31:0]);
	$display("Opdestty : %x ", opdestty[31:0]);
    if(sig_of_in_nop==1'b1) begin
        sig_of_nop=1'b1;
    end

    else begin

	oper[7:0] = operatn;

    $display("of_in= %b ",of_requests);

	case (opsrcsize[1:0])
		2'b00:  begin
			oper1[7:0] = regx[opdestval[3:0]][7:0];
			if (opsrcty == REGISTER) begin
				oper2[7:0] = regx[opsrcval[3:0]][7:0];
			end 
			else begin
				oper2[7:0] = opsrcval[7:0];
			end
	//		$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		2'b01: begin
			oper1[15:0] = regx[opdestval[3:0]][15:0];
			if (opsrcty == REGISTER) begin
				oper2[15:0] = regx[opsrcval[3:0]][15:0];
			end 
			else begin
				oper2[15:0] = opsrcval[15:0];
			end
	//		$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		2'b10: begin 
			oper1[31:0] = regx[opdestval[3:0]][31:0];
			if (opsrcty == REGISTER) begin
				oper2[31:0] = regx[opsrcval[3:0]][31:0];
			end 
			else begin
				oper2[31:0] = opsrcval[31:0];
			end
		//	$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		2'b11: begin
			oper1[63:0] = regx[opdestval[3:0]][63:0];
			if (opsrcty == REGISTER) begin
				oper2[63:0] = regx[opsrcval[3:0]][63:0];
			end 
			else begin
				oper2[63:0] = opsrcval[63:0];
			end
	//		$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		default:;
	endcase

    if(opsrcty==REGISTER) begin
	    srcreg[3:0] = opsrcval[3:0];
    end
    else begin
	    srcreg[3:0] = 4'hf;
    end
    dstreg[3:0] = opdestval[3:0];
	$display("OF: dstreg=%x",dstreg[3:0]);	

            $display("opsrcval=%x",opsrcval[63:0]);
    if(opsrcty==REGISTER) begin
        if(opsrcval[63:0] != 64'hdeadbeefdeadbeef) begin
            of_requests=1<<opsrcval[3:0];
        end
    end

	// To suppress errors 
	if( regx[16] ==0); 
	if( oper_curr==0);
	if(operatn==0);
	if(oper_numop==0);
	if( opsrcty==0);
	if( opdestty==0);
	if( opsrcval==0);
	if( opdestval==0);
	if(opsrcsize==0);
	if(opdestsize==0);
	if (oper1 == 0);
	if (oper2 == 0);
    
    if(opdestval[63:0]!=64'hffffffffffffffff) begin
        of_provides=1<<opdestval[3:0];
    end
    
    if(num_src_regs==1'b1) begin
        of_requests= (of_requests | of_provides);
    end

    of_out_req=of_requests;
    of_out_prov=of_provides;

    end
endtask



endmodule
