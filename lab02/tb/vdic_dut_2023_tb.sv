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
logic               	arg_parity_error;
	

test_result_t        test_result = TEST_PASSED;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

vdic_dut_2023 DUT (.clk, .rst_n, .arg_a, .arg_a_parity, .arg_b, .arg_b_parity, .req, .ack, .result, .result_parity, .result_rdy, .arg_parity_error);





//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

// Covergroup checking the multiplication and parity
covergroup operation_tests;

    option.name = "cg_operation_tests";

    coverpoint op_set {
        // #A1 test all operations
        bins A1_single_cycle[] = {[add_op : xor_op], rst_op, no_op};
    }

endgroup

// Covergroup checking for min and max arguments of the MULT
covergroup edge_cases;

    option.name = "cg_edge_cases";

    all_ops : coverpoint op_set {
        ignore_bins null_ops = {rst_op, no_op};
    }

    a_leg: coverpoint arg_a {
	    bins zero = {'sh0000};
        bins min = {'sh8000};	// signed int MIN
        bins others= {['sh8001:'shFFFF], ['sh0001:'sh7FFE]};	// [MIN+1:MAX-1] except 0
        bins max  = {'sh7FFF};	// signed int MAX
    }

    b_leg: coverpoint arg_b {
	    bins zero = {'sh0000};
        bins min = {'sh8000};
        bins others= {['sh8001:'shFFFF], ['sh0001:'sh7FFE]};
        bins max  = {'sh7FFF};
    }

    B_op_00_FF: cross a_leg, b_leg, all_ops {

        // #B1 simulate all zero input for all the operations

        bins B1_add_00          = binsof (all_ops) intersect {add_op} &&
        (binsof (a_leg.zeros) || binsof (b_leg.zeros));

        // #B2 simulate all one input for all the operations

        bins B2_add_FF          = binsof (all_ops) intersect {add_op} &&
        (binsof (a_leg.ones) || binsof (b_leg.ones));

        ignore_bins others_only =
        binsof(a_leg.others) && binsof(b_leg.others);
    }

endgroup

operation_tests		op_t;
edge_cases			a_b_edge_cases;

initial begin : coverage
    op_t = new();
    a_b_edge_cases = new();
    forever begin : sample_cov
        @(posedge clk);
        if(result_rdy || !rst_n) begin
            op_t.sample();
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

initial begin : tester
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
	    wait(result_rdy);	// wait until result is ready
	    req = 1'b0;
		    
	    //------------------------------------------------------------------------------
	    // temporary data check - scoreboard will do the job later
	    begin
	        expected_data = get_expected(arg_a, arg_b);
		    parity_expected = get_result_parity(expected_data);
		    
		    // PARITY ERROR FLAG TEST
		    if(arg_parity_error == 1) begin		// parity error
			    if(result == 0) begin	// parity error -> result == 0
			    	`ifdef DEBUG
			    	$display("Parity error flag test PASSED");
			    	`endif
			    end
			    else begin
				    test_result = TEST_FAILED;
			    	`ifdef DEBUG
			    	$display("Parity error flag test FAILED");
					`endif
				end
			end
		    
		    else begin		// no parity error
		    	// MULTIPLICATION TEST
		        if(result == expected_data) begin
		            `ifdef DEBUG
		            $display("MUL test PASSED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
		        	`endif
		        end
		        else begin
		            `ifdef DEBUG
		            $display("MUL test FAILED for arg_a=%0d arg_b=%0d. Expected: %d, received: %d", arg_a, arg_b, expected_data, result);
		            `endif
		            test_result = TEST_FAILED;
		        end;

			    // PARITY TEST
			    if(result_parity != parity_expected) begin
				    test_result = TEST_FAILED;
				    `ifdef DEBUG
				    $display("Parity test FAILED for arg_a=%0d arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d. Result parity=%0d, expected parity=%0d.", arg_a, arg_b, arg_a_parity, arg_b_parity, result_parity, parity_expected);
			    	`endif
			    end
			    else begin
					`ifdef DEBUG
					$display("Parity test PASSED");
			    	`endif
			    end
		    end
		end
    end : tester_main_blk
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
endfunction : get_result_parity

//------------------------------------------------------------------------------
// calculate expected result
//------------------------------------------------------------------------------
function logic [31:0] get_expected(
        logic signed [15:0] a,
        logic signed [15:0] b
	);
	
    logic signed [31:0] ret;
	
    ret = a*b;			// mul result
    return(ret);
endfunction : get_expected

//------------------------------------------------------------------------------
// get_input_parity
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
	logic parity_error_flag;
} data_packet_t;

data_packet_t sb_data_q [$];
logic signed [31:0] mult_result;

always @(posedge clk) begin: scoreboard_fe_blk
    if(req == 1 && start_prev == 0) begin
	    mult_result <= get_expected(arg_a, arg_b);
        sb_data_q.push_front(data_packet_t'({arg_a, arg_b, arg_a_parity, arg_b_parity, mult_result, get_result_parity(mult_result), arg_parity_error}));
    end
    start_prev <= req;
end

always @(negedge clk) begin : scoreboard_be_blk
    if(result_rdy) begin:verify_result
        data_packet_t dp;

        dp = sb_data_q.pop_back();

	    // MULT TEST
        CHK_MULT_RESULT: assert(result === dp.result) begin	//checks if result from dut == result from dp
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
           `endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("%0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
                $time, dp.A, dp.B, dp.result, result);
        end;
        
        // PARITY TEST
        CHK_PARITY_RESULT: assert(result_parity === dp.result_parity) begin
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
           `endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("%0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
                $time, dp.A, dp.B, dp.result_parity, result_parity);
        end;
        
        // PARITY ERROR FLAG TEST
        CHK_PARITY_FLAG_RESULT: assert(arg_parity_error === dp.parity_error_flag) begin
           `ifdef DEBUG
            $display("%0t Test passed for A=%0d B=%0d", $time, dp.A, dp.B);
           `endif
        end
        else begin
            test_result = TEST_FAILED;
            $error("%0t Test FAILED for A=%0d B=%0d\nExpected: %d  received: %d",
                $time, dp.A, dp.B, dp.parity_error_flag, arg_parity_error);
        end;
    end
end : scoreboard_be_blk





endmodule : top
