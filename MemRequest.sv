/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */
interface MemRequest #(DATA_WIDTH = 64, TAG_WIDTH = 1) (
	input reset
,	input clk
);

logic[6:0] load_buf_offset;
logic[63:0] load_fetch_ad;
logic[0:64*8-1] load_mem_buffer;
logic load_send_fetch_req_in;
logic[0:0] load_mem_req_completed;
logic[6:0] load_num_bytes;


modport Client (
input load_buf_offset,
output load_fetch_ad,
input load_mem_buffer,
output load_send_fetch_req_in,
input load_mem_req_completed,
input load_num_bytes
);

modport Server (
output load_buf_offset,
input load_fetch_ad,
output load_mem_buffer,
input load_send_fetch_req_in,
output load_mem_req_completed,
output load_num_bytes
);

endinterface
/* verilator lint_on UNUSED */
/* verilator lint_on UNDRIVEN */
