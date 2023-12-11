class runall_test extends mult_base_test;
   `uvm_component_utils(runall_test)
   
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
   local runall_sequence runall_seq;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
   function new (string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new
   
//------------------------------------------------------------------------------
// run_phase
//------------------------------------------------------------------------------
   task run_phase(uvm_phase phase);
      runall_seq = new("runall_seq");
      phase.raise_objection(this);
      runall_seq.start(null); // the sequence gets the sequencer by its own
      phase.drop_objection(this);
   endtask : run_phase


endclass


