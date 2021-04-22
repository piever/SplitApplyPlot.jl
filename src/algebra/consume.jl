function consume(layers::Layers)
    nested = map(consume, layers)
    return reduce(vcat, nested)
end

function consume(layer::Layer)
    init = process_columns(layer.data, layer.mappings)
    return foldl(consume, layer.transformations; init)
end

function consume(v::AbstractArray{LabeledEntry}, f)
    results = [consume(le, f) for le in v]
    return reduce(vcat, results)
end

consume(le::LabeledEntry, f) = maybewrap(f(le))
