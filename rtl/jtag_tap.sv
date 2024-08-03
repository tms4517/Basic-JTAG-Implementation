`default_nettype none

module jtag_tap
  ( input  var logic i_tclk
  , input  var logic i_trst_n
  , input  var logic i_tms

  , output var logic o_stateIsCaptureDr
  , output var logic o_stateIsCaptureIr
  , output var logic o_stateIsShiftDr
  , output var logic o_stateIsShiftIr
  , output var logic o_stateIsUpdateDr
  , output var logic o_stateIsUpdateIr
  );

  import jtag_pa::*;

  ty_STATE_TAP_FSM state_q, state_d;

  always_ff @(posedge i_tclk, negedge i_trst_n)
    if (!i_trst_n)
      state_q <= STATE_RESET;
    else
      state_q <= state_d;

  always_comb
    case (state_q)
      STATE_RESET:
        state_d = i_tms ? STATE_RESET     : STATE_IDLE;
      STATE_IDLE:
        state_d = i_tms ? STATE_SELECT_DR : STATE_IDLE;
      // DR
      STATE_SELECT_DR:
        state_d = i_tms ? STATE_SELECT_IR : STATE_CAPTURE_DR;
      STATE_CAPTURE_DR:
        state_d = i_tms ? STATE_EXIT1_DR  : STATE_SHIFT_DR;
      STATE_SHIFT_DR:
        state_d = i_tms ? STATE_EXIT1_DR  : STATE_SHIFT_DR;
      STATE_EXIT1_DR:
        state_d = i_tms ? STATE_UPDATE_DR : STATE_PAUSE_DR;
      STATE_PAUSE_DR:
        state_d = i_tms ? STATE_EXIT2_DR  : STATE_PAUSE_DR;
      STATE_EXIT2_DR:
        state_d = i_tms ? STATE_UPDATE_DR : STATE_SHIFT_DR;
      STATE_UPDATE_DR:
        state_d = i_tms ? STATE_SELECT_DR : STATE_IDLE;
      // IR
      STATE_SELECT_IR:
        state_d = i_tms ? STATE_RESET     : STATE_CAPTURE_IR;
      STATE_CAPTURE_IR:
        state_d = i_tms ? STATE_EXIT1_IR  : STATE_SHIFT_IR;
      STATE_SHIFT_IR:
        state_d = i_tms ? STATE_EXIT1_IR  : STATE_SHIFT_IR;
      STATE_EXIT1_IR:
        state_d = i_tms ? STATE_UPDATE_IR : STATE_PAUSE_IR;
      STATE_PAUSE_IR:
        state_d = i_tms ? STATE_EXIT2_IR  : STATE_PAUSE_IR;
      STATE_EXIT2_IR:
        state_d = i_tms ? STATE_UPDATE_IR : STATE_SHIFT_IR;
      STATE_UPDATE_IR:
        state_d = i_tms ? STATE_SELECT_DR : STATE_IDLE;
      default:
        state_d = STATE_RESET;
    endcase

  always_comb
    o_stateIsCaptureDr = (state_q == STATE_CAPTURE_DR);

  always_comb
    o_stateIsCaptureIr = (state_q == STATE_CAPTURE_IR);

  always_comb
    o_stateIsShiftDr = (state_q == STATE_SHIFT_DR);

  always_comb
    o_stateIsShiftIr = (state_q == STATE_SHIFT_IR);

  always_comb
    o_stateIsUpdateDr = (state_q == STATE_UPDATE_DR);

  always_comb
    o_stateIsUpdateIr = (state_q == STATE_UPDATE_IR);

endmodule

`resetall
