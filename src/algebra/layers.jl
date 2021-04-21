struct Layers
    layers::Vector{Layer}
end

Base.convert(::Type{Layers}, s::Layer) = Layers([s])
Base.convert(::Type{Layers}, s::Layers) = s

Base.getindex(v::Layers, i::Int) = v.layers[i]
Base.length(v::Layers) = length(v.layers)
Base.eltype(::Type{Layers}) = Layer
Base.iterate(v::Layers, args...) = iterate(v.layers, args...)

const OneOrMoreLayers = Union{Layers, Layer}

function Base.:+(s1::OneOrMoreLayers, s2::OneOrMoreLayers)
    l1::Layers, l2::Layers = s1, s2
    return Layers(vcat(l1.layers, l2.layers))
end

function Base.:*(s1::OneOrMoreLayers, s2::OneOrMoreLayers)
    l1::Layers, l2::Layers = s1, s2
    return Layers([el1 * el2 for el1 in l1 for el2 in l2])
end

summarize(v) = iscontinuous(v) ? extrema(v) : Set{Any}(v)
merge_summaries!(s1::Set, s2::Set) = union!(s1, s2)
merge_summaries!(s1::Tuple, s2::Tuple) = extend_extrema(s1, s2)

function Entries(s::OneOrMoreLayers, palettes=NamedTuple())

    palettes = mergewith!((_, b) -> b, default_palettes(), arguments(; palettes...))

    labeledentries = consume(s)

    entries = map(Entry, labeledentries)

    op(::Nothing, mappings) = map(String, mappings)
    op(acc, mappings) = mergewith!(acc, mappings) do x, y
        return isempty(String(y)) ? String(x) : String(y)
    end

    labels = mapfoldl(le -> le.labels, op, labeledentries, init=nothing)

    summaries = mapfoldl((a, b) -> mergewith!(merge_summaries!, a, b), entries, init=arguments()) do entry
        return map(summarize, entry.mappings)
    end

    scales = default_scales(summaries, palettes)

    return Entries(entries, scales, labels)

end

function AbstractPlotting.plot!(fig, s::OneOrMoreLayers;
                                axis=NamedTuple(), palettes=NamedTuple())
    return plot!(fig, Entries(s, palettes); axis)
end

function AbstractPlotting.plot(s::OneOrMoreLayers;
                               axis=NamedTuple(), figure=NamedTuple(), palettes=NamedTuple())
    return plot(Entries(s, palettes); axis, figure)
end
