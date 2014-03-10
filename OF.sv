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

	oper[7:0] = operatn;

	case (opsrcsize[1:0])
		2'b00:  begin
			oper1[7:0] = regx[opdestval[3:0]][7:0];
			if (opsrcty == IMM) begin
				oper2[7:0] = regx[opsrcval[3:0]][7:0];
			end 
			else begin
				oper2[7:0] = opsrcval[7:0];
			end
			$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		2'b01: begin
			oper1[15:0] = regx[opdestval[3:0]][15:0];
			if (opsrcty == IMM) begin
				oper2[15:0] = regx[opsrcval[3:0]][15:0];
			end 
			else begin
				oper2[15:0] = opsrcval[15:0];
			end
			$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		2'b10: begin 
			oper1[31:0] = regx[opdestval[3:0]][31:0];
			if (opsrcty == IMM) begin
				oper2[31:0] = regx[opsrcval[3:0]][31:0];
			end 
			else begin
				oper2[31:0] = opsrcval[31:0];
			end
			$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		2'b11: begin
			oper1[63:0] = regx[opdestval[3:0]][63:0];
			if (opsrcty == IMM) begin
				oper2[63:0] = regx[opsrcval[3:0]][63:0];
			end 
			else begin
				oper2[63:0] = opsrcval[63:0];
			end
			$display("OF: Operands %x %x", oper1[7:0], oper2[7:0]);
		end
		default:;
	endcase

	dstreg[3:0] = opdestval[3:0];
	$display("OF: dstreg=%x",dstreg[3:0]);	


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
	
endtask


endmodule
