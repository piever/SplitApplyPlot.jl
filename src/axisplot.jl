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

Base.copy(args::Arguments) = Arguments(copy(args.v), copy(args.d))

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

struct Trace
    plottype::PlotFunc
    data::Arguments
    attributes::Dict{Symbol, Any}
end

Trace(plottype::PlotFunc, data::Arguments) = Trace(plottype, data, Dict{Symbol, Any}())

struct AxisPlot
    axis::Axis
    tracelist::Vector{Trace}
    scales::Arguments
    labels::Arguments
end

Base.show(io::IO, ap::AxisPlot) = print(io, "AxisPlot {...}")

AbstractPlotting.Axis(ap::AxisPlot) = ap.axis

function AbstractPlotting.plot!(ap::AxisPlot)
    axis, tracelist, scales, labels = ap.axis, ap.tracelist, ap.scales, ap.labels
    for trace in tracelist
        scaledtrace = map(|>, trace.data, scales)
        plot!(trace.plottype, axis, scaledtrace.v...; scaledtrace.d..., trace.attributes...)
    end
    for (i, (label, scale)) in enumerate(zip(labels.v, scales.v))
        axislabel, ticks = i == 1 ? (:xlabel, :xticks) : (:ylabel, :yticks)
        # FIXME: checkout proper fix in AbstractPlotting
        if scale isa DiscreteScale
            u = scale.uniquevalues
            getproperty(axis, ticks)[] = (axes(u, 1), u)
        else
            min, max = extrema(scale.extrema)
            axis.limits[] = Base.setindex(axis.limits[], (min, max), i)
        end
        getproperty(axis, axislabel)[] = string(label)
    end
    return axis
end
