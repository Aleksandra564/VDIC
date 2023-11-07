interface mult_bfm;
	
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------

logic               	clk;
logic 					rst_n;
logic signed 	[15:0] 	arg_a;
logic               	arg_a_parity;
logic signed 	[15:0] 	arg_b;        
logic               	arg_b_parity;
logic               	req;
	
logic               	ack;
logic signed 	[31:0] 	result;
logic               	result_parity;
logic               	result_rdy;
logic               	arg_parity_error; // 1, if A_parity or B_parity is invalid
	
	
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
	input logic signed 	[15:0] 	iA,
	input logic               	iA_parity,
	input logic signed 	[15:0] 	iB,
	input logic               	iB_parity
	);

    arg_a = iA;
    arg_b = iB;
	arg_a_parity = iA_parity;
	arg_b_parity = iB_parity;

    req = 1'b1;
	    
	wait(ack);			// wait until ack == 1
	req = 1'b0;
	wait(result_rdy);	// wait until result is ready

endtask : send_data

	
endinterface : mult_bfm