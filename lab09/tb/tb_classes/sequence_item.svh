class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------
    bit 						rst_n;
	rand logic signed 	[15:0] 	arg_a;
	rand bit               		arg_a_parity;
	rand logic signed 	[15:0] 	arg_b;        
	rand bit               		arg_b_parity;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------
    `uvm_object_utils_begin(sequence_item)
//        `uvm_field_int(A, UVM_ALL_ON | UVM_DEC)
//        `uvm_field_int(B, UVM_ALL_ON | UVM_DEC)
//        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
//        `uvm_field_int(result, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint data {
	    arg_a dist {[16'sh8000:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFF]:/1};
	    arg_b dist {[16'sh8000:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFF]:/1};
    }

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------
    function string convert2string();
        return {super.convert2string(),
            $sformatf("rst_n: %1h arg_a: %4h arg_b: %4h arg_a_parity: %1h arg_b_parity: %1h", rst_n, arg_a, arg_b, arg_a_parity, arg_a_parity)
        };
    endfunction : convert2string

endclass : sequence_item


