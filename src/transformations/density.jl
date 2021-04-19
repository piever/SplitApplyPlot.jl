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

function (d::Density)(e::Entries)
    entries, labels, scales = e.entries, e.labels, e.scales
    new_entries = Entry[]
    for entry in entries
        mappings = entry.mappings
        grouping_cols = (; (k => mappings[k] for (k, v) in scales.named if isacategoricalscale(v))...)
        result = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
            submappings = map(v -> view(v, idxs), mappings)
            args = submappings.positional
            new_args = _density(args...; d.options...)
            named = map(grouping_cols) do v
                return idxs isa Colon ? v : fill(v[first(idxs)], length(first(new_args)))
            end
            new_mappings = arguments(new_args...; named...)
            return isnothing(acc) ? map(collect, new_mappings) : map(append!, acc, new_mappings)
        end
        push!(new_entries, Entry(Lines, result, entry.attributes))
    end
    return Entries(
        new_entries,
        combine(labels, arguments("PDF")),
        combine(scales, arguments(identity)),
    )
end

density(; kwargs...) = Spec(Density(; kwargs...))
