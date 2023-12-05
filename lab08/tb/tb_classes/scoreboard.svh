class scoreboard extends uvm_subscriber #(result_transaction);
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
    uvm_tlm_analysis_fifo #(command_transaction) cmd_f;
    local test_result_t test_result = TEST_PASSED; // the result of the current test

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// print the PASSED/FAILED in color
//------------------------------------------------------------------------------
	local function void print_test_result (test_result_t r);
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
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// Calculate expected results
//------------------------------------------------------------------------------
	local function result_transaction predict_results(command_transaction cmd);
        result_transaction predicted;
		
		predicted = new("predicted");
		
		// ARG PARITY ERROR
		if(cmd.arg_a_parity == ^cmd.arg_a && cmd.arg_b_parity == ^cmd.arg_b) begin
			predicted.arg_parity_error = 0;	// no parity error
			
			// EXPECTED MULT RESULT
			predicted.result = cmd.arg_a*cmd.arg_b;
			
			// EXPECTED PARITY
			predicted.result_parity = ^predicted.result;
		end
		else begin
			predicted.arg_parity_error = 1;	// parity error
			predicted.result = 0;
			predicted.result_parity = 0;
		end
		
		return predicted;
		
	endfunction

//------------------------------------------------------------------------------
// subscriber write function
//------------------------------------------------------------------------------
    function void write(result_transaction t);
	    string data_str;
        command_transaction cmd;
        result_transaction predicted;
        
        do begin
            if (!cmd_f.try_get(cmd))
                $fatal(1, "Missing command in self checker");
        end
        while (cmd.rst_n == 0);	// get commands until rst_n == 0
  
        predicted = predict_results(cmd);
        
        data_str  = {cmd.convert2string(),
            " ==>  Actual " , t.convert2string(),
            "/Predicted ", predicted.convert2string()};

        if (!predicted.compare(t)) begin
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
            test_result = TEST_FAILED;
        end
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
	endfunction : write

//------------------------------------------------------------------------------
// report phase
//------------------------------------------------------------------------------
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SELF CHECKTER", "Reporting test result below", UVM_LOW)
        print_test_result(test_result);
    endfunction : report_phase

endclass : scoreboard
