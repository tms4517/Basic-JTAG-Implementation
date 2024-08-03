#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <stdlib.h>
#include <vector>

#include "Vjtag.h"             // Verilated DUT.
#include <verilated.h>         // Common verilator routines.
#include <verilated_vcd_c.h>   // Write waverforms to a VCD file.

#define MAX_SIM_TIME 20 // Number of clk edges.
#define RESET_NEG_EDGE 5 // Clk edge number to deassert arst.
#define VERIF_START_TIME 7

vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

// Assert arst only on the first clock edge.
void dut_reset(Vjtag *dut) {
  if ((sim_time > 2) && (sim_time < RESET_NEG_EDGE)) {
    dut->i_trst_n = 0;
    dut->i_tdi = 0;
    dut->i_tms = 0;
    dut->i_bsr = 69;

  }
  else
  {
    dut->i_trst_n = 1;
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
    }

    // Write all the traced signal values into the waveform dump file.
    m_trace->dump(sim_time);

    sim_time++;
  }

  m_trace->close();
  delete dut;
  exit(EXIT_SUCCESS);
}
