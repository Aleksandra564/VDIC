class random_tpgen extends base_tpgen;
    `uvm_component_utils (random_tpgen)

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
	
//---------------------------------
// Random data generation functions
//---------------------------------
	protected function logic signed [15:0] get_data();
	    bit [2:0] zero_ones = 3'($random);

	    if (zero_ones == 3'b001)		
		    return 16'sh0000;		// generate all zeros
	    else
	        return 16'($random);
	    
	endfunction : get_data
	
//------------------------------------------------------------------------------
// get_input_parity - CAN RETURN WRONG VALUE FOR TESTS
//------------------------------------------------------------------------------
	protected function logic get_input_parity(
			logic signed [15:0] arg
		);
		logic result;
		logic no_parity_result;
		logic [1:0] zero_ones;
		
		zero_ones = 2'($random);		// 75% chance to generate proper parity
		result = ^ arg;					// xor
		no_parity_result = !(^ arg);	// wrong parity bit
		
		if(zero_ones == 2'b11) begin	// 25% chance to get wrong parity
			return(no_parity_result);
		end
		else begin
			return(result);
		end
		
	endfunction : get_input_parity
	
	
endclass : random_tpgen
