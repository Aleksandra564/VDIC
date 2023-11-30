class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
    protected virtual mult_bfm bfm;
    uvm_analysis_port #(result_s) ap;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

//------------------------------------------------------------------------------
// monitoring function called from BFM
//------------------------------------------------------------------------------
    function void write_to_monitor(result_s res);
        `ifdef DEBUG
        $display ("RESULT MONITOR: arg_parity_error=%0d, result=%0d, result_parity=%0d", res.arg_parity_error, res.result, res.result_parity);
        `endif
        ap.write(res);
    endfunction : write_to_monitor

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mult_bfm)::get(null, "*", "bfm", bfm))
            $fatal(1, "Failed to get BFM");
        bfm.result_monitor_h = this;
        ap = new("ap", this);
    endfunction : build_phase


endclass : result_monitor






