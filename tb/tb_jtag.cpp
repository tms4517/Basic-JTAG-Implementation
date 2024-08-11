#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <stdlib.h>
#include <vector>

#include "Vjtag.h"           // Verilated DUT.
#include <verilated.h>       // Common verilator routines.
#include <verilated_vcd_c.h> // Write waverforms to a VCD file.

#define MAX_SIM_TIME 150 // Number of clk edges.
#define RESET_NEG_EDGE 5 // Clk edge number to deassert arst.
#define VERIF_START_TIME 7

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

// {{{ Vectors to drive tdi and tms pins & global variables to track TAP state
int resetTapTmsVec_i = 0;
std::vector<int> resetTapTmsVec = {1, 1, 1, 1, 1};
int resetTapCompleted = 0;

int shiftDrTmsVec_i = 0;
std::vector<int> shiftDrTmsVec = {0, 1, 0, 0};

int shiftDataVec_i = 0;
std::vector<int> shiftDataVec0 = {1, 0, 1, 0, 1, 0};
std::vector<int> shiftDataVec1 = {1, 1};
int dataShiftCompleted = 0;

int captureIrTmsVec_i = 0;
std::vector<int> captureIrTmsVec = {0, 1, 1, 0};
int captureIrCompleted = 0;

int captureDrTmsVec_i = 0;
std::vector<int> captureDrTmsVec = {0, 1, 0};
int captureDrCompleted = 0;

int shiftIrTmsVec_i = 0;
std::vector<int> shiftIrTmsVec = {0, 1, 1, 0, 0};

int updateIrTmsVec_i = 0;
std::vector<int> updateIrTmsVec = {0, 1, 1, 0, 0, 1, 1};
int updateIrCompleted = 0;

int tapState = 0;
// }}} Vectors to drive tdi and tms pins & global variables to track TAP state

// Assert arst only on the first clock edge.
void dut_reset(Vjtag *dut) {
  if ((sim_time > 2) && (sim_time < RESET_NEG_EDGE)) {
    dut->i_trst_n = 0;
    dut->i_tdi = 0;
    dut->i_tms = 0;
    dut->i_bsr = 69;

  } else {
    dut->i_trst_n = 1;
  }
}

// {{{ Helper functions to set TAP to a particular state
void setTapToReset(Vjtag *dut) {
  if ((sim_time > RESET_NEG_EDGE) && (resetTapTmsVec_i < resetTapTmsVec.size())) {
    dut->i_tms = resetTapTmsVec[resetTapTmsVec_i];
    resetTapTmsVec_i++;
  } else if (resetTapTmsVec_i == resetTapTmsVec.size()) {
    tapState = 0;
    resetTapCompleted = 1;
  }
}

void setTapToShiftDr(Vjtag *dut) {
  if ((sim_time > RESET_NEG_EDGE) && (shiftDrTmsVec_i < shiftDrTmsVec.size())) {
    dut->i_tms = shiftDrTmsVec[shiftDrTmsVec_i];
    shiftDrTmsVec_i++;
  } else if (shiftDrTmsVec_i == shiftDrTmsVec.size()) {
    tapState = 6;
  }
}

void setTapToShiftIr(Vjtag *dut) {
  if ((sim_time > RESET_NEG_EDGE) && (shiftIrTmsVec_i < shiftIrTmsVec.size())) {
    dut->i_tms = shiftIrTmsVec[shiftIrTmsVec_i];
    shiftIrTmsVec_i++;
  } else if (shiftIrTmsVec_i == shiftIrTmsVec.size()) {
    tapState = 7;
  }
}

void setTapToCaptureIr(Vjtag *dut) {
  if ((sim_time > RESET_NEG_EDGE) &&
      (captureIrTmsVec_i < captureIrTmsVec.size())) {
    dut->i_tms = captureIrTmsVec[captureIrTmsVec_i];
    captureIrTmsVec_i++;
  } else if (captureIrTmsVec_i == captureIrTmsVec.size()) {
    tapState = 5;
    captureIrCompleted = 1;
  }
}

void setTapToCaptureDr(Vjtag *dut) {
  if ((sim_time > RESET_NEG_EDGE) &&
      (captureDrTmsVec_i < captureDrTmsVec.size())) {
    dut->i_tms = captureDrTmsVec[captureDrTmsVec_i];
    captureDrTmsVec_i++;
  } else if (captureDrTmsVec_i == captureDrTmsVec.size()) {
    tapState = 4;
    captureDrCompleted = 1;
  }
}

void setTapToUpdateIr(Vjtag *dut) {
  if ((sim_time > RESET_NEG_EDGE) && (shiftIrTmsVec_i < shiftIrTmsVec.size())) {
    dut->i_tms = shiftIrTmsVec[shiftIrTmsVec_i];
    shiftIrTmsVec_i++;
  } else if (shiftIrTmsVec_i == shiftIrTmsVec.size()) {
    tapState = 7;
  }
}

void shiftDataIn(Vjtag *dut, int vec_num) {
  if (vec_num == 0) {
    if (shiftDataVec_i < shiftDataVec0.size()) {
      dut->i_tdi = shiftDataVec0[shiftDataVec_i];
      shiftDataVec_i++;
    } else {
      dataShiftCompleted = 1;
    }
  }
  else if (vec_num == 1) {
    if (shiftDataVec_i < shiftDataVec1.size()) {
      dut->i_tdi = shiftDataVec1[shiftDataVec_i];
      shiftDataVec_i++;
    } else {
      dataShiftCompleted = 1;
    }
  }
}
// }}} Helper functions to set TAP to a particular state

void demonstrate_CaptureIrShiftIr(Vjtag *dut) {
  setTapToCaptureIr(dut);

  if (captureIrCompleted) {
    setTapToReset(dut);
  }

  if (captureIrCompleted && resetTapCompleted) {
    setTapToShiftIr(dut);
  }
}

void demonstrate_ShiftDataInThenOut(Vjtag *dut) {
  setTapToShiftDr(dut);
  if (tapState == 6) {
    shiftDataIn(dut, 0);
  }
}

void demonstrate_setIrShiftDr(Vjtag *dut) {
  setTapToShiftIr(dut);
  if (tapState == 7) {
    shiftDataIn(dut, 1);
  }
  if (shiftDataVec_i == shiftDataVec1.size()) {
    setTapToReset(dut);
    // In the state transition of reset, the IR gets updated as it passes
    // through update IR.
  }
  if (resetTapCompleted == 1) {
    setTapToCaptureDr(dut);
    dut->i_tdi = 0;
    // Since tms is held at 0, TAP progress to shifting DR.
  }
}

int main(int argc, char **argv, char **env) {
  srand(time(NULL));
  Verilated::commandArgs(argc, argv);
  Vjtag *dut = new Vjtag; // Instantiate DUT.

  // {{{ Set-up waveform dumping.

  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 5);
  m_trace->open("waveform.vcd");

  // }}} Set-up waveform dumping.

  while (sim_time < MAX_SIM_TIME) {
    dut_reset(dut);

    dut->i_tclk ^= 1; // Toggle clk to create pos and neg edge.

    dut->eval(); // Evaluate all the signals in the DUT on each clock edge.

    if (dut->i_tclk == 1) {
      posedge_cnt++;

      demonstrate_setIrShiftDr(dut);
    }
    // Write all the traced signal values into the waveform dump file.
    m_trace->dump(sim_time);

    sim_time++;
  }

  m_trace->close();
  delete dut;
  exit(EXIT_SUCCESS);
}
