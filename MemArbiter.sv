module MemArbiter #(DATA_WIDTH = 64, TAG_WIDTH = 1) (
    /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ Sysbus bus, /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
    output logic[6:0] buf_offset,
    input logic[63:0] fetch_ad,
    //output logic[0:2*64*8-1] mem_buffer,
    //output logic[0:2*64*8-1] mem_buffer,
    output logic[0:64*8-1] mem_buffer,
    input logic send_fetch_req_in,
    output logic[0:0] mem_req_completed,
    output logic[6:0] num_bytes
);

enum { fetch_idle, fetch_waiting, fetch_active } fetch_state;
//logic[5:0] fetch_skip;
//logic[6:0] buf_offset;
logic[63:0] fetch_addr;
logic send_fetch_req;

always_comb begin
    $display("fetch_addr: %x", fetch_addr);
    $display("decode_buffer: %x" , mem_buffer);
    $display("send_fetch_Req_in: %x" , send_fetch_req_in);
    if (fetch_state != fetch_idle) begin
        $display("no fetch");
        send_fetch_req = 0; // hack: in theory, we could try to send another request at this point
    end else if (bus.reqack) begin
        $display("no bus.reqack");
        send_fetch_req = 0; // hack: still idle, but already got ack (in theory, we could try to send another request as early as this)
    end else begin
        $display("update fetch");
        send_fetch_req = send_fetch_req_in; 
    end
    $display("send_Fetch_req: %x" , send_fetch_req);
end

assign bus.respack = bus.respcyc; // always able to accept response



always @ (posedge bus.clk) begin
    if (bus.reset) begin
        fetch_state <= fetch_idle;
        fetch_addr <= fetch_ad; ////& ~63;
        //		fetch_skip <= 6'b100000;//fetch_ad [5:0];
        //		mem_req_completed <= 1;
    end else begin // !bus.reset

        if (fetch_state == fetch_idle) begin
            fetch_addr <= fetch_ad;
//            fetch_addr <= fetch_addr;
            bus.reqcyc <= send_fetch_req;
            bus.reqtag <= { bus.READ, bus.MEMORY, 8'b0 };
            //bus.req <= fetch_addr;// & ~63;
            bus.req <= fetch_ad;// & ~63;
            mem_req_completed <= 1'b0;
        end
        else begin
            fetch_addr <= fetch_addr;
        end

        $display("bus_req: %x" , bus.req);
        $display("bus_reqtag: %x" , bus.reqtag);
        $display("fetch_ad: %x" , fetch_ad);

        if (bus.respcyc) begin
            $display("bus1 !!!!!!!!");
            mem_req_completed <= 1'b0;
            assert(!send_fetch_req) else $fatal;
            fetch_state <= fetch_active;
            fetch_addr <= fetch_addr + 8;

            num_bytes <= num_bytes + 8;
            //			if (fetch_skip > 0) begin
                //                  $display("bus2 !!!!!!!!");
                //				$display("fetch_skip: %x" , fetch_skip);
                //				fetch_skip <= fetch_skip - 8;
                //			end else begin
                    $display("bus3 !!!!!!!!");
                    mem_buffer[buf_offset*8 +: 64] <= bus.resp;
                    buf_offset <= buf_offset + 8;
                    $display("fetch_buffer: %x" , mem_buffer);
                    //			end
         end else begin
                    $display("else bus !!!!!!!!");
                    fetch_addr <= fetch_addr;
                    num_bytes <= 0;
                    if (fetch_state == fetch_active) begin
                        $display("bus4 !!!!!!!!");
                        fetch_state <= fetch_idle;
                        buf_offset <= 0;
                        mem_req_completed <= 1'b1;
                    end else if (bus.reqack) begin
                        $display("bus5 !!!!!!!!");
                        assert(fetch_state == fetch_idle) else $fatal;
                        fetch_state <= fetch_waiting;
                    end
                end

            end
        end

        endmodule
