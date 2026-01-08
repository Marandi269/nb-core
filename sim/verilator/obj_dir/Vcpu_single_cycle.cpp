// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vcpu_single_cycle__pch.h"

//============================================================
// Constructors

Vcpu_single_cycle::Vcpu_single_cycle(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vcpu_single_cycle__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , rst_n{vlSymsp->TOP.rst_n}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vcpu_single_cycle::Vcpu_single_cycle(const char* _vcname__)
    : Vcpu_single_cycle(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vcpu_single_cycle::~Vcpu_single_cycle() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vcpu_single_cycle___024root___eval_debug_assertions(Vcpu_single_cycle___024root* vlSelf);
#endif  // VL_DEBUG
void Vcpu_single_cycle___024root___eval_static(Vcpu_single_cycle___024root* vlSelf);
void Vcpu_single_cycle___024root___eval_initial(Vcpu_single_cycle___024root* vlSelf);
void Vcpu_single_cycle___024root___eval_settle(Vcpu_single_cycle___024root* vlSelf);
void Vcpu_single_cycle___024root___eval(Vcpu_single_cycle___024root* vlSelf);

void Vcpu_single_cycle::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vcpu_single_cycle::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vcpu_single_cycle___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vcpu_single_cycle___024root___eval_static(&(vlSymsp->TOP));
        Vcpu_single_cycle___024root___eval_initial(&(vlSymsp->TOP));
        Vcpu_single_cycle___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vcpu_single_cycle___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vcpu_single_cycle::eventsPending() { return false; }

uint64_t Vcpu_single_cycle::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vcpu_single_cycle::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vcpu_single_cycle___024root___eval_final(Vcpu_single_cycle___024root* vlSelf);

VL_ATTR_COLD void Vcpu_single_cycle::final() {
    Vcpu_single_cycle___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vcpu_single_cycle::hierName() const { return vlSymsp->name(); }
const char* Vcpu_single_cycle::modelName() const { return "Vcpu_single_cycle"; }
unsigned Vcpu_single_cycle::threads() const { return 1; }
void Vcpu_single_cycle::prepareClone() const { contextp()->prepareClone(); }
void Vcpu_single_cycle::atClone() const {
    contextp()->threadPoolpOnClone();
}
