class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(command_transaction) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction
    
//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        bfm.command_monitor_h = this;
        ap = new("ap",this);
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// access function for BMF
//------------------------------------------------------------------------------
    function void write_to_monitor(
	    bit 					rst_n,
		logic signed 	[15:0] 	arg_a,
		bit               		arg_a_parity,
		logic signed 	[15:0] 	arg_b, 
		bit               		arg_b_parity
	    );
	    
        command_transaction cmd;
        `uvm_info("COMMAND MONITOR",$sformatf("COMMAND MONITOR: arg_a=%0d, arg_b=%0d, arg_a_parity=%0d, arg_b_parity=%0d", cmd.arg_a, cmd.arg_b, cmd.arg_a_parity, cmd.arg_b_parity), UVM_HIGH);
        cmd = new("cmd");
        cmd.rst_n = rst_n;
        cmd.arg_a = arg_a;
        cmd.arg_b = arg_b;
        cmd.arg_a_parity = arg_a_parity;
        cmd.arg_b_parity = arg_b_parity;
       
        ap.write(cmd);
    endfunction : write_to_monitor
    

endclass : command_monitor

