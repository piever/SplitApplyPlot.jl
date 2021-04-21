struct Layer
    transformations::Tuple
    data::Any
    entry::Entry
end

Layer(transformations::Tuple=()) = Layer(transformations, nothing, Entry())

Layer(entry::Entry) = Layer((), nothing, entry)

data(df) = Layer((), df, Entry())
mapping(args...; kwargs...) = Layer(Entry(arguments(args...; kwargs...)))
visual(plottype=Any; attributes...) = Layer(Entry(plottype, arguments(); attributes...))

function combine(a1::Arguments, a2::Arguments)
    return Arguments(
        vcat(a1.positional, a2.positional),
        merge(a1.named, a2.named)
    )
end

combine(t1::Tuple, t2::Tuple) = (t1..., t2...)

function combine(entry1::Entry, entry2::Entry)
    plottype = AbstractPlotting.plottype(entry1.plottype, entry2.plottype)
    mappings = combine(entry1.mappings, entry2.mappings)
    attributes = merge(entry1.attributes, entry2.attributes)
    return Entry(plottype, mappings, attributes)
end

function Base.:*(l1::Layer, l2::Layer)
    t1, t2 = l1.transformations, l2.transformations
    d1, d2 = l1.data, l2.data
    e1, e2 = l1.entry, l2.entry
    transformations = combine(t1, t2) # in what order to execute them?
    data = isnothing(d2) ? d1 : d2
    entry = combine(e1, e2)
    return Layer(transformations, data, entry)
end
