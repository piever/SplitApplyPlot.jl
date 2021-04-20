struct Linear
    options::Dict{Symbol, Any}
end

Linear(; kwargs...) = Linear(Dict{Symbol, Any}(kwargs))

# FIXME: factor out the grouping mechanism
function (l::Linear)(e::Entries)
    entries, scales, labels = e.entries, e.scales, e.labels
    new_entries = Entry[]
    for entry in entries
        mappings = entry.mappings
        grouping_cols = (; (k => mappings[k] for (k, v) in scales.named if isacategoricalscale(v))...)
        result = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
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
            new_mappings = arguments(rg, a .* rg .+ b; named...)
            return isnothing(acc) ? map(collect, new_mappings) : map(append!, acc, new_mappings)
        end
        push!(new_entries, Entry(Lines, result, entry.attributes))
    end
    return Entries(new_entries, scales, labels)
end

linear(; kwargs...) = Spec(Linear(; kwargs...))