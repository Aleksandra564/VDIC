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
class add_sequence extends uvm_sequence #(add_sequence_item);
    `uvm_object_utils(add_sequence)
    
//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

// not necessary, req is inherited
//    add_sequence_item req;

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "add_sequence");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// the sequence body
//------------------------------------------------------------------------------

    task body();
        `uvm_info("SEQ_ADD","",UVM_MEDIUM)
        repeat (10) begin
//            req = add_sequence_item::type_id::create("req");
//            start_item(req);
//            assert(req.randomize());
//            finish_item(req);
            `uvm_do(req);
            req.print();
        end
    endtask : body
    
    
endclass : add_sequence











