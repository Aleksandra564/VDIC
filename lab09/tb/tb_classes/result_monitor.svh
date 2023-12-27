class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    local virtual mult_bfm bfm;
    uvm_analysis_port #(result_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*", "bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM");
        ap = new("ap",this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// connect phase
//------------------------------------------------------------------------------
   function void connect_phase(uvm_phase phase);
      bfm.result_monitor_h = this;
   endfunction : connect_phase

//------------------------------------------------------------------------------
// interface function for BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(
		logic signed 	[31:0] 	result,
		logic 					result_parity,
		logic 					arg_parity_error
	    );
	    
        result_transaction result_t;
        result_t = new("result_t");
	    
	    result_t.result = result;
	    result_t.result_parity = result_parity;
	    result_t.arg_parity_error = arg_parity_error;
	    
        ap.write(result_t);
    endfunction : write_to_monitor

endclass : result_monitor






