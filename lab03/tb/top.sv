module top;
	
mult_bfm bfm();
tpgen tpgen_i (bfm);
coverage coverage_i (bfm);
scoreboard scoreboard_i(bfm);


//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
vdic_dut_2023 DUT (
	.clk(bfm.clk), 
	.rst_n(bfm.rst_n), 
	.arg_a(bfm.arg_a), 
	.arg_a_parity(bfm.arg_a_parity), 
	.arg_b(bfm.arg_b), 
	.arg_b_parity(bfm.arg_b_parity), 
	.req(bfm.req), 
	
	.ack(bfm.ack), 
	.result(bfm.result), 
	.result_parity(bfm.result_parity), 
	.result_rdy(bfm.result_rdy), 
	.arg_parity_error(bfm.arg_parity_error)
	);


endmodule : top