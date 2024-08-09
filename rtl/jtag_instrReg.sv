`default_nettype none

module jtag_instrReg
  ( input  var logic i_tclk
  , input  var logic i_trst_n

  , input  var logic i_stateIsUpdateIr
  , input  var logic i_stateIsCaptureIr

  , input  var logic [REG_W-1:0] i_shiftReg

  , output var logic [REG_W-1:0] o_instrReg
  );

  import jtag_pa::*;

  logic [REG_W-1:0] instr_d, instr_q;

  always_ff @(posedge i_tclk, negedge i_trst_n)
    if (!i_trst_n)
      instr_q <= '0;
    else
      instr_q <= instr_d;

  always_comb
    if (i_stateIsUpdateIr)
      instr_d = i_shiftReg;
    else if (i_stateIsCaptureIr)
      instr_d = IR_SCAN_CODE;
    else
      instr_d = instr_q;

  always_comb
    o_instrReg = instr_q;

endmodule

`resetall
