struct Entry
    plottype::PlotFunc
    mappings::Arguments
    attributes::Dict{Symbol, Any}
end

Entry(plottype::PlotFunc, arguments; attributes...) =
    Entry(plottype, arguments, Dict{Symbol, Any}(attributes))

"""
    AxisEntries(axis::Union{Axis, Nothing}, entries::Vector{Entry}, labels, scales)

Define all ingredients to make plots on an axis.
Each scale can be either an ordered dictionary (for discrete collections), such as
`LittleDict("a" => "red", "b" => "blue")`, or a pair giving an interval and a function,
such as `(0, 10) => log10`. Other scales may be supported in the future.
"""
struct AxisEntries
    axis::Union{Axis, Nothing}
    entries::Vector{Entry}
    labels::Arguments
    scales::Arguments
end

AxisEntries(axis::Union{Axis, Nothing}=nothing, entries::AbstractVector{Entry}=Entry[]) =
    AxisEntries(axis, entries, arguments(), arguments())
AxisEntries(axis::Union{Axis, Nothing}, entry::Entry) = AxisEntries(axis, [entry])
AxisEntries(entries::AbstractVector{Entry}) = AxisEntries(nothing, entries)

AbstractPlotting.Axis(ae::AxisEntries) = ae.axis
has_axis(ae::AxisEntries) = !isnothing(Axis(ae))

function Base.merge!(ae1::AxisEntries, ae2::AxisEntries)
    axis = isnothing(ae2.axis) ? ae1.axis : ae2.axis
    entries = append!(ae1.entries, ae2.entries)
    labels = mergewith!((a, b) -> isempty(b) ? a : b, ae1.labels, ae2.labels)
    scales = mergewith!(merge_scales, ae1.scales, ae2.scales)
    return AxisEntries(axis, entries, labels, scales)
end

Base.merge(ae::AxisEntries, aes::AxisEntries...) = foldl(merge!, (ae, aes...), init=AxisEntries())
Base.merge(ae::AxisEntries, axis::Axis) = merge(ae, AxisEntries(axis))

function AbstractPlotting.plot!(ae::AxisEntries)
    has_axis(ae) || return
    axis, entries, labels, scales = ae.axis, ae.entries, ae.labels, ae.scales
    @assert !isnothing(axis)
    for entry in entries
        plottype, mappings, attributes = entry.plottype, entry.mappings, entry.attributes
        trace = map(rescale, mappings, scales)
        positional, named = trace.positional, trace.named
        merge!(named, attributes)
        plot!(plottype, axis, positional...; named...)
    end
    for (i, (label, scale)) in enumerate(zip(labels.positional, scales.positional))
        axislabel, ticks = i == 1 ? (:xlabel, :xticks) : (:ylabel, :yticks)
        if isadiscretescale(scale)
            u = collect(keys(scale))
            getproperty(axis, ticks)[] = (axes(u, 1), u)
        else
            @assert isacontinuousscale(scale)
            axis.limits[] = Base.setindex(axis.limits[], first(scale), i)
            # TODO: also set axis scale
        end
        getproperty(axis, axislabel)[] = string(label)
    end
    return axis
end
