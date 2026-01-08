// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vcpu_single_cycle.h for the primary calling header

#ifndef VERILATED_VCPU_SINGLE_CYCLE___024ROOT_H_
#define VERILATED_VCPU_SINGLE_CYCLE___024ROOT_H_  // guard

#include "verilated.h"


class Vcpu_single_cycle__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vcpu_single_cycle___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst_n,0,0);
    CData/*0:0*/ __VactContinue;
    IData/*31:0*/ __VactIterCount;
    VlTriggerVec<0> __VactTriggered;
    VlTriggerVec<0> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vcpu_single_cycle__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vcpu_single_cycle___024root(Vcpu_single_cycle__Syms* symsp, const char* v__name);
    ~Vcpu_single_cycle___024root();
    VL_UNCOPYABLE(Vcpu_single_cycle___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
