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
