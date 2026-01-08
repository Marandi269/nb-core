// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcpu_single_cycle.h for the primary calling header

#include "Vcpu_single_cycle__pch.h"
#include "Vcpu_single_cycle__Syms.h"
#include "Vcpu_single_cycle___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcpu_single_cycle___024root___dump_triggers__act(Vcpu_single_cycle___024root* vlSelf);
#endif  // VL_DEBUG

void Vcpu_single_cycle___024root___eval_triggers__act(Vcpu_single_cycle___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcpu_single_cycle___024root___eval_triggers__act\n"); );
    Vcpu_single_cycle__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vcpu_single_cycle___024root___dump_triggers__act(vlSelf);
    }
#endif
}
