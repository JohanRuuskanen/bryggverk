

function simulate(sys::ss, opt::control_opt; t_end=100, x0=[0,0], dt=1)
    # Discretize state space using forward euler
    sysd = ssd(I + dt*sys.A, dt*sys.B, sys.C)
    T = collect(0:dt:t_end)

    output = sim_data(  T = T,
                        x = zeros(2, length(T)),
                        y = zeros(1, length(T)),
                        e = zeros(1, length(T)),
                        u = zeros(1, length(T))
                )

    output.x[:, 1] = x0
    output.y[:, 1] = C*x0

    control_cycle = 0
    for k = 2:length(output.T)
        control_cycle += dt
        output.e[:, k] = opt.r(output.T[k-1]) - output.y[:, k-1]
        if opt.h <= control_cycle
            control_cycle = 0
            output.u[:, k] = opt.controller(output.e[k])
        else
            output.u[:, k] = output.u[:, k-1]
        end

        output.x[:, k] = sysd.F*output.x[:, k-1] + sysd.G*output.u[:, k]
        output.y[:, k] = round.(sysd.H*output.x[:, k], digits=2, base=2)
    end

    return output
end
