struct Linear
    options::Dict{Symbol, Any}
end

Linear(; kwargs...) = Linear(Dict{Symbol, Any}(kwargs))

function (l::Linear)(e::Entries)
    entries, labels, scales = e.entries, e.labels, e.scales
    new_entries = Entry[]
    for entry in entries
        mappings = entry.mappings
        grouping_cols = (; (k => mappings[k] for (k, v) in scales.named if isadiscretescale(v))...)
        result = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
            submappings = map(v -> view(v, idxs), mappings)
            x, y = submappings.positional
            x̂ = [x x]
            x̂[:, 2] .= 1
            a, b = x̂ \ y
            length = 100
            rg = range(extrema(x)...; length)
            i1 = first(idxs)
            named = map(v -> fill(v[i1], length), grouping_cols)
            new_mappings = arguments(rg, a .* rg .+ b; named...)
            return isnothing(acc) ? map(collect, new_mappings) : map(append!, acc, new_mappings)
        end
        push!(new_entries, Entry(Lines, result, entry.attributes))
    end
    return Entries(new_entries, labels, scales)
end