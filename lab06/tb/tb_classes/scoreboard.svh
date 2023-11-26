class scoreboard extends uvm_subscriber #(result_s);
    `uvm_component_utils(scoreboard)
	
//------------------------------------------------------------------------------
// Local type definitions
//------------------------------------------------------------------------------
	protected typedef enum bit {
	    TEST_PASSED,
	    TEST_FAILED
	} test_result_t;
	
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    uvm_tlm_analysis_fifo #(command_s) cmd_f;
    protected test_result_t test_result = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

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
// Calculate expected result
//------------------------------------------------------------------------------
	protected function logic signed [31:0] get_expected(	// albo int
	        logic signed [15:0] a,
	        logic signed [15:0] b
		);
		
	    logic signed [31:0] ret;
		
	    ret = a*b;		// mul result
	    return(ret);
	endfunction : get_expected
	
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

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(result_s res);
	    
        logic signed [31:0] predicted_mult_result;
		logic predicted_parity_result;
	    logic predicted_parity_flag;

        command_s cmd;
	    cmd.rst_n = 0;
        cmd.arg_a = 0;
        cmd.arg_b = 0;
	    cmd.arg_a_parity = 0;
	    cmd.arg_b_parity = 0;
	    
        do
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        while (cmd.rst_n == 1);	// get commands until rst_n == 1

        predicted_mult_result = get_expected(cmd.arg_a, cmd.arg_b);
	    predicted_parity_result = get_result_parity(predicted_mult_result);
	    predicted_parity_flag = check_input_parity(cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity);

		// PARITY ERROR FLAG TEST
		CHK_PARITY_FLAG_RESULT: 
		assert(res.arg_parity_error == predicted_parity_flag) begin
		    `ifdef DEBUG
		    $display("PARITY ERROR FLAG TEST: %0t Test passed for A=%0d B=%0d", $time, cmd.arg_a, cmd.arg_b);
		    `endif
		end
		else begin
		    test_result = TEST_FAILED;
		    $error("PARITY ERROR FLAG TEST: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d", $time, cmd.arg_a, cmd.arg_b, predicted_parity_flag, res.arg_parity_error);
		end

		// PARITY TEST
		if(predicted_parity_flag == 0) begin
			CHK_PARITY_RESULT: 
			assert(res.result_parity == predicted_parity_result) begin
			    `ifdef DEBUG
			    $display("PARITY TEST: %0t Test passed for A=%0d B=%0d", $time, cmd.arg_a, cmd.arg_b);
			    `endif
			end
			else begin
			    test_result = TEST_FAILED;
			    $error("PARITY TEST: %0t Test FAILED for A=%0d B=%0d Ap=%0d Bp=%0d\nExpected: %d  received: %d", $time, cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity, predicted_parity_result, res.result_parity);
			end
			
			// MULT TEST
			CHK_MULT_RESULT: 
			assert(res.result == predicted_mult_result) begin	//checks if result from dut == expected result
				`ifdef DEBUG
				$display("MULTIPLICATION TEST: %0t Test passed for A=%0d B=%0d", $time, cmd.arg_a, cmd.arg_b);
				`endif
			end
			else begin
				test_result = TEST_FAILED;
				$error("MULTIPLICATION TEST: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d", $time, cmd.arg_a, cmd.arg_b, predicted_mult_result, res.result);
			end
		end
	endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_test_result(test_result);
    endfunction : report_phase

	
endclass : scoreboard
