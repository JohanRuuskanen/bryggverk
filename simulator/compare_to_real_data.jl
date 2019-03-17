
include("Bryggverk.jl")

file = "bryggverk/simulator/data/log190312.csv"
data = CSV.read(file)

# Constats
m = 56.3 # Water
c = 4.2e3 # Specific heat capacity
k = 4e3/(m*c) # Temperature added to system
a = -0.00001 # Fit by hand

# Create state space representation
A = [a -a; 0 0]
B = [k 0]'
C = [1.0 0.0]
sys = ss(A, B, C)

r(t) = [100.0]
opt = control_opt(onOff, r, 1)

output = simulate(sys, opt, t_end=maximum(data.time), x0=[8, 18], dt=1)

figure(1)
clf()
plot(data.time, data.temp, "C0")
plot(output.T, output.x[1,:], "C1--")
plot(output.T, output.y[:], "C1")
