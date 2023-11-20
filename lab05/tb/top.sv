module top;
	
import uvm_pkg::*;
`include "uvm_macros.svh"
import mult_pkg::*;
	
mult_bfm bfm();
	
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
	
initial begin
    uvm_config_db #(virtual mult_bfm)::set(null, "*", "bfm", bfm);
    run_test();
end

endmodule : top
