
function controller_PID!(k, P, I, D, e, u, v, par)
	
    P[k] = par.K * e[k]
	I[k] = I[k-1] + par.K*par.h/par.Ti*e[k] + 1/par.Tv*par.h*(u[k-1] - v[k-1])
	D[k] = par.Td/(par.Td + par.N*par.h) * D[k-1] - 
        par.K*par.Td*par.N/(par.Td + par.N*par.h) * (y[k] - y[k-1]) 



	v[k] = P[k] + I[k] + D[k]
	u[k] = lim(v[k], 0.0, 1.0)

end

function controller_onoff!(k, e, u, par)

    if e[k] > 0
        u[k] =  1.0
    else
        u[k] = 0.0
    end

end
