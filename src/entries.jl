struct Entry
    plottype::PlotFunc
    mappings::Arguments
    attributes::Dict{Symbol, Any}
end

Entry(plottype::PlotFunc=Any, mappings=arguments(); attributes...) =
    Entry(plottype, mappings, Dict{Symbol, Any}(attributes))

Entry(mappings::Arguments; attributes...) = Entry(Any, mappings; attributes...)

struct LabeledEntry
    plottype::PlotFunc
    mappings::Arguments
    labels::Arguments
    attributes::Dict{Symbol, Any}
end

Entry(le::LabeledEntry) = Entry(le.plottype, le.mappings, le.attributes)

struct Entries
    entries::Vector{Entry}
    scales::Arguments
    labels::Arguments
end

Entries() = Entries(Entry[], arguments(), arguments())

function compute_axes_grid(fig, e::Entries; axis=NamedTuple())

    rowcol = (:row, :col)

    layout_scale, scales... = map((:layout, rowcol...)) do sym
        return get(e.scales, sym, nothing)
    end

    grid_size = map(scales, (first, last)) do scale, f
        isnothing(scale) || return maximum(scale.plot)
        isnothing(layout_scale) || return maximum(f, layout_scale.plot)
        return 1
    end

    axes_grid = map(CartesianIndices(grid_size)) do c
        ax = Axis(fig[Tuple(c)...]; axis...)
        return AxisEntries(ax, Entry[], e.scales, e.labels)
    end

    for entry in e.entries
        rows, cols = map(rowcol, scales, (first, last)) do sym, scale, f
            v = get(entry.mappings, sym, nothing)
            layout_v = get(entry.mappings, :layout, nothing)
            # without layout info, plot on all axes
            # all values in `v` and `layout_v` are equal
            isnothing(v) || return rescale(v[1:1], scale)
            isnothing(layout_v) || return map(f, rescale(layout_v[1:1], layout_scale))
            return 1:f(grid_size)
        end
        for i in rows, j in cols
            ae = axes_grid[i, j]
            push!(ae.entries, entry)
        end
    end

    return axes_grid

end

# TODO: join figure and axis grid in a unique "displayable" object
function AbstractPlotting.plot(entries::Entries; axis=NamedTuple(), figure=NamedTuple())
    fig = Figure(; figure...)
    grid = plot!(fig, entries; axis)
    return FigureGrid(fig, grid)
end

function AbstractPlotting.plot!(fig, entries::Entries; axis=NamedTuple())
    axes_grid = compute_axes_grid(fig, split_entries(entries); axis)
    foreach(plot!, axes_grid)
    return axes_grid
end

"""
    AxisEntries(axis::Union{Axis, Nothing}, entries::Vector{Entry}, labels, scales)

Define all ingredients to make plots on an axis.
Each scale can be either a `CategoricalScale` (for discrete collections), such as
`CategoricalScale(["a", "b"], ["red", "blue"])`, or a function,
such as `log10`. Other scales may be supported in the future.
"""
struct AxisEntries
    axis::Axis
    entries::Vector{Entry}
    scales::Arguments
    labels::Arguments
end

AbstractPlotting.Axis(ae::AxisEntries) = ae.axis
Entries(ae::AxisEntries) = Entries(ae.entries, ae.labels, ae.scales)

function prefix(i::Int, sym::Symbol)
    var = (:x, :y, :z)[i]
    return Symbol(var, sym)
end

function AbstractPlotting.plot!(ae::AxisEntries)
    axis, entries, labels, scales = ae.axis, ae.entries, ae.labels, ae.scales
    for entry in entries
        plottype, mappings, attributes = entry.plottype, entry.mappings, entry.attributes
        trace = map(rescale, mappings, scales)
        positional, named = trace.positional, trace.named
        merge!(named, attributes)
        for sym in [:col, :row, :layout]
            pop!(named, sym, nothing)
        end
        plot!(plottype, axis, positional...; named...)
    end
    # TODO: support log colorscale
    for i in 1:2
        label, scale = get(labels, i, nothing), get(scales, i, nothing)
        any(isnothing, (label, scale)) && continue
        axislabel, ticks, axisscale = prefix.(i, (:label, :ticks, :scale))
        if scale isa CategoricalScale
            u = map(string, scale.data)
            getproperty(axis, ticks)[] = (axes(u, 1), u)
        end
        getproperty(axis, axislabel)[] = string(label)
    end
    return axis
end

struct FigureGrid
    figure::Figure
    grid::Matrix{AxisEntries}
end

Base.show(io::IO, fg::FigureGrid) = show(io, fg.figure)
Base.show(io::IO, m::MIME, fg::FigureGrid) = show(io, m, fg.figure)
Base.show(io::IO, ::MIME"text/plain", fg::FigureGrid) = print(io, "FigureGrid()")

Base.showable(mime::MIME{M}, fg::FigureGrid) where {M} = showable(mime, fg.figure)

Base.display(fg::FigureGrid) = display(fg.figure)

function FileIO.save(filename::String, fg::FigureGrid; kwargs...)
    return FileIO.save(FileIO.query(filename), fg; kwargs...)
end

function FileIO.save(file::FileIO.Formatted, fg::FigureGrid; kwargs...)
    return FileIO.save(file, fg.figure; kwargs...)
end

to_tuple(fg) = (fg.figure, fg.grid)

Base.iterate(fg::FigureGrid) = iterate(to_tuple(fg))
Base.iterate(fg::FigureGrid, i) = iterate(to_tuple(fg), i)