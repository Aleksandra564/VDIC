class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(command_s) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(command_s cmd);
//        `ifdef DEBUG
//        $display("COMMAND MONITOR: A:0x%2h B:0x%2h op: %s", cmd.A, cmd.B, cmd.op.name());
//        `endif
        ap.write(cmd);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*", "bfm", bfm))
            $fatal(1, "Failed to get BFM");

        bfm.command_monitor_h = this;
        ap = new("ap", this);
    endfunction : build_phase

endclass : command_monitor

