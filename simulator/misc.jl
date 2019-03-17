
struct ss
    A::AbstractArray{Float64,2}
    B::AbstractArray{Float64,2}
    C::AbstractArray{Float64,2}
end

struct ssd
    F::AbstractArray{Float64,2}
    G::AbstractArray{Float64,2}
    H::AbstractArray{Float64,2}
end

struct control_opt
    controller::Function
    r::Function
    h::Float64
end

@with_kw mutable struct sim_data
    T::AbstractArray{Float64,1} = zeros(1)
    x::AbstractArray{Float64,2} = zeros(1,1)
    y::AbstractArray{Float64,2} = zeros(1,1)
    e::AbstractArray{Float64,2} = zeros(1,1)
    u::AbstractArray{Float64,2} = zeros(1,1)
end
