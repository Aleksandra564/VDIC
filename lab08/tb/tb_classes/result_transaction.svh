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
// transaction functions: do_copy, do_compare, convert2string
//------------------------------------------------------------------------------

    extern function void do_copy(uvm_object rhs);
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : result_transaction

//------------------------------------------------------------------------------
// external functions
//------------------------------------------------------------------------------
function void result_transaction::do_copy(uvm_object rhs);
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

function string result_transaction::convert2string();
    string s;
    s = $sformatf("result: %8h result_parity: %1h arg_parity_error: %1h", result, result_parity, arg_parity_error);
    return s;
endfunction : convert2string

function bit result_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
    result_transaction compared_transaction_h;
    bit same;

    if (rhs==null) `uvm_fatal("RESULT TRANSACTION",
            "Tried to do comparison to a null pointer");
    if (!$cast(compared_transaction_h, rhs))
        same = 0;
    else
        same = super.do_compare(rhs, comparer) &&
        (compared_transaction_h.result == result &&
	    compared_transaction_h.result_parity &&
	    compared_transaction_h.arg_parity_error);
    return same;
endfunction : do_compare

