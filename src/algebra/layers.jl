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

summary(v) = iscontinuous(v) ? extrema(v) : Set{Any}(v)
mergesummaries!(s1::Set, s2::Set) = union!(s1, s2)
mergesummaries!(s1::Tuple, s2::Tuple) = extend_extrema(s1, s2)

function Entries(s::OneOrMoreLayers, palettes=NamedTuple())
    summaries = arguments()
    labellists = arguments()
    entries = Entry[]
    for labeledentry in process_transformations(s)
        for le in splitapply(labeledentry)
            entry = Entry(le.plottype, map(getvalue, le.mappings), le.attributes)
            push!(entries, entry)
            mergewith!(mergesummaries!, summaries, map(summary, entry.mappings))
            mergewith!(union!, labellists, map(vcat∘getlabel, le.mappings))
        end
    end

    palettes = merge!(default_palettes(), arguments(; palettes...))
    scales = default_scales(summaries, palettes)
    labels = map(v -> join(v, ' '), labellists)

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
