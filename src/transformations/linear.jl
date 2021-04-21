struct Linear
    options::Dict{Symbol, Any}
end

Linear(; kwargs...) = Linear(Dict{Symbol, Any}(kwargs))

function (l::Linear)(le::LabeledEntry)
    mappings = le.mappings
    grouping_cols = (; (k => v for (k, v) in mappings.named if !iscontinuous(v))...)
    newmappings = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
        submappings = map(v -> view(v, idxs), mappings)
        x, y = submappings.positional
        x̂ = [x x]
        x̂[:, 2] .= 1
        a, b = x̂ \ y
        length = 100
        rg = range(extrema(x)...; length)
        named = map(grouping_cols) do v
            return idxs isa Colon ? v : fill(v[first(idxs)], length)
        end
        m = arguments(rg, a .* rg .+ b; named...)
        return isnothing(acc) ? map(collect, m) : map(append!, acc, m)
    end
    return LabeledEntry(
        AbstractPlotting.plottype(le.plottype, Lines),
        newmappings,
        le.labels,
        le.attributes
    )
end

linear(; kwargs...) = Layer((Linear(; kwargs...),))