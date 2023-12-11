class parallel_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(parallel_sequence)

//------------------------------------------------------------------------------
// sequences to run
//------------------------------------------------------------------------------
    local reset_sequence reset;
    local short_random_sequence short_random;
    local fibonacci_sequence fibonacci;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "parallel_sequence");
        super.new(name);
//      reset = reset_sequence::type_id::create("reset");
//      fibonacci    = fibonacci_sequence::type_id::create("fibonacci");
//      short_random = short_random_sequence::type_id::create("short_random");
        `uvm_create(reset);
        `uvm_create(fibonacci);
        `uvm_create(short_random);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        `uvm_info("SEQ_PARALLEL","",UVM_MEDIUM)
        reset.start(m_sequencer); // m_sequencer from the start method call
        fork
            fibonacci.start(m_sequencer);
            short_random.start(m_sequencer);
        join
    endtask : body


endclass : parallel_sequence


