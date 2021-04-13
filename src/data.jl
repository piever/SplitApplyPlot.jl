function column_scale_label(cols, x::Pair{<:Any, <:Pair})
    columnname, scale_label = x
    scale, label = scale_label
    return getcolumn(cols, columnname), scale, string(label)
end

column_scale_label(cols, x) = column_scale_label(cols, x => automatic => x)

function splitapplyplot(f, fig, data, args...; kwargs...)
    cols = columns(data)
    csl = map(arguments(args...; kwargs...)) do x
        return column_scale_label(cols, x)
    end
    columns, scales′, labels = ntuple(map(t -> t[i], csl), 3)
    scales = default_scales(columns, scales′)
    grouping_keys = [k for (k, v) in scales.named if isacontinuousscale(v)]
end