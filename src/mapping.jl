struct Mapping{T<:Tuple, names, NT<:Tuple}
    t::T
    nt::NamedTuple{names, NT}
end

mapping(args...; kwargs...) = Mapping(args, values(kwargs))

Base.Tuple(m::Mapping) = getfield(m, 1)
Base.NamedTuple(m::Mapping) = getfield(m, 2)

function AbstractPlotting.plot!(P::AbstractPlotting.PlotFunc, ax::Axis, m::Mapping)
    return plot!(P, ax, Tuple(m)...; NamedTuple(m)...)
end