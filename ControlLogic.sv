module ControlLogic (
);            
           

task stall;
	
    output[0:0] cl_out_nop_id;
	output[0:0] cl_out_nop_of;
	output[0:0] cl_out_nop_ex;
    
    input[15:0] id_out_req;
    input[15:0] id_out_prov;
    input[15:0] of_out_req;
    input[15:0] of_out_prov;
    input[15:0] ex_out_req;
    input[15:0] ex_out_prov;
    /*
    logic[15:0] requests_id;
    logic[15:0] provides_id;
    logic[15:0] requests_of;
    logic[15:0] provides_of;
    logic[15:0] requests_ex;
    logic[15:0] provides_ex;
*/

    logic[15:0] id_stat;
    logic[15:0] of_stat;
    logic[15:0] ex_stat;

    logic[0:0] cl_out_nop_id_local;
	logic[0:0] cl_out_nop_of_local;
	logic[0:0] cl_out_nop_ex_local;
    
    begin
/*
        requests_id=id_out_req  | of_out_req  | ex_out_req;
        provides_id=id_out_prov | of_out_prov | ex_out_prov;


        requests_of=of_out_req  | ex_out_req;
        provides_of=of_out_prov | ex_out_prov;

        requests_ex=ex_out_req;
        provides_ex=ex_out_prov;

  */
  
 
        id_stat= (id_out_req & (of_out_prov|ex_out_prov)) 
                |(of_out_req & (id_out_prov|ex_out_prov)) 
                |(ex_out_req & (id_out_prov|of_out_prov));
 
 
        of_stat= (of_out_req & ex_out_prov) | (ex_out_req & of_out_prov);
 
        ex_stat=16'b0;
        
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
/*
        if((requests & provides) == 16'b0) begin
            cl_out_nop=0;
            $display("hello");
        end
       else begin
            cl_out_nop=1;
            $display("buffallo");
       /*     if(requests && provides == 1'd0) begin
                cl_out_nop1=1;
            
            end
        end */
   //     end
   end
endtask

endmodule
