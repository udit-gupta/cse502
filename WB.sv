module WB(
	input logic[63:0] regx[16]
);

typedef enum { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15 } regname;

task write_back;
	input logic[3:0] dst_reg;
	input logic[63:0] res;

	begin
		regx[dst_reg[3:0]][63:0] = res[63:0];
//		$display("WB: dstreg=%x val=%x",dst_reg[3:0], regx[dst_reg[3:0]][63:0]); 
		if(regx[dst_reg[3:0]]==64'b0);
		
	end
endtask

endmodule
