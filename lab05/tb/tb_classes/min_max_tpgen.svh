class min_max_tpgen extends random_tpgen;
    `uvm_component_utils(min_max_tpgen)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// function: get_op - generate random opcode for the tpgen
//------------------------------------------------------------------------------
	protected function logic signed [15:0] get_data();
	    bit zero_one = 1'($random);
	
	    if (zero_one == 1'b0)
	        return 16'sh8000;				// 16-bit data SIGNED min
	    else		
	        return 16'sh7FFF;				// 16-bit data SIGNED max
	    
	endfunction : get_data


endclass : min_max_tpgen
