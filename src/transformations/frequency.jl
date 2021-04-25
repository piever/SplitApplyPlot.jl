struct FrequencyAnalysis end

function (f::FrequencyAnalysis)(entry::Entry)
    plottype = entry.plottype
    mappings = copy(entry.mappings)
    N = length(getvalue(mappings[1]))
    push!(mappings.positional, Labeled("count", fill(nothing, N)))
    attributes = entry.attributes
    transformation = ReducerAnalysis(Dict{Symbol, Any}(:agg => Counter))
    return transformation(Entry(plottype, mappings, attributes))
end

"""
    frequency()

Compute a frequency table of the arguments.
"""
frequency() = Layer((FrequencyAnalysis(),))
