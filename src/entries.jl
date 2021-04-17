struct Entry
    plottype::PlotFunc
    mappings::Arguments
    attributes::Dict{Symbol, Any}
end

Entry(plottype::PlotFunc, arguments; attributes...) =
    Entry(plottype, arguments, Dict{Symbol, Any}(attributes))

struct Entries
    entries::Vector{Entry}
    labels::Arguments
    scales::Arguments
end

Entries() = Entries(Entry[], arguments(), arguments())

"""
    Entries(iterator)

Return a unique `Entries` object from an iterator of `Entries`. Scales and labels are combined.
"""
Entries(iterator) = foldl(merge!, iterator, init=Entries())

function Base.merge!(e1::Entries, e2::Entries)
    entries = append!(e1.entries, e2.entries)
    labels = mergewith!((a, b) -> isempty(b) ? a : b, e1.labels, e2.labels)
    scales = mergewith!(merge_scales, e1.scales, e2.scales)
    return Entries(entries, labels, scales)
end

function compute_axes_grid(e::Entries)
    dict = Dict{NTuple{2, Any}, AxisEntries}()
    layout_scales = (
        layout_y=get(e.scales, :layout_y, LittleDict(1 => 1)),
        layout_x=get(e.scales, :layout_x, LittleDict(1 => 1)),
    )
    grid_size = map(length, layout_scales)
    axes_grid = map(CartesianIndices(Tuple(grid_size))) do c
        i, j = Tuple(c)
        axis = Axis(fig[i, j])
        return AxisEntries(axis, Entry[], labels, scales)
    end
    for entry in e.entries
        layout = map((:layout_y, :layout_x)) do sym
            scale = layout_scales[sym]
            col = get(entry.arguments, sym, nothing)
            # without layout info, plot on all axes
            return isnothing(col) ? (1:grid_size[sym]) : rescale(col, scale)[1]
        end
        for i in layout[1], j in layout[2]
            ae = axes_grid[i, j]
            push!(ae.entries, entry)
        end
    end
    return axis_grid
end

"""
    AxisEntries(axis::Union{Axis, Nothing}, entries::Vector{Entry}, labels, scales)

Define all ingredients to make plots on an axis.
Each scale can be either an ordered dictionary (for discrete collections), such as
`LittleDict("a" => "red", "b" => "blue")`, or a pair giving an interval and a function,
such as `(0, 10) => log10`. Other scales may be supported in the future.
"""
struct AxisEntries
    axis::Axis
    entries::Vector{Entry}
    labels::Arguments
    scales::Arguments
end

function AxisEntries(axis::Union{Axis, Nothing}=nothing,
                     entries::Union{AbstractVector{Entry}, Entry}=Entry[])
    return AxisEntries(axis, to_entries(entries), arguments(), arguments())
end
AxisEntries(axis::Union{Axis, Nothing}, entry::Entry) = AxisEntries(axis, [entry])
AxisEntries(entries::AbstractVector{Entry}) = AxisEntries(nothing, entries)

AbstractPlotting.Axis(ae::AxisEntries) = ae.axis
Entries(ae::AxisEntries) = Entries(ae.entries, ae.labels, ae.scales)

function Base.merge!(ae1::AxisEntries, ae2::AxisEntries)
    axis = isnothing(ae2.axis) ? ae1.axis : ae2.axis
    entries = append!(ae1.entries, ae2.entries)
    labels = mergewith!((a, b) -> isempty(b) ? a : b, ae1.labels, ae2.labels)
    scales = mergewith!(merge_scales, ae1.scales, ae2.scales)
    return AxisEntries(axis, entries, labels, scales)
end

function prefix(i::Int, sym::Symbol)
    var = (:x, :y, :z)[i]
    return Symbol(var, sym)
end

function AbstractPlotting.plot!(ae::AxisEntries)
    has_axis(ae) || return
    axis, entries, labels, scales = ae.axis, ae.entries, ae.labels, ae.scales
    for entry in entries
        plottype, mappings, attributes = entry.plottype, entry.mappings, entry.attributes
        trace = map(rescale, mappings, scales)
        positional, named = trace.positional, trace.named
        merge!(named, attributes)
        pop!(named, :layout_y, nothing)
        pop!(named, :layout_x, nothing)
        plot!(plottype, axis, positional...; named...)
    end
    # TODO: support log colorscale
    for (i, (label, scale)) in enumerate(zip(labels.positional, scales.positional))
        axislabel, ticks, axisscale = prefix.(i, (:label, :ticks, :scale))
        if isadiscretescale(scale)
            u = collect(keys(scale))
            getproperty(axis, ticks)[] = (axes(u, 1), u)
        else
            @assert isacontinuousscale(scale)
            if hasproperty(axis, axisscale) # support older AbstractPlotting
                getproperty(axis, axisscale)[] = scale
            end
        end
        getproperty(axis, axislabel)[] = string(label)
    end
    return axis
end
