struct Visual
    plottype::PlotFunc
    attributes::Dict{Symbol, Any}
end
Visual(plottype=Any; kwargs...) = Visual(plottype, Dict{Symbol, Any}(kwargs))

function (v::Visual)(e::Entry)
    plottype = AbstractPlotting.plottype(e.plottype, v.plottype)
    mappings = e.mappings
    attributes = merge(e.attributes, v.attributes)
    return Entry(plottype, mappings, attributes)
end

function (v::Visual)(e::Entries)
    entries = Entries(map(v, e.entries), e.labels, e.scales)
    function isgrouping((k, v),)
        unsplittable_attrs = (:dodge, :stack)
        return k ∉ unsplittable_attrs && isadiscretescale(v)
    end
    return split_entries(entries, isgrouping)
end