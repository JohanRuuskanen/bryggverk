using PyPlot
using Distributions
using ControlSystems

include("misc.jl")
include("controllers.jl")

"""
Define constants and set up continuous state-space representation
"""
# Constants
m = 50
V = m * 10^-3.0
C = 4.2e3
T0 = 20

# Heating constants
Ah = 1 #Adhoc, we transfer 24 KW to the tank 
Hh = 24e3

Dh = Ah*Hh

# Heat loss constants
r = 0.2  #Adhoc, measure the size of the tank
h = 0.4

Atop = pi*r^2 #Need better, more correct values, measure how long it takes to cool?
Htop = 1e3 

Asteel = pi*r^2 + pi*2*r*h
Hsteel = 5

# Set up state space equations using law of thermodynamics
Dl = Atop*Htop + Asteel*Hsteel

A = [-Dl/(m*C) Dl/(m*C); 0 0]
B = [Dh/(m*C); 0]
C = [1 0]
D = [0]

sys = ss(A, B, C, D)

"""
Simulating the arduino actuation
"""
# Set parameters and discretize the system
Te = 3600
h = 1
Q = 0.01
R = 0.1

sysd = c2d(sys, h)

Ad = sysd[1].A
Bd = sysd[1].B
Cd = C
Dd = D

# Create vectors to store information
t = collect(0:h:Te)
v = zeros(size(t))
P = zeros(size(t))
I = zeros(size(t))
D = zeros(size(t))
u = zeros(size(t))
x = zeros(length(t), 2)
y = zeros(size(t))
r = zeros(size(t))
e = zeros(size(t))

# PID params
K = 1/50
Ti = 1000
Td = 1/100
Tv = sqrt(Ti*Td)
N = 10

par = params(h, K, Ti, Td, Tv, N)

# Initial conditions
x[1, :] = [20, 20]
y[1, :] = Cd*x[1, :]
r[1] = 80
e[1] = r[1] - y[1]

for k = 2:length(t)
	# Actuate
    x[k, :] = Ad*x[k-1, :] + Bd.*[u[k-1]; 0] + [rand(Normal(0.0, Q)), 0]
    y[k, :] = round.(Cd*x[k, :], 2, 2) + rand(Normal(0.0, R))
	
	r[k] = r[k-1]	

	# Control
    e[k] = r[k] - y[k] 
    
    #controller_PID!(k, P, I, D, e, u, v, par)
    controller_onoff!(k, e, u, par)
    
end

# Plot results

figure(1)
clf()
subplot(2, 1, 1)
plot(t, y)
plot(t, r, "r--")
plot(t, 100*ones(size(t)), "k--")
plot(t, 0*ones(size(t)), "k--")
ylim([-10, 110])
title("measurement")
legend(["y", "ref"])
subplot(2, 1, 2)
plot(t, u, "b")
plot(t, P, "k--")
plot(t, I, "k:")
plot(t, D, "k-.")
plot(t, v, "r")
title("Control signal")
legend(["u", "P", "I", "D",  "v"])
