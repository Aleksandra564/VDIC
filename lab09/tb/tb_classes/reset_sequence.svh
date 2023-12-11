class reset_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(reset_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
// Not necessary: req is inherited
//    sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "reset");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        `uvm_info("SEQ_RESET", "", UVM_MEDIUM)
        `uvm_do_with(req, {rst_n;} )
    endtask : body


endclass : reset_sequence












