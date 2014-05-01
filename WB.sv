module WB(
);

typedef enum { RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8, R9, R10, R11, R12, R13, R14, R15 } regname;

task write_back;
    output logic[0:0] sig_out_nop;
    output logic[63:0] regx[16];
    input logic[3:0] dstreg;
	input logic[63:0] resl;
	input logic[0:0] sig_wb_in_nop;

	logic[63:0] wbregx[16];
	begin
		wbregx[dstreg] = resl;

        regx=wbregx;
        if(sig_wb_in_nop==1'b1) begin
            sig_out_nop=sig_wb_in_nop;
        end

        if(dstreg[3:0] != 4'hf);


//		$display("WB: dstreg=%x val=%x",dst_reg[3:0], wbregx[dst_reg[3:0]][63:0]); 
		if(wbregx[dstreg[3:0]]==64'b0);
		
	end
endtask

endmodule
