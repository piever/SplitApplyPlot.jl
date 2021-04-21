struct Visual
    plottype::PlotFunc
    attributes::Dict{Symbol, Any}
end
Visual(plottype=Any; kwargs...) = Visual(plottype, Dict{Symbol, Any}(kwargs))

function (v::Visual)(e::LabeledEntry)
    plottype = AbstractPlotting.plottype(e.plottype, v.plottype)
    mappings, labels = e.mappings, e.labels
    attributes = merge(e.attributes, v.attributes)
    return LabeledEntry(plottype, mappings, labels, attributes)
end

visual(plottype=Any; kwargs...) = Layer((Visual(plottype; kwargs...),))