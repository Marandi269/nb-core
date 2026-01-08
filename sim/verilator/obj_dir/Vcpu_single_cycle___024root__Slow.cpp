// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcpu_single_cycle.h for the primary calling header

#include "Vcpu_single_cycle__pch.h"
#include "Vcpu_single_cycle__Syms.h"
#include "Vcpu_single_cycle___024root.h"

void Vcpu_single_cycle___024root___ctor_var_reset(Vcpu_single_cycle___024root* vlSelf);

Vcpu_single_cycle___024root::Vcpu_single_cycle___024root(Vcpu_single_cycle__Syms* symsp, const char* v__name)
    : VerilatedModule{v__name}
    , vlSymsp{symsp}
 {
    // Reset structure values
    Vcpu_single_cycle___024root___ctor_var_reset(this);
}

void Vcpu_single_cycle___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vcpu_single_cycle___024root::~Vcpu_single_cycle___024root() {
}
