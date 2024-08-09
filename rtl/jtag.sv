`default_nettype none

module jtag
  ( input  var logic i_tclk
  , input  var logic i_trst_n
  , input  var logic i_tdi
  , input  var logic i_tms
  , output var logic o_tdo

  , input  var logic [REG_W-1:0] i_bsr
  , output var logic [REG_W-1:0] o_userData
  );

  import jtag_pa::*;

  // {{{ Interconnects
  logic stateIsCaptureDr;
  logic stateIsCaptureIr;
  logic stateIsShiftDr;
  logic stateIsShiftIr;
  logic stateIsUpdateDr;
  logic stateIsUpdateIr;

  logic [REG_W-1:0] dataReg;
  logic [REG_W-1:0] instrReg;
  logic [REG_W-1:0] shiftReg;
  // }}} Interconnects

  // {{{ TAP
  jtag_tap u_jtag_tap
  ( .i_tclk
  , .i_trst_n
  , .i_tms

  , .o_stateIsCaptureDr (stateIsCaptureDr)
  , .o_stateIsCaptureIr (stateIsCaptureIr)
  , .o_stateIsShiftDr (stateIsShiftDr)
  , .o_stateIsShiftIr (stateIsShiftIr)
  , .o_stateIsUpdateDr (stateIsUpdateDr)
  , .o_stateIsUpdateIr (stateIsUpdateIr)
  );
  // }}} TAP

  // {{{ Shift Reg
  jtag_shiftReg u_jtag_shiftReg
  ( .i_tclk
  , .i_trst_n
  , .i_tdi
  , .o_tdo

  , .i_stateIsCaptureDr (stateIsCaptureDr)
  , .i_stateIsCaptureIr (stateIsCaptureIr)
  , .i_stateIsShiftDr (stateIsShiftDr)
  , .i_stateIsShiftIr (stateIsShiftIr)

  , .i_dataReg (dataReg)
  , .i_instrReg (instrReg)

  , .o_shiftReg (shiftReg)
  );
  // }}} Shift Reg

  // {{{ Instr Reg
  jtag_instrReg u_jtag_instrReg
  ( .i_tclk
  , .i_trst_n

  , .i_stateIsUpdateIr  (stateIsUpdateIr)
  , .i_stateIsCaptureIr (stateIsCaptureIr)

  , .i_shiftReg (shiftReg)

  , .o_instrReg (instrReg)
  );
  // }}} Instr Reg

  // {{{ Data Reg
  jtag_dataReg u_jtag_dataReg
  ( .i_tclk
  , .i_trst_n
  , .i_tdi

  , .i_stateIsUpdateDr (stateIsUpdateDr)

  , .i_shiftReg (shiftReg)
  , .i_instrReg (instrReg)
  , .i_bsr
  , .o_dataReg  (dataReg)
  , .o_userData
  );
  // }}} Data Reg

endmodule

`resetall
