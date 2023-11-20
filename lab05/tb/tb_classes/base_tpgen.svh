virtual class base_tpgen extends uvm_component;
	
	protected virtual mult_bfm bfm;	

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
	
//------------------------------------------------------------------------------
// function prototypes
//------------------------------------------------------------------------------
    pure virtual protected function logic signed [15:0] get_data();
    pure virtual protected function logic get_input_parity(logic signed [15:0] arg);

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		logic signed 	[15:0] 	iA;
		bit               		iA_parity;
		logic signed 	[15:0] 	iB;        
		bit               		iB_parity;
		
		logic signed 	[31:0] 	result;
		logic               	result_parity;
	
		phase.raise_objection(this);
	    bfm.reset_mult();
		
	    repeat (1000) begin : random_loop
	        iA = get_data();
	        iB = get_data();
		    iA_parity = get_input_parity(iA);
		    iB_parity = get_input_parity(iB);
		    
	        bfm.send_data(iA, iA_parity, iB, iB_parity);
		    bfm.wait_ready();	// wait until result is ready
	    end : random_loop
	    
	    // reset until DUT finish processing data
	    bfm.send_data(iA, iA_parity, iB, iB_parity);
	    bfm.reset_mult();
	    
	    phase.drop_objection(this);
	    
	endtask : run_phase
	
endclass : base_tpgen
