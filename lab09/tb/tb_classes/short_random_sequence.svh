class short_random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(short_random_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
// not necessary, req is inherited
//    sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "short_random_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        repeat (14) begin : short_random_loop
//            req = sequence_item::type_id::create("req");
//            start_item(req);
//            assert(req.randomize());
//            finish_item(req);
            `uvm_do(req)
// Moved relative to the book example so as to show result
            `uvm_info("SEQ_SHORT_RANDOM", $sformatf("random req: %s", req.convert2string), UVM_MEDIUM)
        end : short_random_loop
    endtask : body

endclass : short_random_sequence











