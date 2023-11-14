module tpgen(mult_bfm bfm);	// test patterns generator
	
//---------------------------------
// Random data generation functions
//---------------------------------
function logic signed [15:0] get_data();

    bit [2:0] zero_ones;

    zero_ones = 3'($random);

    if (zero_ones == 3'b000)
        return 16'sh8000;				// 16-bit data SIGNED min
    else if (zero_ones == 3'b111)		
        return 16'sh7FFF;				// 16-bit data SIGNED max
    else if (zero_ones == 3'b001)		
	    return 16'sh0000;				// generate all zeros
    else
        return 16'($random);
    
endfunction : get_data

//------------------------------------------------------------------------------
// get_input_parity - CAN RETURN WRONG VALUE FOR TESTS
//------------------------------------------------------------------------------
function logic get_input_parity(
		logic signed [15:0] arg
	);
	logic result;
	logic no_parity_result;
	logic [1:0] zero_ones;
	
	zero_ones = 2'($random);	// 75% chance to generate proper parity
	result = ^ arg;		// xor
	no_parity_result = !(^ arg);	// wrong parity bit
	
	if(zero_ones == 2'b11) begin	// 25% chance to get wrong parity
		return(no_parity_result);
	end
	else begin
		return(result);
	end
	
endfunction : get_input_parity
	
//------------------------------------------------------------------------------
initial begin
	logic signed 	[15:0] 	iA;
	bit               		iA_parity;
	logic signed 	[15:0] 	iB;        
	bit               		iB_parity;
	
	logic signed 	[31:0] 	result;
	logic               	result_parity;

    bfm.reset_mult();
    repeat (1000) begin : random_loop
        iA = get_data();
        iB = get_data();
	    iA_parity = get_input_parity(iA);
	    iB_parity = get_input_parity(iB);
        bfm.send_data(iA, iA_parity, iB, iB_parity);
	    bfm.wait_ready();	// wait until result is ready
    end : random_loop
    
    // reset until DUT finish processing data
    bfm.send_data(iA, iA_parity, iB, iB_parity);
    bfm.reset_mult();
    
    $finish;
    
end // initial begin
	
	
endmodule : tpgen
