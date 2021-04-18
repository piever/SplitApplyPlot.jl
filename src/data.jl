function column_scale_label(cols, x::Pair{<:Any, <:Pair})
    columnname, scale_label = x
    scale, label = scale_label
    return getcolumn(cols, columnname), scale, string(label)
end

column_scale_label(cols, x) = column_scale_label(cols, x => automatic => x)

to_transformation(plottype::PlotFunc) = Visual(plottype)
to_transformation(f) = f

function splitapplyplot!(f, fig, data, args...; kwargs...)
    cols = columns(data)
    csl = map(arguments(args...; kwargs...)) do x
        return column_scale_label(cols, x)
    end
    mappings, scales′, labels = ntuple(i -> map(t -> t[i], csl), 3)
    scales = default_scales(mappings, scales′)

    entry = Entry(Any, mappings)
    input_entries = Entries([entry], labels, scales)
    transformation = to_transformation(f)
    entries = transformation(input_entries)
    axes_grid = compute_axes_grid(fig, split_entries(entries))
    foreach(plot!, axes_grid)
    return axes_grid
end
