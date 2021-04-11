struct Arguments
    positional::Vector{Any}
    named::Dict{Symbol, Any}
end

function arguments(args...; kwargs...)
    positional = collect(Any, args)
    named = Dict{Symbol, Any}(kwargs)
    return Arguments(positional, named)
end

Base.getindex(args::Arguments, i::Int) = args.positional[i]
Base.getindex(args::Arguments, sym::Symbol) = args.named[sym]
Base.setindex!(args::Arguments, val, i::Int) = (args.positional[i] = val)
Base.setindex!(args::Arguments, val, sym::Symbol) = (args.named[sym] = val)
Base.pop!(args::Arguments, i::Int, default) = pop!(args.positional, i, default)
Base.pop!(args::Arguments, sym::Symbol, default) = pop!(args.named, sym, default)

Base.copy(args::Arguments) = Arguments(copy(args.positional), copy(args.named))

function Base.map(f, a::Arguments, as::Arguments...)
    is = eachindex(a.positional)
    ks = keys(a.named)
    function g(i)
        vals = map(t -> t[i], (a, as...))
        return f(vals...)
    end
    positional = collect(Any, Iterators.map(g, is))
    named = Dict{Symbol, Any}(k => g(k) for k in ks)
    return Arguments(positional, named)
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
        positional, named = scaledtrace.positional, scaledtrace.named
        merge!(named, trace.attributes)
        plot!(trace.plottype, axis, positional...; named...)
    end
    for (i, (label, scale)) in enumerate(zip(labels.positional, scales.positional))
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
