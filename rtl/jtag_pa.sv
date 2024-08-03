`ifndef PA_JTAG
`define PA_JTAG

`default_nettype none

package jtag_pa;

  // TAP FSM states.
  typedef enum logic [3:0]
  { STATE_RESET      // 0
  , STATE_IDLE       // 1
  , STATE_SELECT_DR  // 2
  , STATE_SELECT_IR  // 3
  , STATE_CAPTURE_DR // 4
  , STATE_CAPTURE_IR // 5
  , STATE_SHIFT_DR   // 6
  , STATE_SHIFT_IR   // 7
  , STATE_EXIT1_DR   // 8
  , STATE_EXIT1_IR   // 9
  , STATE_PAUSE_DR   // 10
  , STATE_PAUSE_IR   // 11
  , STATE_EXIT2_DR   // 12
  , STATE_EXIT2_IR   // 13
  , STATE_UPDATE_DR  // 14
  , STATE_UPDATE_IR  // 15
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
