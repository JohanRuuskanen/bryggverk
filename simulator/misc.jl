
struct params
    h::Float64
    K::Float64
    Ti::Float64
    Td::Float64
    Tv::Float64
    N::Float64
end

function lim(x, l, u)
	y = x
	if y > u
		y = u
	elseif y < l
		y = l
	end
	return y	
end	

function sim_sys(sys, u=NaN, t=linspace(0, 3600, 10000), x0=[100, 20])
	if length(u) == 1	
		if isnan(u)
			u = zeros(length(t))
		end
	end
	lsimplot(sys, u, t, x0)
end
