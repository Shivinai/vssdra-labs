#include <cstdint>
#include <cmath>
#include <iostream>
#include <iomanip>
#include <memory>
#include <vector>
#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vmac.h"

int16_t ft2fp(float val, int float_bits) {
    return static_cast<int16_t>(std::round(val * (1 << float_bits)));
}

float fp2ft(int16_t val, int float_bits = 15) {
    return static_cast<float>(val) / static_cast<float>(1 << float_bits);
}

void tick(Vmac* top, VerilatedFstC* trace, uint64_t& sim_time) {
    top->CLK = 0;
    top->eval();
    if (trace) trace->dump(sim_time);
    sim_time += 5;

    top->CLK = 1;
    top->eval();
    if (trace) trace->dump(sim_time);
    sim_time += 5;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vmac>();

    Verilated::traceEverOn(true);
    auto trace = std::make_unique<VerilatedFstC>();
    top->trace(trace.get(), 99);
    trace->open("wave.fst");

    uint64_t sim_time = 0;

    top->RESET = 1;
    top->START = 0;
    top->DIN_A = 0;
    top->DIN_B = 0;
    tick(top.get(), trace.get(), sim_time);
    tick(top.get(), trace.get(), sim_time);
    top->RESET = 0;
    tick(top.get(), trace.get(), sim_time);

    struct TestCase { float a; float b; };
    std::vector<TestCase> tests = {
            {-0.12f, 0.95f}, 
            { 0.42f, 0.50f}, 
            {-0.99f, 0.67f}, 
            { 0.21f, 0.40f}
        };
    std::cout << std::fixed << std::setprecision(4);
    std::cout << "Step |     A     |     B     |   A * B   | Accumulator (Actual / Expected)\n";
    std::cout << "-----+-----------+-----------+-----------+---------------------------------\n";

    float expected_acc = 0.0f;

    for (size_t i = 0; i < tests.size(); ++i) {
        float a = tests[i].a;
        float b = tests[i].b;
        expected_acc += a * b;

        top->DIN_A = ft2fp(a, 15);
        top->DIN_B = ft2fp(b, 15);

        top->START = 1;
        tick(top.get(), trace.get(), sim_time);
        top->START = 0;

        while (!top->READY) {
            tick(top.get(), trace.get(), sim_time);
        }

        int16_t dout = static_cast<int16_t>(top->DOUT);
        float result = fp2ft(dout, 15);

        std::cout << "  " << i + 1 << "  | " << std::setw(9) << a << " | "  << std::setw(9) << b << " | "  << std::setw(9) << (a * b) << " | "  << std::setw(9) << result << " / " << expected_acc << "\n";}

    trace->dump(sim_time);
    trace->close();
    top->final();

    return 0;
}