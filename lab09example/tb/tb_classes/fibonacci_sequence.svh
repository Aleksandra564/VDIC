/*
 Copyright 2013 Ray Salemi

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
class fibonacci_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(fibonacci_sequence)

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "fibonacci");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        shortint unsigned n_minus_2=0;
        shortint unsigned n_minus_1=1;

        `uvm_do_with(req, {op == rst_op;})
        `uvm_info("SEQ_FIBONACCI", " Fib(01) = 00", UVM_MEDIUM)
        `uvm_info("SEQ_FIBONACCI", " Fib(02) = 01", UVM_MEDIUM)

        for(int ff = 3; ff <= 14; ff++) begin
            `uvm_rand_send_with(req, { A == n_minus_2; B == n_minus_1; op == add_op; })
            n_minus_2 = n_minus_1;
            n_minus_1 = req.result;
            `uvm_info("SEQ_FIBONACCI", $sformatf("Fib(%02d) = %02d", ff, n_minus_1), UVM_MEDIUM)
        end

    endtask : body

endclass : fibonacci_sequence



