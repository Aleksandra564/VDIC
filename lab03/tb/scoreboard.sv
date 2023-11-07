module scoreboard(mult_bfm bfm);
	
//------------------------------------------------------------------------------
// Local type definitions
//------------------------------------------------------------------------------
typedef enum bit {
    TEST_PASSED,
    TEST_FAILED
} test_result_t;

typedef enum {
    COLOR_BOLD_BLACK_ON_GREEN,
    COLOR_BOLD_BLACK_ON_RED,
    COLOR_BOLD_BLACK_ON_YELLOW,
    COLOR_BOLD_BLUE_ON_WHITE,
    COLOR_BLUE_ON_WHITE,
    COLOR_DEFAULT
} print_color_t;
	
//------------------------------------------------------------------------------
// Local variables
//------------------------------------------------------------------------------
test_result_t        test_result = TEST_PASSED;
	
//------------------------------------------------------------------------------
// Calculate expected result
//------------------------------------------------------------------------------
function logic signed [31:0] get_expected(
        logic signed [15:0] a,
        logic signed [15:0] b
	);
	
    logic signed [31:0] ret;
	
    ret = a*b;			// mul result
    return(ret);
endfunction : get_expected
	
//------------------------------------------------------------------------------
// checks if any input parity is wrong (then output parity flag should be 1)
//------------------------------------------------------------------------------
function logic check_input_parity(
		logic signed [15:0] A,
		logic signed [15:0] B,
		logic A_parity,
		logic B_parity
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
function logic get_result_parity(
		logic signed [31:0] arg
	);
	logic result;
	
	result = ^ arg;		// xor
	return(result);
endfunction : get_result_parity
	
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
logic start_prev;

typedef struct packed {
    logic signed [15:0] A;
    logic signed [15:0] B;
	logic A_parity;
	logic B_parity;
    logic signed [31:0] result;
	logic result_parity;
	logic parity_error_flag;	// 1, if A_parity or B_parity is invalid
} data_packet_t;

data_packet_t sb_data_q [$];
logic signed [31:0] mult_result;
logic parity_error_flag;

always @(posedge bfm.clk) begin: scoreboard_fe_blk
    if(bfm.req == 1 && start_prev == 0) begin
	    mult_result = get_expected(bfm.arg_a, bfm.arg_b);
	    parity_error_flag = check_input_parity(bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity);
        sb_data_q.push_front(data_packet_t'({bfm.arg_a, bfm.arg_b, bfm.arg_a_parity, bfm.arg_b_parity, mult_result, get_result_parity(mult_result), parity_error_flag}));
    end
    start_prev = bfm.req;
end

always @(negedge bfm.clk) begin : scoreboard_be_blk
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
	
//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------
function void set_print_color ( print_color_t c );
    string ctl;
    case(c)
        COLOR_BOLD_BLACK_ON_GREEN : ctl  = "\033\[1;30m\033\[102m";
        COLOR_BOLD_BLACK_ON_RED : ctl    = "\033\[1;30m\033\[101m";
        COLOR_BOLD_BLACK_ON_YELLOW : ctl = "\033\[1;30m\033\[103m";
        COLOR_BOLD_BLUE_ON_WHITE : ctl   = "\033\[1;34m\033\[107m";
        COLOR_BLUE_ON_WHITE : ctl        = "\033\[0;34m\033\[107m";
        COLOR_DEFAULT : ctl              = "\033\[0m\n";
        default : begin
            $error("set_print_color: bad argument");
            ctl                          = "";
        end
    endcase
    $write(ctl);
endfunction

function void print_test_result (test_result_t r);
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
// Print the test result at the simulation end
//------------------------------------------------------------------------------
final begin : finish_of_the_test
    print_test_result(test_result);
end

	
endmodule : scoreboard