struct Density
    options::Dict{Symbol, Any}
end
Density(; kwargs...) = Density(Dict{Symbol, Any}(kwargs))

function _density(data; xlims = (-Inf, Inf), trim = false, kwargs...)
    k = kde(data; kwargs...)
    x, y = k.x, k.density
    xmin, xmax = xlims
    xmin = max(xmin, minimum(data))
    xmax = min(xmax, maximum(data))
    if trim
        for i in eachindex(x, y)
            xmin ≤ x[i] ≤ xmax || (y[i] = NaN)
        end
    end
    return (x, y)
end

function _density(datax, datay; xlims = (-Inf, Inf), ylims = (-Inf, Inf), trim = false, kwargs...)
    k = kde((datax, datay); kwargs...)
    x, y, z = k.x, k.y, k.density
    xmin, xmax = xlims
    xmin = max(xmin, minimum(datax))
    xmax = min(xmax, maximum(datax))
    ymin, ymax = ylims
    ymin = max(ymin, minimum(datay))
    ymax = min(ymax, maximum(datay))
    if trim
        for i in eachindex(x, y)
            xmin ≤ x[i] ≤ xmax && ymin ≤ y[i] ≤ ymax || (z[i] = NaN)
        end
    end
    return (x, y, z)
end

function (d::Density)(layer::Layer)
    data, entry = layer.data, layer.entry
    mappings = entry.mappings
    grouping_cols = filter(!iscontinuous, Tuple(data))
    pdfname = newname(keys(data), :PDF)
    result = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
        subdata = map(v -> view(v, idxs), data)
        pos_names = mappings.positional
        args = map(n -> subdata[n], pos_names)
        new_args = _density(args...; d.options...)
        vals = map(keys(subdata)) do k
            i = findfirst(==(k), pos_names)
            return if isnothing(i)
                col = subdata[k]
                fill(first(col), length(first(new_args)))
            else
                collect(new_args[i])
            end
        end
        new_data = merge(
            NamedTuple{keys(subdata)}(vals),
            NamedTuple{(pdfname,)}((last(new_args),))
        )
        return isnothing(acc) ? new_data : map(append!, acc, new_data)
    end
    new_entry = combine(entry, Entry(Lines, arguments(pdfname)))
    return Layer((), result, new_entry)
end

density(; kwargs...) = Layer((Density(; kwargs...),))
