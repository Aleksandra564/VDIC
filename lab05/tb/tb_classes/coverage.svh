class coverage;
	
	protected virtual mult_bfm bfm;

	protected logic signed 	[15:0] 	arg_a;
	protected bit               	arg_a_parity;
	protected logic signed 	[15:0] 	arg_b;        
	protected bit               	arg_b_parity;

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
	
	
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
	function new (virtual mult_bfm b);
	    edge_cases   = new();
	    bfm          = b;
	endfunction : new
	
	
//------------------------------------------------------------------------------
// Execute task
//------------------------------------------------------------------------------
	task execute();
	    forever begin : sampling_block
	        @(posedge bfm.clk);
		    arg_a = bfm.arg_a;
			arg_a_parity = bfm.arg_a_parity;
			arg_b = bfm.arg_b;        
			arg_b_parity = bfm.arg_b_parity;
		    
	        if(bfm.result_rdy || !bfm.rst_n) begin
	            edge_cases.sample();
	            #1step; 
	            if($get_coverage() == 100) break; //disable, if needed
	        end
	    end : sampling_block
	endtask : execute


endclass : coverage
