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
class sequence_item extends uvm_sequence_item;

//  This macro is moved below the variables definition and expanded.
//    `uvm_object_utils(sequence_item)

//------------------------------------------------------------------------------
// sequence item variables
//------------------------------------------------------------------------------

    rand byte unsigned A;
    rand byte unsigned B;
    rand operation_t op;
    shortint unsigned result;

//------------------------------------------------------------------------------
// Macros providing copy, compare, pack, record, print functions.
// Individual functions can be enabled/disabled with the last
// `uvm_field_*() macro argument.
// Note: this is an expanded version of the `uvm_object_utils with additional
//       fields added. DVT has a dedicated editor for this (ctrl-space).
//------------------------------------------------------------------------------

    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(B, UVM_ALL_ON | UVM_DEC)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

//------------------------------------------------------------------------------
// constraints
//------------------------------------------------------------------------------

    constraint op_con {op dist {no_op := 1, add_op := 5, and_op:=5,
            xor_op:=5,mul_op:=5, rst_op:=1};}

    constraint data { A dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
        B dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};}

//------------------------------------------------------------------------------
// constructor
//------------------------------------------------------------------------------

    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

//------------------------------------------------------------------------------
// convert2string 
//------------------------------------------------------------------------------

    function string convert2string();
        return {super.convert2string(),
            $sformatf("A: %2h  B: %2h   op: %s = %4h", A, B, op.name(), result)
        };
    endfunction : convert2string

endclass : sequence_item


