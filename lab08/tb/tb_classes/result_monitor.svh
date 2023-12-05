class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
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
        // get the bfm 
        mult_agent_config agent_config_h;
        if(!uvm_config_db #(mult_agent_config)::get(this, "", "config", agent_config_h))
            `uvm_fatal("RESULT MONITOR", "Failed to get CONFIG");

        // pass the result_monitor handler to the BFM
        agent_config_h.bfm.result_monitor_h = this;
		
        ap = new("ap", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// access function for BFM
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






