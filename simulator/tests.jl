
include("Bryggverk.jl")

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

function r(t)
    if t <= 3000
        return [45.0]
    elseif 3000 <= t <= 5000
        return [55.0]
    elseif 5000 <= t <= 7000
        return [65.0]
    elseif 7000 <= t <= 9000
        return [75.0]
    else
        return [100.0]
    end
end

t_end = 10000
opt = control_opt(onOff, r, 10)
output = simulate(sys, opt, t_end=maximum(data.time), x0=[8, 18], dt=1)

figure(1)
clf()
subplot(3, 1, 1)
plot(output.T, output.x[1,:], "k--")
plot(output.T, output.y[:], "C0")
title("Measured temperature")
subplot(3, 1, 2)
plot(output.T, output.e[:])
title("Error")
subplot(3, 1, 3)
plot(output.T, output.u[:])
title("Control signal")
