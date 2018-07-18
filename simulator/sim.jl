using PyPlot
using ControlSystems

function sim_sys(sys, u=NaN, t=linspace(0, 3600, 10000), x0=[100, 20])
	if length(u) == 1	
		if isnan(u)
			u = zeros(length(t))
		end
	end
	lsimplot(sys, u, t, x0)
end

"Constants"
m = 50
V = m * 10^-3.0
C = 4.2e3
T0 = 20

"Heating constants"
Ah = 1 #Adhoc, we transfer 24 KW to the tank 
Hh = 24e3

Dh = Ah*Hh

"Heat loss constants"
r = 0.2  #Adhoc, measure the size of the tank
h = 0.4

Atop = pi*r^2 #Need better, more correct values, measure how long it takes to cool?
Htop = 1e3 

Asteel = pi*r^2 + pi*2*r*h
Hsteel = 5

Dl = Atop*Htop + Asteel*Hsteel

A = [-Dl/(m*C) Dl/(m*C); 0 0]
B = [Dh/(m*C); 0]
C = [1 0]
D = [0]

sys = ss(A, B, C, D)

"Simulating the arduino actuation"
Te = 3600
h = 1

sysd = c2d(sys, h)

Ad = sysd[1].A
Bd = sysd[1].B
Cd = C
Dd = D

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

K = 1/1000
Ti = 100
Td = 1/100
Tv = sqrt(Ti*Td)
N = 10

x[1, :] = [80, 20]
y[1, :] = Cd*x[1, :]
r[1] = 67
e[1] = r[1] - y[1]

function lim(x, l, u)
	y = x
	if y > u
		y = u
	elseif y < l
		y = l
	end
	return y	
end	

for k = 2:length(t)

	"Actuate"
	x[k, :] = Ad*x[k-1, :] + Bd.*[u[k-1]; 0]
	y[k, :] = round.(Cd*x[k, :], 2, 2)
	
	r[k] = r[k-1]	
	

	"Controller"
	e[k] = r[k] - y[k] 
	P[k] = K * e[k]
	I[k] = I[k-1] + K*h/Ti*e[k] + 1/Tv*h*(u[k-1] - v[k-1])
	D[k] = Td/(Td + N*h) * D[k-1] - K*Td*N/(Td + N*h) * (y[k] - y[k-1]) 



	v[k] = P[k] + I[k] + D[k]
	u[k] = lim(v[k], 0.0, 1.0)
end

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

