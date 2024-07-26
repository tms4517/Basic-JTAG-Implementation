`ifndef PA_JTAG
`define PA_JTAG

`default_nettype none

package jtag_pa;

  // TAP FSM states.
  typedef enum logic [3:0]
  { STATE_RESET
  , STATE_IDLE
  , STATE_SELECT_DR
  , STATE_SELECT_IR
  , STATE_CAPTURE_DR
  , STATE_CAPTURE_IR
  , STATE_SHIFT_DR
  , STATE_SHIFT_IR
  , STATE_EXIT1_DR
  , STATE_EXIT1_IR
  , STATE_PAUSE_DR
  , STATE_PAUSE_IR
  , STATE_EXIT2_DR
  , STATE_EXIT2_IR
  , STATE_UPDATE_DR
  , STATE_UPDATE_IR
  } ty_STATE_TAP_FSM;

  localparam int unsigned IR_SCAN_CODE = 1;

  // Width of data, instruction and shift register.
  localparam int unsigned REG_W = 32;

  // Unique identifier of the device.
  localparam int unsigned ID_CODE = 5;

  // Instruction opcodes
  typedef enum logic [REG_W-1:0]
  { IDCODE = 'h1
  , BYPASS = 'h2
  , BSR    = 'h3
  , USER   = 'h4
  } ty_INSTRUCTION;

endpackage

`resetall

`endif
