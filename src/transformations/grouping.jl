function fast_hashed(v::AbstractVector)
    w = refarray(v)
    return isbitstype(eltype(w)) ? refarray(PooledArray(w)) : w
end

function indices_iterator(cols)
    isempty(cols) && return Ref(Colon())
    grouping_sa = StructArray(map(fast_hashed, cols))
    gp = GroupPerm(grouping_sa)
    return (sortperm(gp)[rg] for rg in gp)
end

# TODO: decide more carefully when to split
function split_entries(e::Entries, isgrouping=isadiscretescale∘last)
    entries, labels, scales = e.entries, e.labels, e.scales
    flattened_entries = Entry[]
    for entry in entries
        mappings = entry.mappings
        grouping_cols = Tuple(mappings[k] for (k, v) in scales.named if isgrouping(k => v))
        foreach(indices_iterator(grouping_cols)) do idxs
            submappings = map(v -> view(v, idxs), mappings)
            new_entry = Entry(entry.plottype, submappings, entry.attributes)
            push!(flattened_entries, new_entry)
        end
    end
    return Entries(flattened_entries, labels, scales)
end