struct Density
    options::Dict{Symbol, Any}
end
Density(; kwargs...) = Density(Dict{Symbol, Any}(kwargs))

function _density(data; xlims = (-Inf, Inf), trim = false, kwargs...)
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

function _density(datax, datay; xlims = (-Inf, Inf), ylims = (-Inf, Inf), trim = false, kwargs...)
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

function (d::Density)(le::Entry)
    labels, mappings = map(getlabel, le.mappings), map(getvalue, le.mappings)
    grouping_cols = (; (k => v for (k, v) in mappings.named if !iscontinuous(v))...)
    newmappings = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
        submappings = map(v -> view(v, idxs), mappings)
        args = submappings.positional
        new_args = _density(args...; d.options...)
        named = map(grouping_cols) do v
            return idxs isa Colon ? v : fill(v[first(idxs)], length(first(new_args)))
        end
        m = arguments(new_args...; named...)
        return isnothing(acc) ? map(collect, m) : map(append!, acc, m)
    end
    newlabels = copy(labels)
    push!(newlabels.positional, "PDF")
    defaultplot = length(mappings.positional) == 1 ? Lines : Heatmap
    return Entry(
        AbstractPlotting.plottype(le.plottype, defaultplot),
        map(Labeled, newlabels, newmappings),
        le.attributes
    )
end

density(; kwargs...) = Layer((Density(; kwargs...),))
