module ControlLogic (
    output[0:0] cl_out_nop_id,
	output[0:0] cl_out_nop_of,
	output[0:0] cl_out_nop_ex,
	output[0:0] cl_out_nop_wb,
    input[15:0] id_out_req,
    input[15:0] id_out_prov
//	/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ Sysbus bus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
);            
           
    logic[15:0] temp_fill=16'b0;
    logic[15:0] of_out_req=16'b0;
    logic[15:0] of_out_prov=16'b0;
    logic[15:0] ex_out_req=16'b0;
    logic[15:0] ex_out_prov=16'b0;
    logic[15:0] wb_out_req=16'b0;
    logic[15:0] wb_out_prov=16'b0;

    logic[15:0] id_stat=16'b0;
    logic[15:0] of_stat=16'b0;
    logic[15:0] ex_stat=16'b0;
    logic[15:0] wb_stat=16'b0;

    logic[0:0] cl_out_nop_id_local;
	logic[0:0] cl_out_nop_of_local;
	logic[0:0] cl_out_nop_ex_local;
	logic[0:0] cl_out_nop_wb_local;

    always_comb begin
        
        id_stat= ((id_out_req | id_out_prov) & (of_out_prov|ex_out_prov|wb_out_prov)) 
                |((of_out_req | of_out_prov) & (id_out_prov|ex_out_prov|wb_out_prov)) 
                |((ex_out_req | ex_out_prov) & (id_out_prov|of_out_prov|wb_out_prov))
                |((wb_out_req | wb_out_prov) & (id_out_prov|of_out_prov|ex_out_prov));

        of_stat= ((of_out_req | of_out_prov) & (ex_out_prov|wb_out_prov)) 
                |((ex_out_req | ex_out_prov) & (of_out_prov|wb_out_prov)) 
                |((wb_out_req | wb_out_prov) & (of_out_prov|ex_out_prov));
        

        ex_stat= ((ex_out_req | ex_out_prov) & wb_out_prov) 
                |((wb_out_req | wb_out_prov) & ex_out_prov);
        
        
        wb_stat=16'b0;

        $display("id_stat:%x ,of_stat:%x ,ex_stat:%x ,wb_stat:%x ",id_stat,of_stat,ex_stat,wb_stat);
        $display("id_out_req:%b ",id_out_req);
        $display("id_out_prov:%b ",id_out_prov);
        $display("of_out_req:%b ",of_out_req);
        $display("of_out_prov:%b ",of_out_prov);
        $display("ex_out_req:%b ",ex_out_req);
        $display("ex_out_prov:%b ",ex_out_prov);
        $display("wb_out_req:%b ",wb_out_req);
        $display("wb_out_prov:%b ",wb_out_prov);
        



        if (id_stat ==16'b0) begin
            cl_out_nop_id_local=0;
        end
        else begin
            cl_out_nop_id_local=1;
        end

        if (of_stat==16'b0) begin
            cl_out_nop_of_local=0;
        end
        else begin
            cl_out_nop_of_local=1;
        end

        if (ex_stat==16'b0) begin
            cl_out_nop_ex_local=0;
        end
        else begin
            cl_out_nop_ex_local=1;
        end

        if (wb_stat==16'b0) begin
            cl_out_nop_wb_local=0;
        end
        else begin
            cl_out_nop_wb_local=1;
        end

        if(cl_out_nop_id_local == 1'b0) begin
            cl_out_nop_id=0;
        end
        else begin
            cl_out_nop_id=1;
        end

        if(cl_out_nop_of_local == 1'b0) begin
            cl_out_nop_of=0;
        end
        else begin
            cl_out_nop_of=1;
        end

        if(cl_out_nop_ex_local == 1'b0) begin
            cl_out_nop_ex=0;
        end
        else begin
            cl_out_nop_ex=1;
        end

        if(cl_out_nop_wb_local == 1'b0) begin
            cl_out_nop_wb=0;
        end
        else begin
            cl_out_nop_wb=1;
        end
    end     

/*   if(of_out_req[15:0]==16'b0);
   if(of_out_prov[15:0]==16'b0);
   if(ex_out_req[15:0]==16'b0);
   if(ex_out_prov[15:0]==16'b0);
   if(wb_out_rieq[15:0]==16'b0);
   if(wb_out_prov[15:0]==16'b0);
  */
    always @ (posedge bus.clk)
        if(bus.reset) begin
            of_out_req  <= 0;
            of_out_prov <= 0;
            ex_out_req  <= 0;
            ex_out_prov <= 0;
            wb_out_req  <= 0;
            wb_out_prov <= 0;
        end
        else begin
            of_out_req  <= id_out_req;
            of_out_prov <= id_out_prov;
            ex_out_req  <= of_out_req;
            ex_out_prov <= of_out_prov;
            wb_out_req  <= ex_out_req;
            wb_out_prov <= ex_out_prov;

            if(cl_out_nop_id==1'b1) begin
                of_out_req  <= temp_fill;
                of_out_prov <= temp_fill;
            end

            if(cl_out_nop_of==1'b1) begin
                ex_out_req  <= temp_fill;
                ex_out_prov <= temp_fill;
            end

            if(cl_out_nop_ex==1'b1) begin
                wb_out_req  <= temp_fill;
                wb_out_prov <= temp_fill;
            end
        end
endmodule
