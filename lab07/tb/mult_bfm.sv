import mult_pkg::*;
interface mult_bfm;

//------------------------------------------------------------------------------
// DUT connections
//------------------------------------------------------------------------------
bit               		clk;
bit 					rst_n;
logic signed 	[15:0] 	arg_a;
bit               		arg_a_parity;
logic signed 	[15:0] 	arg_b;        
bit               		arg_b_parity;
bit               		req;
	
logic               	ack;
logic signed 	[31:0] 	result;
logic               	result_parity;
logic               	result_rdy;
logic               	arg_parity_error; // 1, if A_parity or B_parity is invalid
	
command_monitor command_monitor_h;
result_monitor result_monitor_h;
	
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------
initial begin : clk_gen_blk
    clk = 0;
    forever begin : clk_frv_blk
        #10;
        clk = ~clk;
    end
end

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
task reset_mult();
	req = 1'b0;
	rst_n = 1'b0;
	@(negedge clk);
	rst_n = 1'b1;
endtask: reset_mult

//------------------------------------------------------------------------------
// send_data
//------------------------------------------------------------------------------
task send_data(
	input bit					irst,
	input logic signed 	[15:0] 	iA,
	input logic               	iA_parity,
	input logic signed 	[15:0] 	iB,
	input logic               	iB_parity
	);
	
	if(irst) begin
		reset_mult();
	end
	else begin
	    arg_a = iA;
	    arg_b = iB;
		arg_a_parity = iA_parity;
		arg_b_parity = iB_parity;
        
	    req = 1'b1;
		wait(ack);	// wait until ack == 1
		req = 1'b0;
		wait(result_rdy);
	end
endtask : send_data

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
always @(posedge clk) begin
    if (req) begin
        command_monitor_h.write_to_monitor(rst_n, arg_a, arg_a_parity, arg_b, arg_b_parity);
    end
end

always @(negedge rst_n) begin : rst_monitor
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(0, arg_a, arg_a_parity, arg_b, arg_b_parity);
end : rst_monitor

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------
initial begin : result_monitor_thread
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
            result_monitor_h.write_to_monitor(result, result_parity, arg_parity_error);
	    end
    end
end : result_monitor_thread


endinterface : mult_bfm
