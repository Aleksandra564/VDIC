class result_transaction extends uvm_transaction;

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------
	logic signed 	[31:0] 	result;
	logic 					result_parity;
	logic 					arg_parity_error;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// transaction methods - do_copy, convert2string, do_compare
//------------------------------------------------------------------------------
    function void do_copy(uvm_object rhs);
        result_transaction copied_transaction_h;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(copied_transaction_h, rhs)) else
            `uvm_fatal("RESULT TRANSACTION","Failed cast in do_copy");
        result = copied_transaction_h.result;
        result_parity = copied_transaction_h.result_parity;
        arg_parity_error = copied_transaction_h.arg_parity_error;
    endfunction : do_copy

    function string convert2string();
        string s;
        s = $sformatf("result: %8h result_parity: %1h arg_parity_error: %1h",result, result_parity, arg_parity_error);
        return s;
    endfunction : convert2string

    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        result_transaction RHS;
        bit same;
        assert(rhs != null) else
            `uvm_fatal("RESULT TRANSACTION","Tried to compare null transaction");

        same = super.do_compare(rhs, comparer);
        $cast(RHS, rhs);
        
        same = (result == RHS.result && 
	    result_parity == RHS.result_parity && 
	    arg_parity_error == RHS.arg_parity_error) && same;
        
        return same;
    endfunction : do_compare


endclass : result_transaction
