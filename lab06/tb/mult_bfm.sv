interface mult_bfm;
import mult_pkg::*;

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
// wait for ready
//------------------------------------------------------------------------------
task wait_ready();
	wait(result_rdy);
endtask : wait_ready

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
	end
endtask : send_data

//------------------------------------------------------------------------------
// write command monitor
//------------------------------------------------------------------------------
always @(posedge clk) begin
    command_s command;
    if (req) begin
	    command.rst_n = rst_n;
        command.arg_a = arg_a;
	    command.arg_a_parity = arg_a_parity;
        command.arg_b = arg_b;
	    command.arg_b_parity = arg_b_parity;
        command_monitor_h.write_to_monitor(command);
    end
end

always @(negedge rst_n) begin : rst_monitor
    command_s command;
    command.rst_n = 0;
    if (command_monitor_h != null) //guard against VCS time 0 negedge
        command_monitor_h.write_to_monitor(command);
end : rst_monitor

//------------------------------------------------------------------------------
// write result monitor
//------------------------------------------------------------------------------
initial begin : result_monitor_thread
	result_s res;
    forever begin
        @(posedge clk) ;
        if (result_rdy) begin
	        res.arg_parity_error = arg_parity_error;
	        res.result_parity = result_parity;
	        res.result = result;
            result_monitor_h.write_to_monitor(res);
	    end
    end
end : result_monitor_thread


endinterface : mult_bfm
