class testbench;

    protected virtual mult_bfm bfm;

    protected tpgen tpgen_h;
    protected coverage coverage_h;
    protected scoreboard scoreboard_h;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new (virtual mult_bfm b);
        bfm          = b;
        tpgen_h      = new(bfm);
        coverage_h   = new(bfm);
        scoreboard_h = new(bfm);
    endfunction : new

//------------------------------------------------------------------------------
// Execute task
//------------------------------------------------------------------------------
    task execute();
        fork
            coverage_h.execute();
            scoreboard_h.execute();
        join_none
        tpgen_h.execute();
        scoreboard_h.print_result();
    endtask : execute

endclass : testbench
