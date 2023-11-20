`timescale 1ns/1ps

package mult_pkg;
    import uvm_pkg::*;
	`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// package typedefs
//------------------------------------------------------------------------------
	typedef enum{
	    COLOR_BOLD_BLACK_ON_GREEN,
	    COLOR_BOLD_BLACK_ON_RED,
	    COLOR_BOLD_BLACK_ON_YELLOW,
	    COLOR_BOLD_BLUE_ON_WHITE,
	    COLOR_BLUE_ON_WHITE,
	    COLOR_DEFAULT
	} print_color_t;

//------------------------------------------------------------------------------
// package functions
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

//------------------------------------------------------------------------------
// testbench classes
//------------------------------------------------------------------------------
	`include "base_tpgen.svh"
	`include "random_tpgen.svh"
	`include "min_max_tpgen.svh"

	`include "coverage.svh"
	`include "scoreboard.svh"
	`include "env.svh"
	
//------------------------------------------------------------------------------
// test classes
//------------------------------------------------------------------------------
	`include "random_test.svh"
	`include "min_max_test.svh"
	
endpackage : mult_pkg
	