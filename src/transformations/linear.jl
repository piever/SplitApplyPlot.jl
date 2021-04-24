struct LinearAnalysis
    options::Dict{Symbol, Any}
end

LinearAnalysis(; kwargs...) = LinearAnalysis(Dict{Symbol, Any}(kwargs))

function (l::LinearAnalysis)(le::Entry)
    return splitapply(le) do entry
        labels, mappings = map(getlabel, entry.mappings), map(getvalue, entry.mappings)
        x, y = mappings.positional
        x̂ = [x x]
        x̂[:, 2] .= 1
        a, b = x̂ \ y
        length = 100
        rg = range(extrema(x)...; length)
        m = arguments(rg, a .* rg .+ b)
        return Entry(
            AbstractPlotting.plottype(entry.plottype, Lines),
            map(Labeled, labels, m),
            entry.attributes
        )
    end
end

linear(; kwargs...) = Layer((LinearAnalysis(; kwargs...),))