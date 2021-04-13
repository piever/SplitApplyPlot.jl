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

function splitapplyplot!(f, fig, data, args...; kwargs...)
    cols = columns(data)
    csl = map(arguments(args...; kwargs...)) do x
        return column_scale_label(cols, x)
    end
    mappings, scales′, labels = ntuple(i -> map(t -> t[i], csl), 3)
    scales = default_scales(mappings, scales′)

    layout_scales = map(sym -> get(scales, sym, LittleDict(1 => 1)), (:layout_y, :layout_x))
    grid_size = map(length, layout_scales)
    axes_grid = map(CartesianIndices(grid_size)) do c
        i, j = Tuple(c)
        axis = Axis(fig[i, j])
        return AxisEntries(axis, Entry[], copy(labels), copy(scales))
    end
    grouping_cols = Tuple(mappings[k] for (k, v) in scales.named if isadiscretescale(v))
    grouping_sa = StructArray(map(fast_hashed, grouping_cols))
    iterator = isempty(grouping_cols) ? [() => Colon()] : finduniquesorted(grouping_sa)

    foreach(iterator) do (_, idxs)
        submappings = map(v -> view(v, idxs), mappings)
        layout = map((:layout_y, :layout_x), layout_scales) do sym, scale
            v = pop!(submappings, sym, (1,))
            return rescale(v, scale)[1]
        end
        ae = axes_grid[layout...]
        append!(ae.entries, to_entries(f(submappings)))
    end
    # FIXME: should refit continuous scales here
    foreach(plot!, axes_grid)
    return axes_grid
end