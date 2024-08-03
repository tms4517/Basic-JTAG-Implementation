`default_nettype none

module jtag_shiftReg
  ( input  var logic i_tclk
  , input  var logic i_trst_n
  , input  var logic i_tdi
  , output var logic o_tdo

  , input  var logic i_stateIsCaptureDr
  , input  var logic i_stateIsCaptureIr
  , input  var logic i_stateIsShiftDr
  , input  var logic i_stateIsShiftIr

  , input  var logic [REG_W-1:0] i_dataReg
  , output var logic [REG_W-1:0] o_shiftReg
  );

  import jtag_pa::*;

  // {{{ Capture
    logic stateIsCapture;
    logic [REG_W-1:0] capture;

    always_comb
      stateIsCapture = i_stateIsCaptureDr || i_stateIsCaptureIr;

    // If i_stateIsCaptureDr, load the shift register with the value stored in
    // the selected data register. If i_stateIsCaptureIr, load the shift
    // register with the IR_SCAN_CODE set in `jtag_pa.sv`.
    always_comb
      capture = i_stateIsCaptureDr ? i_dataReg : IR_SCAN_CODE;
  // }}} Capture

  // {{{ Shift
    logic stateIsShift;

    always_comb
      stateIsShift = i_stateIsShiftDr || i_stateIsShiftIr;
  // }}} Shift

  logic [REG_W-1:0] shiftReg_d, shiftReg_q;

  always_ff @(posedge i_tclk, negedge i_trst_n)
    if (i_trst_n)
      shiftReg_q <= '0;
    else
      shiftReg_q <= shiftReg_d;

  // Data is shifted in to MSB of the shift register and the lsb is moved to the
  // TDO pin. If state is pause IR/DR, the shift register maintains it's value.
  always_comb
    if (stateIsCapture)
      shiftReg_d = capture;
    else if (stateIsShift)
      shiftReg_d = {i_tdi, shiftReg_q[REG_W-1:1]};
    else
      shiftReg_d = shiftReg_q;

  always_comb
    o_tdo = shiftReg_q[0];

  // Update IR/DR with shift register value.
  always_comb
    o_shiftReg = shiftReg_q;

endmodule

`resetall
