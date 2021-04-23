struct DensityAnalysis
    options::Dict{Symbol, Any}
end
DensityAnalysis(; kwargs...) = DensityAnalysis(Dict{Symbol, Any}(kwargs))

function _density(data; xlims=(-Inf, Inf), trim=false, kwargs...)
    k = kde(data; kwargs...)
    x, y = k.x, k.density
    xmin, xmax = xlims
    xmin = max(xmin, minimum(data))
    xmax = min(xmax, maximum(data))
    if trim
        for i in eachindex(x, y)
            xmin ≤ x[i] ≤ xmax || (y[i] = NaN)
        end
    end
    return (x, y)
end

function _density(datax, datay; xlims=(-Inf, Inf), ylims=(-Inf, Inf), trim=false, kwargs...)
    k = kde((datax, datay); kwargs...)
    x, y, z = k.x, k.y, k.density
    xmin, xmax = xlims
    xmin = max(xmin, minimum(datax))
    xmax = min(xmax, maximum(datax))
    ymin, ymax = ylims
    ymin = max(ymin, minimum(datay))
    ymax = min(ymax, maximum(datay))
    if trim
        for i in eachindex(x, y)
            xmin ≤ x[i] ≤ xmax && ymin ≤ y[i] ≤ ymax || (z[i] = NaN)
        end
    end
    return (x, y, z)
end

function (d::DensityAnalysis)(le::Entry)
    return splitapply(le) do entry
        labels, mappings = map(getlabel, entry.mappings), map(getvalue, entry.mappings)
        res = _density(mappings.positional...; mappings.named..., d.options...)
        labeled_res = map(Labeled, vcat(labels.positional, "pdf"), collect(res))
        plottypes = [Lines, Heatmap, Volume]
        default_plottype = plottypes[length(mappings.positional)]
        return Entry(
            AbstractPlotting.plottype(entry.plottype, default_plottype),
            Arguments(labeled_res),
            entry.attributes
        )
    end
end

density(; kwargs...) = Layer((DensityAnalysis(; kwargs...),))
