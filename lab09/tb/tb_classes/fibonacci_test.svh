class fibonacci_test extends tinyalu_base_test;
   `uvm_component_utils(fibonacci_test)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

//------------------------------------------------------------------------------
// run phase
//------------------------------------------------------------------------------
   task run_phase(uvm_phase phase);
      fibonacci_sequence fibonacci;
      fibonacci = new("fibonacci");

      phase.raise_objection(this);
      fibonacci.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase

endclass


