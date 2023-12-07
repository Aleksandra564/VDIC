class env extends uvm_env;
    `uvm_component_utils(env)

//------------------------------------------------------------------------------
// agents
//------------------------------------------------------------------------------
    mult_agent class_mult_agent_h;
    mult_agent module_mult_agent_h;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new

//------------------------------------------------------------------------------
// build phase
//------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        // declare configuration object handlers
        env_config env_config_h;
        mult_agent_config class_agent_config_h;
        mult_agent_config module_agent_config_h;

        // get the env_config with two BFM's included
        if(!uvm_config_db #(env_config)::get(this, "", "config", env_config_h))
            `uvm_fatal("ENV", "Failed to get config object");

        // create configs for the agents
        class_agent_config_h   = new(.bfm(env_config_h.class_bfm), .is_active(UVM_ACTIVE));
        
        // for the second DUT we provide external stimulus, the agent does not generate it
        module_agent_config_h  = new(.bfm(env_config_h.module_bfm), .is_active(UVM_PASSIVE));

        // store the agent configs in the UMV database
        // important: restricted access by the hierarchical name, the second argument must
        //            match the agent handler name
        uvm_config_db #(mult_agent_config)::set(this, "class_mult_agent_h*",
            "config", class_agent_config_h);
        uvm_config_db #(mult_agent_config)::set(this, "module_mult_agent_h*",
            "config", module_agent_config_h);

        // create the agents
        class_mult_agent_h  = mult_agent::type_id::create("class_mult_agent_h", this);
        module_mult_agent_h = mult_agent::type_id::create("module_mult_agent_h", this);

    endfunction : build_phase

endclass


