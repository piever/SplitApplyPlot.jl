function column_scale_label(cols, x::Pair{<:Any, <:Pair})
    columnname, scale_label = x
    scale, label = scale_label
    return getcolumn(cols, columnname), scale, string(label)
end

column_scale_label(cols, x) = column_scale_label(cols, x => automatic => x)

function fast_hashed(v::AbstractVector)
    w = refarray(v)
    return isbitstype(eltype(w)) ? refarray(PooledArray(w)) : w
end

function splitapplyplot!(plottype, fig, data, args...; kwargs...)
    cols = columns(data)
    csl = map(arguments(args...; kwargs...)) do x
        return column_scale_label(cols, x)
    end
    mappings, scales′, labels = ntuple(i -> map(t -> t[i], csl), 3)
    scales = default_scales(mappings, scales′)

    grouping_cols = Tuple(mappings[k] for (k, v) in scales.named if isadiscretescale(v))
    grouping_sa = StructArray(map(fast_hashed, grouping_cols))
    iterator = isempty(grouping_cols) ? [() => Colon()] : finduniquesorted(grouping_sa)

    list = map(iterator) do (_, idxs)
        submappings = map(v -> view(v, idxs), mappings)
        return Entry(plottype, submappings)
    end
    e = Entries(list, labels, scales)
    axes_grid = compute_axes_grid(fig, e)
    foreach(plot!, axes_grid)
    return axes_grid
end