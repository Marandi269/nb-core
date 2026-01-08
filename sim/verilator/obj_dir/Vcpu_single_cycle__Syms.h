// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VCPU_SINGLE_CYCLE__SYMS_H_
#define VERILATED_VCPU_SINGLE_CYCLE__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vcpu_single_cycle.h"

// INCLUDE MODULE CLASSES
#include "Vcpu_single_cycle___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vcpu_single_cycle__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vcpu_single_cycle* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vcpu_single_cycle___024root    TOP;

    // CONSTRUCTORS
    Vcpu_single_cycle__Syms(VerilatedContext* contextp, const char* namep, Vcpu_single_cycle* modelp);
    ~Vcpu_single_cycle__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
