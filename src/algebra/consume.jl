function consume(layers::Layers)
    nested = map(consume, layers)
    return reduce(vcat, nested)
end

function consume(layer::Layer)
    init = [process_columns(layer.data, layer.mappings)]
    return foldl(consume, layer.transformations; init)
end

to_labeledentries(l::LabeledEntry) = [l]
to_labeledentries(l::AbstractVector{LabeledEntry}) = l

function consume(v::AbstractVector{LabeledEntry}, f)
    results = [consume(le, f) for le in v]
    return reduce(vcat, results)
end

consume(le::LabeledEntry, f) = to_labeledentries(f(le))
