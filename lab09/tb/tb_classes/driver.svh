class driver extends uvm_driver #(sequence_item);
    `uvm_component_utils(driver)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    
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
    endfunction : build_phase
    
//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
    task run_phase(uvm_phase phase);
        sequence_item cmd;

	    void'(begin_tr(cmd));
        forever begin : cmd_loop
            seq_item_port.get_next_item(cmd);
            bfm.send_data(cmd.rst_n, cmd.arg_a, cmd.arg_a_parity, cmd.arg_b, cmd.arg_b_parity);
        	seq_item_port.item_done();
        end : cmd_loop
        end_tr(cmd);
        
    endtask : run_phase
    

endclass : driver

