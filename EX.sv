module EX(
);


task alu;
	output logic[3:0] out_dest_reg;
	output logic[63:0] res;
	input logic[7:0] oper;
	input logic[63:0] op1;
	input logic[63:0] op2;
	input logic[3:0] in_dest_reg;

begin
		case (oper[7:0])
			// ADD instruction
			8'h0:   res = op1 + op2;
			8'h1:   res = op1 + op2;  
			8'h2:   res = op1 + op2;
			8'h3:   res = op1 + op2;
			8'h4:   res = op1 + op2;
			8'h5:   res = op1 + op2;
			8'h80:  res = op1 + op2;
			8'h81:  res = op1 + op2;
			8'h83:  res = op1 + op2;

			// SUB instruction
			8'h28:  res = op1 - op2;
			8'h29:  res = op1 - op2;
			8'h2A:  res = op1 - op2;
			8'h2B:  res = op1 - op2;
			8'h2C:  res = op1 - op2;
			// 8'h80:  res = op1 - op2;
			// 8'h81:  res = op1 - op2;
			// 8'h83:  res = op1 - op2;

			// MUL instruction
			// 8'hF6: res = op1 * op2;
			// 8'hF7: res = op1 * op2;

			// DIV instruction
			// 8'hF6: res = op1 / op2;
			// 8'hF7: res = op1 / op2;

			// IMUL instruction
			8'h69: res = op1 * op2;
			8'h6B: res = op1 * op2;
			// 8'hF6: res = op1 * op2;
			// 8'hF7: res = op1 * op2;
			
			// IDIV instruction
			// 8'hF6: res = op1 / op2;
			// 8'hF7: res = op1 / op2;

			// AND instruction
			8'h20:   res = op1 & op2;
			8'h21:   res = op1 & op2;  
			8'h22:   res = op1 & op2;
			8'h23:   res = op1 & op2;
			8'h24:   res = op1 & op2;
			8'h25:   res = op1 & op2;
			// 8'h80:  res = op1 & op2;
			// 8'h81:  res = op1 & op2;
			// 8'h83:  res = op1 & op2;


			// OR instruction
			8'h8:  res = op1 | op2;
			8'h9:  res = op1 | op2;
			8'hA:  res = op1 | op2;
			8'hB:  res = op1 | op2;
			8'hC:  res = op1 | op2;
			// 8'h80:  res = op1 | op2;
			// 8'h81:  res = op1 | op2;
			// 8'h83:  res = op1 | op2;

			// XOR instruction 
			8'h30:   res = op1 ^ op2;
			8'h31:   res = op1 ^ op2;  
			8'h32:   res = op1 ^ op2;
			8'h33:   res = op1 ^ op2;
			8'h34:   res = op1 ^ op2;
			8'h35:   res = op1 ^ op2;
			// 8'h80:  res = op1 ^ op2;
			// 8'h81:  res = op1 ^ op2;
			// 8'h83:  res = op1 ^ op2;


			// NOT instruction
			// 8'hF6: res = ~op1;
			// 8'hF7: res = ~op1;

			// NEG instruction
			// 8'hF6: res = ~op1 + 1;
			// 8'hF7: res = ~op1 + 1;

			// CMP instruction 
			8'h38:  res = op1 - op2;
			8'h39:  res = op1 - op2;
			8'h3A:  res = op1 - op2;
			8'h3B:  res = op1 - op2;
			8'h3C:  res = op1 - op2;
			// 8'h80:  res = op1 - op2;
			// 8'h81:  res = op1 - op2;
			// 8'h83:  res = op1 - op2;

			// MOV instruction
			8'h88: res = op2;
			8'h89: res = op2;
			8'h8A: res = op2;
			8'h8B: res = op2;
			8'h8C: res = op2;
			8'h8E: res = op2;
			8'hA0: res = op2;
			8'hA1: res = op2;
			8'hA2: res = op2;
			8'hA3: res = op2; 
			8'hB0: res = op2;
			8'hB1: res = op2;
			8'hB2: res = op2;
			8'hB3: res = op2;
			8'hB4: res = op2;
			8'hB5: res = op2;
			8'hB6: res = op2;
			8'hB7: res = op2;
			8'hB8: res = op2;
			8'hB9: res = op2;
			8'hBA: res = op2;
			8'hBB: res = op2;
			8'hBC: res = op2;
			8'hBD: res = op2;
			8'hBE: res = op2;
			8'hBF: res = op2;
			8'hC6: res = op2;
			8'hC7: res = op2;


			default:
			begin 
				res = 64'b0;
		//		$display("EX: Instruction %x not supported by ALU", oper[7:0]);
			end
		endcase
			out_dest_reg[3:0] = in_dest_reg[3:0];
		//	$display("EX: op1=%x op2=%x res=%x destreg=%x inst=%x", op1[63:0], op2[63:0], res[63:0],out_dest_reg[3:0],oper[7:0]);
	end
endtask

endmodule
