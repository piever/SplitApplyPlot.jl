apply_context(cols, columnname::Union{Symbol, String}) = getcolumn(cols, columnname)
apply_context(cols, columnnames::Tuple) = map(Base.Fix1(getcolumn, cols), columnnames)

function column_scale_label(cols, x::Pair{<:Any, <:Union{AbstractString, Symbol}})
    columnname, label = x
    return column_scale_label(cols, columnname => automatic => label)
end

function column_scale_label(cols, x::Pair{<:Any, <:Any})
    columnname, scale = x
    return column_scale_label(cols, columnname => scale => columnname)
end

function column_scale_label(cols, x::Pair{<:Any, <:Pair})
    columnname, scale_label = x
    scale, label = scale_label
    return getcolumn(cols, columnname), scale, string(label)
end

column_scale_label(cols, x) = column_scale_label(cols, x => automatic => x)

function (e::Entries)(f, data, args...; kwargs...)
    cols = columns(data)
    csl = map(arguments(args...; kwargs...)) do x
        return column_scale_label(cols, x)
    end
    mappings, scales′, labels = ntuple(i -> map(t -> t[i], csl), 3)
    scales = default_scales(mappings, scales′)

    entry = Entry(Any, mappings)
    input_entries = Entries([entry], labels, scales)
    entries = f(input_entries)
    merge!(e, entries)
    return e
end

function AbstractPlotting.plot!(fig, entries::Entries)
    axes_grid = compute_axes_grid(fig, split_entries(entries))
    foreach(plot!, axes_grid)
    return axes_grid
end
