`default_nettype none

module jtag_dataReg
  ( input  var logic i_tclk
  , input  var logic i_trst_n
  , input  var logic i_tdi

  , input  var logic i_stateIsUpdateDr

  , input  var logic [REG_W-1:0] i_shiftReg
  , input  var logic [REG_W-1:0] i_instrReg
  , input  var logic [REG_W-1:0] i_bsr
  , output var logic [REG_W-1:0] o_dataReg
  , output var logic [REG_W-1:0] o_userData
  );

  import jtag_pa::*;

  // {{{ IDCODE Register
  // IDCODE is set in 'jtag_pa.sv'. Read only.
  logic [REG_W-1:0] idCode_q;

  always_ff @(posedge i_tclk)
    idCode_q <= ID_CODE;
  // }}} IDCODE Register

  // {{{ BSR
  // BSR is an input into jtag.
  logic [REG_W-1:0] bsr_q;

  always_ff @(posedge i_tclk)
    bsr_q <= i_bsr;
  // }}} BSR

  // {{{ BYPASS
  // 1 bit to minimise latency from TDI to TDO
  logic bypass_q;

  always_ff @(posedge i_tclk)
    bypass_q <= i_tdi;
  // }}} BYPASS

  // {{{ USER
  // Register whose data is used by external logic.
  logic [REG_W-1:0] user_q;

  always_ff @(posedge i_tclk, negedge i_trst_n)
    if (!i_trst_n)
      user_q <= '0;
    else if (i_stateIsUpdateDr)
      user_q <= i_shiftReg;
    else
      user_q <= user_q;

  always_comb
    o_userData = user_q;
  // }}} USER

  // MUX registers to output. Select line controlled by instruction reg.
  always_comb
    case (i_instrReg)
      IDCODE:
        o_dataReg = idCode_q;
      BYPASS:
        o_dataReg = {bypass_q, (REG_W-1)'(0)};
      BSR:
        o_dataReg = bsr_q;
      USER:
        o_dataReg = user_q;
      default:
        o_dataReg = '0;
    endcase

endmodule

`resetall
