class command_transaction extends uvm_transaction;
    `uvm_object_utils(command_transaction)

//------------------------------------------------------------------------------
// transaction variables
//------------------------------------------------------------------------------
	bit							rst_n;
	rand logic signed 	[15:0] 	arg_a;
	rand bit               		arg_a_parity;
	rand logic signed 	[15:0] 	arg_b;        
	rand bit               		arg_b_parity;

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------
    constraint data {
	    arg_a dist {[16'sh8000:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFF]:/1};
	    arg_b dist {[16'sh8000:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFF]:/1};
//		arg_a dist {16'sh8000:/1, [16'sh8001:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFE]:/1, 16'sh7FFF:/1};
//	    arg_b dist {16'sh8000:/1, [16'sh8001:16'shFFFF]:/1, 16'sh0000:/1, [16'sh0001:16'sh7FFE]:/1, 16'sh7FFF:/1};
    }
    
//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name = "");
        super.new(name);
    endfunction : new
    
//------------------------------------------------------------------------------
// transaction functions: do_copy, clone_me, do_compare, convert2string
//------------------------------------------------------------------------------
    extern function void do_copy(uvm_object rhs);
    extern function command_transaction clone_me();
    extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    extern function string convert2string();

endclass : command_transaction

//------------------------------------------------------------------------------
// external functions
//------------------------------------------------------------------------------
function void command_transaction::do_copy(uvm_object rhs);
    command_transaction copied_transaction_h;

    if(rhs == null)
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")
    super.do_copy(rhs); // copy all parent class data
    if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")
            
    arg_a  = copied_transaction_h.arg_a;
    arg_a_parity  = copied_transaction_h.arg_a_parity;
    arg_b  = copied_transaction_h.arg_b;
    arg_b_parity  = copied_transaction_h.arg_b_parity;
endfunction : do_copy


function command_transaction command_transaction::clone_me();
    command_transaction clone;
    uvm_object tmp;
    tmp = this.clone();
    $cast(clone, tmp);
    return clone;
endfunction : clone_me


function bit command_transaction::do_compare(uvm_object rhs, uvm_comparer comparer);
    command_transaction compared_transaction_h;
    bit same;
    if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
        "Tried to do comparison to a null pointer");
    if (!$cast(compared_transaction_h,rhs))
        same = 0;
    else
        same = super.do_compare(rhs, comparer) &&
        (compared_transaction_h.arg_a == arg_a) &&
        (compared_transaction_h.arg_a_parity == arg_a_parity) &&
        (compared_transaction_h.arg_b == arg_b) &&
        (compared_transaction_h.arg_b_parity == arg_b_parity);
    return same;
endfunction : do_compare


function string command_transaction::convert2string();
    string s;
    s = $sformatf("rst_n: %1h arg_a: %4h arg_b: %4h arg_a_parity: %1h arg_b_parity: %1h", rst_n, arg_a, arg_b, arg_a_parity, arg_a_parity);
    return s;
endfunction : convert2string

