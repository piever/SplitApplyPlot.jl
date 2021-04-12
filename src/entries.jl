function default_palettes()
    abstractplotting_palette = AbstractPlotting.current_default_theme()[:palette]
    return Dict(k => to_value(v) for (k, v) in abstractplotting_palette)
end

function apply_palettes(k, v; palettes, summaries, iscontinuous)
    summary = summaries[k]
    r = apply_summary(summary, v)
    (iscontinuous || !haskey(palettes, k)) && return r
    return cycle(palettes[k], r) # FIXME: support continuous palettes?
end

Base.@kwdef struct Entry
    plottype::PlotFunc=Any
    group::NamedTuple=NamedTuple()
    select::Arguments=arguments()
    labels::Arguments=arguments()
    attributes::Dict{Symbol, Any}=Dict{Symbol, Any}()
end

Entry(plottype::PlotFunc; kwargs...) = Entry(; plottype, kwargs...)

struct Entries
    list::Vector{Entry}
    labels::Arguments
    summaries::Arguments
end

Entries() = Entries(Entry[], arguments(), arguments())

struct AxisEntries
    axis::Axis
    entries::Entries
end

AbstractPlotting.Axis(ae::AxisEntries) = ae.axis

extend_extrema((l1, u1), (l2, u2)) = min(l1, l2), max(u1, u2)

join_summaries!(i1::Tuple, i2::Tuple) = extend_extrema(i1, i2)
join_summaries!(s1::Set, s2::Set) = union!(s1, s2)

apply_summary(::Tuple, v) = v
apply_summary(s::Set, el) = count(≤(el), s)

function combine!(acc::Entries, entry::Entry)
    push!(acc.list, entry)
    mergewith!(acc.labels, entry.labels) do l1, l2
        return isempty(l1) ? l1 : l2
    end
    mergewith!(union!, acc.summaries, arguments(; map(Set{Any}, entry.group)...))
    mergewith!(extend_extrema, acc.summaries, map(extrema, entry.select))
    return acc
end

function add_entry!(entries_dict, entry)
    layout = (get(entry.group, :layout_y, 1), get(entry.group, :layout_x, 1))
    entries = get!(Entries, entries_dict, layout) # look up entries list or initialize empty
    combine!(entries, entry)
    return entries_dict
end

function axes_grid(fig, iterator)
    init = Dict{NTuple{2, Any}, Entries}()
    entries_dictionary = foldl(add_entry!, iterator; init)
    summaries_iter = (entries.summaries for entries in values(entries_dictionary))
    summaries = foldl(summaries_iter, init=arguments()) do acc, v
        return mergewith!(join_summaries!, acc, v)
    end
    # Here we may want to control whether we link scales across axes, simple version is to link everything
    foreach(summaries_iter) do el
        mergewith!((a, b) -> b, el, summaries)
    end
    layout_summaries = map(sym -> get(summaries, dym, Set{Any}(1)), (:layout_y, :layout_x))
    sz = map(length, layout_summaries)
    mat = Union{AxisEntries, Missing}[missing for _ in CartesianIndices(sz)]
    for (datalayout, entries) in pairs(entries_dictionary)
        layout = map(apply_summary, layout_summaries, datalayout)
        axis = Axis(fig[layout...])
        mat[layout...] = AxisEntries(axis, entries)
    end
    return mat
end

function AbstractPlotting.plot!(ae::AxisEntries, palettes=default_palettes())
    axis, entries = ae.axis, ae.entries
    for entry in entries.list
        plottype, group, select, attributes = entry.plottype, entry.group, entry.select, entry.attributes
        scaledtrace = copy(select) # initialize with correct number of positional values
        for cont in (select.positional, select.named, group), (k, v) in pairs(cont)
            k in (:layout_y, :layout_x) && continue
            iscontinuous = cont !== group
            scaledtrace[k] = apply_palettes(k, v; palettes, entries.summaries, iscontinuous)
        end
        positional, named = scaledtrace.positional, scaledtrace.named
        merge!(named, attributes)
        plot!(plottype, axis, positional...; named...)
    end
    labels, summaries = entries.labels, entries.summaries
    for (i, (label, summary)) in enumerate(zip(labels.positional, summaries.positional))
        axislabel, ticks = i == 1 ? (:xlabel, :xticks) : (:ylabel, :yticks)
        # FIXME: checkout proper fix in AbstractPlotting
        if summary isa Set
            u = sort(collect(summary))
            getproperty(axis, ticks)[] = (axes(u, 1), u)
        else
            @assert summary isa NTuple{2, Real}
            axis.limits[] = Base.setindex(axis.limits[], summary, i)
        end
        getproperty(axis, axislabel)[] = string(label)
    end
    return axis
end
