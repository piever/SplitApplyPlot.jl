struct Linear
    options::Dict{Symbol, Any}
end

Linear(; kwargs...) = Linear(Dict{Symbol, Any}(kwargs))

function (l::Linear)(layer::Layer)
    data, entry = layer.data, layer.entry
    mappings = entry.mappings
    grouping_cols = filter(!iscontinuous, Tuple(data))
    newdata = map(v -> similar(v, 0), data)
    result = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
        subdata = map(v -> view(v, idxs), data)
        xname, yname = mappings.positional
        x, y = subdata[xname], subdata[yname]
        x̂ = [x x]
        x̂[:, 2] .= 1
        a, b = x̂ \ y
        length = 200
        new_x = collect(range(extrema(x)...; length))
        new_y = @. a * new_x + b
        vals = map(keys(subdata)) do k
            col = subdata[k]
            return (k == xname) ? new_x : (k == yname) ? new_y : fill(first(col), length)
        end
        new_data = NamedTuple{keys(subdata)}(vals)
        return isnothing(acc) ? new_data : map(append!, acc, new_data)
    end
    return Layer((), result, combine(entry, Entry(Lines)))
end

linear(; kwargs...) = Layer((Linear(; kwargs...),))