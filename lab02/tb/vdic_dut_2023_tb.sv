module top;

//------------------------------------------------------------------------------
// Type definitions
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
	

test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .result_rdy, .arg_parity_error);


//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking for min and max arguments of the MULT
covergroup edge_cases;

    option.name = "cg_edge_cases";


    a_leg: coverpoint arg_a {
	    bins zeros = {16'sh0000};
        bins min = {16'sh8000};		// signed int MIN
        bins max  = {16'sh7FFF};	// signed int MAX
        bins negative = {[16'sh8001:16'shFFFF]};	// [MIN+1:-1]
        bins positive = {[16'sh0001:16'sh7FFE]};	// [1:MAX-1]   
    }

    b_leg: coverpoint arg_b {
	    bins zeros = {16'sh0000};
        bins min = {16'sh8000};		// signed int MIN
        bins max  = {16'sh7FFF};	// signed int MAX
        bins negative = {[16'sh8001:16'shFFFF]};	// [MIN+1:-1]
        bins positive = {[16'sh0001:16'sh7FFE]};	// [1:MAX-1] 
    }

    mult_edge_cases: cross a_leg, b_leg {

        // min * max
        bins min_max = binsof (a_leg.min) && binsof (b_leg.max);

        // min * min
        bins min_min = binsof (a_leg.min) && binsof (b_leg.min);
	    
	    // max * max
        bins max_max = binsof (a_leg.max) && binsof (b_leg.max);
	    
	    // zero * anything
        bins zero_any = binsof (a_leg.zeros) && binsof (b_leg.min);

    }
    
    
    a_par: coverpoint arg_a_parity {
	    bins zero = {0};
	    bins one = {1};
    }
    
    b_par: coverpoint arg_b_parity {
	    bins zero = {0};
	    bins one = {1};
    }  
    
    a_parity_cases: cross a_leg, a_par {
	    
	    bins max_par_correct = binsof(a_leg.max) && binsof(a_par.one);	// checks MAX with correct parity (par = 1)
		bins max_par_wrong = binsof(a_leg.max) && binsof(a_par.zero);	// checks MAX with wrong parity (par = 0)
	    
	    bins zero_par_correct = binsof(a_leg.zeros) && binsof(a_par.zero);	// checks ZERO with correct parity (par = 0)
		bins zero_par_wrong = binsof(a_leg.zeros) && binsof(a_par.one);	// checks ZERO with wrong parity (par = 1)
		
    }
    
    b_parity_cases: cross b_leg, b_par {
	    
	    bins max_par_correct = binsof(b_leg.max) && binsof(b_par.one);	// checks MAX with correct parity (par = 1)
		bins max_par_wrong = binsof(b_leg.max) && binsof(b_par.zero);	// checks MAX with wrong parity (par = 0)
	    
	    bins zero_par_correct = binsof(b_leg.zeros) && binsof(b_par.zero);	// checks ZERO with correct parity (par = 0)
		bins zero_par_wrong = binsof(b_leg.zeros) && binsof(b_par.one);	// checks ZERO with wrong parity (par = 1)
		
    }
    

endgroup

edge_cases a_b_edge_cases;

initial begin : coverage
	
    a_b_edge_cases = new();
    forever begin : sample_cov
        @(posedge clk);
        if(result_rdy || !rst_n) begin
            a_b_edge_cases.sample();
            
            /* #1step delay is necessary before checking for the coverage
             * as the .sample methods run in parallel threads
             */
            #1step; 
            if($get_coverage() == 100) break; //disable, if needed
            
            // you can print the coverage after each sample
//            $strobe("%0t coverage: %.4g\%",$time, $get_coverage());
        end
    end
end : coverage


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

// timestamp monitor
initial begin
    longint clk_counter;
    clk_counter = 0;
    forever begin
        @(posedge clk) clk_counter++;
        if(clk_counter % 1000 == 0) begin
	        `ifdef DEBUG
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
        	`endif
        end
    end
end


//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------
initial begin : tester					// generates data and signals
	logic signed [31:0] expected_data;
	logic parity_expected;
	
	reset_mult();
	
    repeat (1000) begin : tester_main_blk
	    @(negedge clk)
	    arg_a = get_data();
	    arg_b = get_data();
	    arg_a_parity = get_input_parity(arg_a);
	    arg_b_parity = get_input_parity(arg_b);
	    
		req = 1'b1;
	    wait(ack);			// wait until ack == 1
	    req = 1'b0;
	    wait(result_rdy);	// wait until result is ready

    end : tester_main_blk
    
	// reset until DUT finish processing data (for 100% code coverage)
	arg_a = get_data();
	arg_b = get_data();
	arg_a_parity = get_input_parity(arg_a);
	arg_b_parity = get_input_parity(arg_b);
	    
	req = 1'b1;
	wait(ack);
	req = 1'b0;
	reset_mult();	// reset until DUT finish processing data
    
    $finish;
end : tester


//------------------------------------------------------------------------------
// tasks and functions
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// reset task
//------------------------------------------------------------------------------
task reset_mult();
	req = 1'b0;
	rst_n = 1'b0;
	@(negedge clk);
	rst_n = 1'b1;
endtask: reset_mult
	
	
//---------------------------------
// Random data generation functions
//---------------------------------
function logic signed [15:0] get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'sh8000;				// 16-bit data SIGNED min
    else if (zero_ones == 3'b111)		
        return 16'sh7FFF;				// 16-bit data SIGNED max
    else if (zero_ones == 3'b001)		
	    return 16'sh0000;				// generate all zeros
    else
        return 16'($random);
endfunction : get_data

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
// calculate expected result
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
// get_input_parity - CAN RETURN WRONG VALUE FOR TESTS
//------------------------------------------------------------------------------
function logic get_input_parity(
		logic signed [15:0] arg
	);
	logic result;
	logic no_parity_result;
	logic [1:0] zero_ones;
	
	zero_ones = 2'($random);	// 75% chance to generate proper parity
	result = ^ arg;		// xor
	no_parity_result = !(^ arg);	// wrong parity bit
	
	if(zero_ones == 2'b11) begin	// 25% chance to get wrong parity
		return(no_parity_result);
	end
	else begin
		return(result);
	end
	
endfunction : get_input_parity

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

//------------------------------------------------------------------------------
// Temporary. The scoreboard will be later used for checking the data
final begin : finish_of_the_test
    print_test_result(test_result);
end

//------------------------------------------------------------------------------
// Other functions
//------------------------------------------------------------------------------

// used to modify the color of the text printed on the terminal
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

always @(posedge clk) begin: scoreboard_fe_blk
    if(req == 1 && start_prev == 0) begin
	    mult_result = get_expected(arg_a, arg_b);
	    parity_error_flag = check_input_parity(arg_a, arg_b, arg_a_parity, arg_b_parity);
        sb_data_q.push_front(data_packet_t'({arg_a, arg_b, arg_a_parity, arg_b_parity, mult_result, get_result_parity(mult_result), parity_error_flag}));	// zmienic to zero
    end
    start_prev = req;
end

always @(negedge clk) begin : scoreboard_be_blk
    if(result_rdy) begin:verify_result
        data_packet_t dp;

        dp = sb_data_q.pop_back();

        // PARITY ERROR FLAG TEST
        CHK_PARITY_FLAG_RESULT: assert(arg_parity_error === dp.parity_error_flag) begin
           `ifdef DEBUG
            $display("PARITY ERROR FLAG TEST: %0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
           `endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("PARITY ERROR FLAG TEST: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
                $time, dp.A, dp.B, dp.parity_error_flag, arg_parity_error);
        end
        
        // PARITY TEST
        if(dp.parity_error_flag == 0) begin
	        CHK_PARITY_RESULT: assert(result_parity === dp.result_parity) begin
	           `ifdef DEBUG
	            $display("PARITY TEST: %0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
	           `endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("PARITY TEST: %0t Test FAILED for A=%0d B=%0d Ap=%0d Bp=%0d\nExpected: %d  received: %d",
	                $time, dp.A, dp.B, dp.A_parity, dp.B_parity, dp.result_parity, result_parity);
	        end
	        
		    // MULT TEST
	        CHK_MULT_RESULT: assert(result === dp.result) begin	//checks if result from dut == result from dp
	           `ifdef DEBUG
	            $display("MULTIPLICATION TEST: %0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
	           `endif
	        end
	        else begin
	            test_result = TEST_FAILED;
	            $error("MULTIPLICATION TEST: %0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
	                $time, dp.A, dp.B, dp.result, result);
	        end
        end
        
    end
end : scoreboard_be_blk





endmodule : top
