class min_max_sequence_item extends sequence_item;
    `uvm_object_utils(min_max_sequence_item)

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
    function new(string name = "min_max_sequence_item");
        super.new(name);
    endfunction : new

endclass : min_max_sequence_item


