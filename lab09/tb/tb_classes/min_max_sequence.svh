class min_max_sequence extends uvm_sequence #(min_max_sequence_item);
    `uvm_object_utils(min_max_sequence)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
// not necessary, req is inherited
//    add_sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "min_max_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        `uvm_info("SEQ_MIN_MAX", "", UVM_MEDIUM)
        
        `uvm_create(req);
        repeat (1000) begin
//            req = add_sequence_item::type_id::create("req");
//            start_item(req);
//            assert(req.randomize());
//            finish_item(req);
            `uvm_rand_send(req);
            req.print();
        end
        req.rst_n = 1;
        `uvm_rand_send(req)
    endtask : body
    
    
endclass : min_max_sequence











