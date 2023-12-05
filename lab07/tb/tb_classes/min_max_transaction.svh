class min_max_transaction extends command_transaction;
    `uvm_object_utils(min_max_transaction)

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint min_max{
	    arg_a dist {16'sh8000:=1, 16'sh7FFF:=1};
        arg_b dist {16'sh8000:=1, 16'sh7FFF:=1};
	}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name="");
        super.new(name);
    endfunction
    
    
endclass : min_max_transaction


