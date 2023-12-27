class runall_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(runall_sequence)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    local sequencer sequencer_h;
    local uvm_component uvm_component_h;

//------------------------------------------------------------------------------
// sequences to run
//------------------------------------------------------------------------------t;
    local random_sequence random;
    local min_max_sequence min_max;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new(string name = "runall_sequence");
        super.new(name);

        // runall_sequence is called with null sequencer; another way to
        // define the sequence is to use find function;
        uvm_component_h = uvm_top.find("*.env_h.sequencer_h");

        if (uvm_component_h == null)
            `uvm_fatal("RUNALL_SEQUENCE", "Failed to get the sequencer")

        // find function returns uvm_component, needs casting
        if (!$cast(sequencer_h, uvm_component_h))
            `uvm_fatal("RUNALL_SEQUENCE", "Failed to cast from uvm_component_h.")

        random = random_sequence::type_id::create("random");
        min_max = min_max_sequence::type_id::create("min_max");
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------
    task body();
        `uvm_info("SEQ_RUNALL", "", UVM_MEDIUM)
        random.start(sequencer_h);
        min_max.start(sequencer_h);
    endtask : body


endclass : runall_sequence



