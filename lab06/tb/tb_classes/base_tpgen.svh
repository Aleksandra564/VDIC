virtual class base_tpgen extends uvm_component;
	
//------------------------------------------------------------------------------
// port for sending the transactions
//------------------------------------------------------------------------------
    uvm_put_port #(command_s) command_port;

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
        command_port = new("command_port", this);
    endfunction : build_phase

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
	task run_phase(uvm_phase phase);
		command_s command;
	
		phase.raise_objection(this);
		command.rst_n = 1;
        command_port.put(command);
		command.rst_n = 0;
		
	    repeat (1000) begin : random_loop
	        command.arg_a = get_data();
	        command.arg_b = get_data();
		    command.arg_a_parity = get_input_parity(command.arg_a);
		    command.arg_b_parity = get_input_parity(command.arg_b);
		    
		    command_port.put(command);
		    wait(command.result_rdy);	// zmienic bo nie moge dostac na commandzie wyjscia DUTa
	    end : random_loop
	    
	    // reset until DUT finish processing data
	    command_port.put(command);
	    command.rst_n = 1;
	    command_port.put(command);
		command.rst_n = 0;
	    
	    phase.drop_objection(this);
	endtask : run_phase
	
endclass : base_tpgen
