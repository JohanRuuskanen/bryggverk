using CSV
using PyPlot
using ControlSystems

file = "bryggverk/simulator/data/log190312.csv"
data = CSV.read(file)

# Constats
m = 56.3 # Water
c = 4.2e3 # Specific heat capacity
k = 4.8e3/(m*c) # Temperature added to system

a = -0.1

A = [a 1; 0 0]
B = [k; 0]
C = [1 0]

sys = ss(A, B, C, 0)

u(x, t) = [1.0]
x0 = [0; 18]

y, t, x = lsim(sys, u, data.time, x0=x0)

figure(1)
clf()
plot(data.time, data.temp, "C0")
plot(t, y, "C1")
