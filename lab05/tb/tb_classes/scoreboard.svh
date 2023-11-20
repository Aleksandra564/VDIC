class scoreboard extends uvm_component;
    `uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// Local type definitions
//------------------------------------------------------------------------------
	protected typedef enum bit {
	    TEST_PASSED,
	    TEST_FAILED
	} test_result_t;
	
	protected typedef struct packed {
	    logic signed [15:0] A;
	    logic signed [15:0] B;
		bit A_parity;
		bit B_parity;
	    logic signed [31:0] result;
		logic result_parity;
		logic parity_error_flag;	// 1, if A_parity or B_parity is invalid
	} data_packet_t;
	
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
	protected virtual mult_bfm bfm;
	protected test_result_t test_result = TEST_PASSED;

    // fifo for storing input and expected data
    protected data_packet_t sb_data_q[$];

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// Calculate expected result
//------------------------------------------------------------------------------
	protected function logic signed [31:0] get_expected(
	        logic signed [15:0] a,
	        logic signed [15:0] b
		);
		
	    logic signed [31:0] ret;
		
	    ret = a*b;		// mul result
	    return(ret);
	endfunction : get_expected
	
//------------------------------------------------------------------------------
// checks if any input parity is wrong (then output parity flag should be 1)
//------------------------------------------------------------------------------
	protected function logic check_input_parity(
			logic signed [15:0] A,
			logic signed [15:0] B,
			bit A_parity,
			bit B_parity
		);
		logic parity_err_flag;
		
		if(A_parity == ^A && B_parity == ^B) begin
			parity_err_flag = 0;	// no parity error
		end
		else begin
			parity_err_flag = 1;	// parity error
		end
		
		return parity_err_flag;
		
	endfunction

//---------------------------------
// Calculate expected parity
//---------------------------------
	protected function logic get_result_parity(
			logic signed [31:0] arg
		);
		logic result;
		
		result = ^ arg;		// xor
		return(result);
	endfunction : get_result_parity
	
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
	protected task store_cmd();
		logic start_prev;
		logic signed [31:0] mult_result;
		logic parity_error_flag;
		
		forever begin : scoreboard_fe_blk
			@(posedge bfm.clk)
		    if(bfm.req == 1 && start_prev == 0) begin
			    mult_result = get_expected(bfm.arg_a, bfm.arg_b);
			    parity_error_flag = check_input_parity(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity);
		        sb_data_q.push_front(data_packet_t'({bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity, mult_result, get_result_parity(mult_result), parity_error_flag}));
		    end
		    start_prev = bfm.req;
		end
	endtask : store_cmd
	
	protected task process_data_from_dut();
		forever begin : scoreboard_be_blk
			@(negedge bfm.clk)
		    if(bfm.result_rdy) begin:verify_result
		        data_packet_t dp;
		
		        dp = sb_data_q.pop_back();
		
		        // PARITY ERROR FLAG TEST
		        CHK_PARITY_FLAG_RESULT: assert(bfm.arg_parity_error === dp.parity_error_flag) begin
		           `ifdef DEBUG
		            $display("PARITY ERROR FLAG TEST: %0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
		           `endif
		        end
		        else begin
		            test_result = TEST_FAILED;
		            $error("PARITY ERROR FLAG TEST: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
		                $time, dp.A, dp.B, dp.parity_error_flag, bfm.arg_parity_error);
		        end
		        
		        // PARITY TEST
		        if(dp.parity_error_flag == 0) begin
			        CHK_PARITY_RESULT: assert(bfm.result_parity === dp.result_parity) begin
			           `ifdef DEBUG
			            $display("PARITY TEST: %0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
			           `endif
			        end
			        else begin
			            test_result = TEST_FAILED;
			            $error("PARITY TEST: %0t Test FAILED for A=%0d B=%0d Ap=%0d Bp=%0d\nExpected: %d  received: %d",
			                $time, dp.A, dp.B, dp.A_parity, dp.B_parity, dp.result_parity, bfm.result_parity);
			        end
			        
				    // MULT TEST
			        CHK_MULT_RESULT: assert(bfm.result === dp.result) begin	//checks if result from dut == result from dp
			           `ifdef DEBUG
			            $display("MULTIPLICATION TEST: %0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
			           `endif
			        end
			        else begin
			            test_result = TEST_FAILED;
			            $error("MULTIPLICATION TEST: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
			                $time, dp.A, dp.B, dp.result, bfm.result);
			        end
		        end
		        
		    end
		end : scoreboard_be_blk
	endtask : process_data_from_dut
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        fork
            store_cmd();
            process_data_from_dut();
        join_none
    endtask : run_phase

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
	protected function void print_test_result (test_result_t r);
	    if(r == TEST_PASSED) begin
	        set_print_color(COLOR_BOLD_BLACK_ON_GREEN);
	        $write ("-----------------------------------\n");
	        $write ("----------- Test PASSED -----------\n");
	        $write ("-----------------------------------");
	        set_print_color(COLOR_DEFAULT);
	        $write ("\n");
	    end
	    else begin
	        set_print_color(COLOR_BOLD_BLACK_ON_RED);
	        $write ("-----------------------------------\n");
	        $write ("----------- Test FAILED -----------\n");
	        $write ("-----------------------------------");
	        set_print_color(COLOR_DEFAULT);
	        $write ("\n");
	    end
	endfunction

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(test_result);
    endfunction : report_phase

	
endclass : scoreboard
