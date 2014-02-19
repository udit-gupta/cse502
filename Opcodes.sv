module Opcodes(
	output logic[3:0] byte_incr, 
	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ 
	Sysbus bus
	/* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
	,
    input logic[0:15*8-1] buffer);

typedef logic[63:0] mystring;
mystring op[0:4];

initial begin
op[0] = "ADD";
op[1] = "ADD";
op[2] = "ADD";
op[3] = "ADD";
if (op[1] == 0);
if (buffer == 0);
byte_incr = 1;
end

endmodule
