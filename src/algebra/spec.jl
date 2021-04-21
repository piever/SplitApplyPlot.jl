struct Spec
    transformations::Tuple
    data::Any
    entry::Entry
end

Spec(transformations::Tuple=()) = Spec(transformations, nothing, Entry())

Spec(entry::Entry) = Spec((), nothing, entry)

data(df) = Spec((), df, Entry())
mapping(args...; kwargs...) = Spec(Entry(arguments(args...; kwargs...)))
visual(plottype=Any; attributes...) = Spec(Entry(plottype, arguments(); attributes...))

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

function Base.:*(spec1::Spec, spec2::Spec)
    t1, t2 = spec1.transformations, spec2.transformations
    d1, d2 = spec1.data, spec2.data
    e1, e2 = spec1.entry, spec2.entry
    transformations = combine(t1, t2) # in what order to execute them?
    data = isnothing(d2) ? d1 : d2
    entry = combine(e1, e2)
    return Spec(transformations, data, entry)
end
