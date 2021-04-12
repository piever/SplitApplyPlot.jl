function palettes()
    abstractplotting_palette = AbstractPlotting.current_default_theme()[:palette]
    return Dict(k => to_value(v) for (k, v) in abstractplotting_palette)
end

struct Entry
    plottype::PlotFunc
    group::NamedTuple
    select::Arguments
    attributes::Dict{Symbol, Any}
end

struct LabelledEntry
    entry::Entry
    labels::Arguments
end

struct Entries
    list::Vector{Entry}
    labels::Arguments
    summaries::Arguments
end

Entries() = Entries(Entry[], arguments(), arguments())

extend_extrema((l1, u1), (l2, u2)) = min(l1, l2), max(u1, u2)

function combine_entries!(acc::Entries, labelled_entry::LabelledEntry)
    entry = labelled_entry.entry
    push!(acc.list, entry)
    mergewith!(acc.labels, labelled_entry.labels) do l1, l2
        return isempty(l1) ? l1 : l2
    end
    mergewith!(union!, acc.summaries, Arguments(; map(Set{Any}, entry.group)...))
    mergewith!(extend_extrema, acc.summaries, map(extrema, entry.select))
    return acc
end

foldl(entries, init=Dict()) do acc, entry
    layout = map(sym -> get(entry.group, sym, 1), (:layout_y, :layout_x))
    buffer = get(acc, layout, nothing)
end

# Maybe add layout to Trace?
function addtrace!(T::PlotFunc, trace_hashlist, group, select, labels; attributes...)
    
    # Initialize `trace` with columns from `select`
    trace = copy(select)
    # Add arguments from grouping
    merge!(trace.named, pairs(group))
    # Remove layout information
    layout = map((:layout_y, :layout_x)) do sym
        l = pop!(trace, sym, 1)
        ls = get(uniquevalues, sym, [1])
        return findfirst(==(l), ls)
    end

    
        axisplot = get!(axisplots, layout) do
            axis = Axis(fig[layout...])
            scales = map(select) do _
                return ContinuousScale(identity)
            end
            for (key, val) in pairs(group)
                scale = get(palette, key, Counter)
                scales[key] = DiscreteScale(scale)
            end
            return AxisPlot(axis, Trace[], scales, labels)
        end

        push!(axisplot.tracelist, Trace(T, trace, Dict(attributes)))
    end
    M, N = maximum(first, keys(axisplots)), maximum(last, keys(axisplots))
    return Union{AxisPlot, Missing}[get(axisplots, Tuple(c), missing) for c in CartesianIndices((M, N))]
end

function fitscales!(axisplots::AbstractMatrix{<:Union{AxisPlot, Missing}})
    datas = [trace.data for trace in ap.tracelist for ap in skipmissing(axisplots)]
    for ap in skipmissing(axisplots)
        fitscales!(ap.scales, datas) # FIXME: a lot of redundant computation here
    end
    return axisplots
end