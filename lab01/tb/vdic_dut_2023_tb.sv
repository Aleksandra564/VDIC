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
            $display("%0t Clock cycles elapsed: %0d", $time, clk_counter);
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
	    @(posedge clk)
	    arg_a = get_data();
	    arg_b = get_data();
	    arg_a_parity = parity_bit_check(arg_a);
	    arg_b_parity = parity_bit_check(arg_b);
	    
		req = 1'b1;
	    
	    wait(ack);			// wait until ack == 1
	    wait(result_rdy);	// wait until result is ready
	    req = 1'b0;
		    
	    //------------------------------------------------------------------------------
	    // temporary data check - scoreboard will do the job later
	    begin
	        expected_data = get_expected(arg_a, arg_b);
		    parity_expected = get_parity(expected_data);
		    
		    // PARITY ERROR TEST
		    if(arg_parity_error == 1) begin		// parity error
			    if(result == 0) begin	// parity error -> result == 0
			    	$display("Parity error flag test PASSED");
			    end
			    else begin
				    test_result = TEST_FAILED;
			    	$display("Parity error flag test FAILED");
				end
			end
		    
		    else begin		// no parity error
		    	// MULTIPLICATION TEST
		        if(result == expected_data) begin
		            $display("MUL test PASSED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
		        end
		        else begin
		            $display("MUL test FAILED for arg_a=%0d arg_b=%0d", arg_a, arg_b);
		            $display("Expected: %d, received: %d", expected_data, result);
		            test_result = TEST_FAILED;
		        end;

			    // PARITY TEST
			    if(result_parity != parity_expected) begin
				    test_result = TEST_FAILED;
				    $display("Parity test FAILED for arg_a=%0d arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d. Result parity=%0d, expected parity=%0d.", arg_a, arg_b, arg_a_parity, arg_b_parity, result_parity, parity_expected);
			    end
			    else begin
					$display("Parity test PASSED");
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
	@(posedge clk);
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
function logic get_parity(
		logic signed [31:0] arg
	);
	logic result;
	
	result = ^ arg;		// xor
endfunction : get_parity

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
// check if parity
//------------------------------------------------------------------------------
function logic parity_bit_check(
		logic signed [15:0] arg
	);
	logic result;
	logic no_parity_result;
	logic [1:0] zero_ones;
	
	zero_ones = 2'($random);	// 75% chance to generate proper parity
	result = ^ arg;		// xor
	no_parity_result = ^ arg + 1;	// wrong parity bit
	
	if(zero_ones == 2'b11) begin	// 25% chance to get wrong parity
		return(no_parity_result);
	end
	else begin
		return(result);
	end
	
endfunction : parity_bit_check

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


endmodule : top
