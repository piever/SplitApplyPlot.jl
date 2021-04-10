struct Arguments
    v::Vector{Any}
    d::Dict{Symbol, Any}
end

function arguments(args...; kwargs...)
    v = collect(Any, args)
    d = Dict{Symbol, Any}(kwargs)
    return Arguments(v, d)
end

Base.getindex(args::Arguments, i::Int) = args.v[i]
Base.getindex(args::Arguments, sym::Symbol) = args.d[sym]
Base.setindex!(args::Arguments, val, i::Int) = (args.v[i] = val)
Base.setindex!(args::Arguments, val, sym::Symbol) = (args.d[sym] = val)
Base.pop!(args::Arguments, i::Int, default) = pop!(args.v, i, default)
Base.pop!(args::Arguments, sym::Symbol, default) = pop!(args.d, sym, default)

function Base.map(f, a::Arguments, as::Arguments...)
    is = eachindex(a.v)
    ks = keys(a.d)
    function g(i)
        vals = map(t -> t[i], (a, as...))
        return f(vals...)
    end
    v = collect(Any, Iterators.map(g, is))
    d = Dict{Symbol, Any}(k => g(k) for k in ks)
    return Arguments(v, d)
end

struct AxisPlot
    axis::Axis
    tracelist::Vector{Arguments}
    scales::Arguments
    labels::Arguments
end

AbstractPlotting.Axis(ap::AxisPlot) = ap.axis

apply(f, x) = f(x)

function AbstractPlotting.plot!(ap::AxisPlot)
    axis, tracelist, scales, labels = ap.axis, ap.tracelist, ap.scales, ap.labels
    for trace in tracelist
        scaledtracelist = map(apply, scales, trace)
        plot!(axis, scaledtracelist.v...; scaledtracelist.d...)
    end
    for (label, scale, axislabel, ticks) in zip(labels.v, scales.v, [:xlabel, :ylabel], [:xticks, :yticks])
        # FIXME: checkout proper fix in AbstractPlotting
        if scale isa DiscreteScale
            u = scale.uniquevalues
            getproperty(axis, ticks)[] = (axes(u, 1), u)
        end
        getproperty(axis, axislabel)[] = string(label)
    end
    return axis
end
