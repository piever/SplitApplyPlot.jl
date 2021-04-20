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

function isgrouping((k, v),)
    unsplittable_attrs = (:dodge, :stack)
    return k ∉ unsplittable_attrs && isacategoricalscale(v)
end

function _broadcastable(column, scale)
    singlescale = isacategoricalscale(scale) || isacontinuousscale(scale)
    return singlescale ? (Ref(column), Ref(scale)) : (column, scale)
end

function subselect(column, scale, idxs)
    singlescale = isacategoricalscale(scale) || isacontinuousscale(scale)
    return singlescale ? view(column, idxs) : view.(column, Ref(idxs))
end

# TODO: decide more carefully when to split
function split_entries(e::Entries, isgrouping=isgrouping)
    entries, labels, scales = e.entries, e.labels, e.scales
    flattened_entries = Entry[]
    for entry in entries
        mappings = entry.mappings
        flattened_cols = []
        for (k, vs) in scales.named
            col = get(mappings, k, nothing)
            isnothing(col) && continue
            cols, scs = _broadcastable(col, vs)
            for (col, v) in zip(cols, scs)
                isgrouping(k => v) && push!(flattened_cols, col)
            end
        end
        grouping_cols = Tuple(flattened_cols)
        foreach(indices_iterator(grouping_cols)) do idxs
            submappings = map(mappings, scales) do v, scale
                return subselect(v, scale, idxs)
            end
            new_entry = Entry(entry.plottype, submappings, entry.attributes)
            push!(flattened_entries, new_entry)
        end
    end
    return Entries(flattened_entries, labels, scales)
end