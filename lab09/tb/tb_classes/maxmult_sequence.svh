class maxmult_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(maxmult_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
// not necessary, req is inherited
//    sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "maxmult_sequence");
        super.new(name);
    endfunction : new
    
//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        `uvm_info("SEQ_MAXMULT", "", UVM_MEDIUM)
//      req = sequence_item::type_id::create("req");
//      start_item(req);
//      req.op = mul_op;
//      req.A = 8'hFF;
//      req.B = 8'hFF;
//      finish_item(req);
        `uvm_do_with(req, {op == mul_op; A == 8'hFF; B == 8'hFF;})
        `uvm_do_with(req, {op == rst_op;} )
        `uvm_do_with(req, {op == mul_op;} )
        `uvm_do_with(req, {op == mul_op;} )
        `uvm_do_with(req, {op == rst_op;} )
    endtask : body
    

endclass : maxmult_sequence
