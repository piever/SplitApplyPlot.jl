function column_scale_label(cols, x::Pair{<:Any, <:Pair})
    columnname, scale_label = x
    scale, label = scale_label
    return getcolumn(cols, columnname), scale, string(label)
end

column_scale_label(cols, x) = column_scale_label(cols, x => automatic => x)

maybe_pool(v::AbstractVector{T}) where {T} = isbitstype(T) ? v : PooledArray(v)

function splitapplyplot!(f, fig, data, args...; kwargs...)
    cols = columns(data)
    csl = map(arguments(args...; kwargs...)) do x
        return column_scale_label(cols, x)
    end
    mappings, scales′, labels = ntuple(i -> map(t -> t[i], csl), 3)
    scales = default_scales(mappings, scales′)

    layout_scales = map(sym -> get(scales, sym, LittleDict(1 => 1)), (:layout_y, :layout_x))
    grid_size = map(length, layout_scales)
    axes_grid = map(CartesianIndices(grid_size)) do _
        return AxisEntries(nothing, Entry[], copy(labels), copy(scales))
    end
    grouping_keys = Tuple(mappings[k] for (k, v) in scales.named if isadiscretescale(v))
    grouping_sa = StructArray(map(maybe_pool, grouping_keys))
    iterator = isempty(grouping_keys) ? [Colon()] : GroupPerm(grouping_sa)

    foreach(iterator) do idxs
        submappings = map(v -> view(v, idxs), mappings)
        layout = map((:layout_y, :layout_x), layout_scales) do sym, scale
            v = pop!(submappings, sym, (1,))
            return rescale(v, scale)[1]
        end
        ae′ = axes_grid[layout...]
        # Draw new axis if no axis is present
        new_axis = has_axis(ae′) ? nothing : Axis(fig[layout...])
        ae = AxisEntries(new_axis, f(submappings))
        axes_grid[layout...] = merge!(ae′, ae)
    end
    foreach(plot!, axes_grid)
    return axes_grid
end