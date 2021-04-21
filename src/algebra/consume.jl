function consume(layer::Layer)
    init = Layer((), layer.data, layer.entry)
    return foldl(consume, layer.transformations; init)
end

consume(layers::Layers, f) = Layers([consume(f, layer) for layer in layers])

consume(layer::Layer, f) = f(layer)

function analyze(layer::Layer)::Layers
    data, entry = process_columns(layer.data, layer.entry)
    l = Layer(layer.transformations, data, entry)
    return consume(l)
end

function analyze(layers::Layers)::Layers
    list = collect(Iterators.flatten(Iterators.map(analyze, layers)))
    return Layers(list)
end
