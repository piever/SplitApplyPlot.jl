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

struct AxisEntries
    axis::Axis
    entries::Entries
end

Entries() = Entries(Entry[], arguments(), arguments())

extend_extrema((l1, u1), (l2, u2)) = min(l1, l2), max(u1, u2)

join_summaries!(i1::Tuple, i2::Tuple) = extend_extrema(i1, i2)
join_summaries!(s1::Set, s2::Set) = union!(s1, i2)

apply_summary(s::Tuple, v) = v
apply_summary(s::Set, el) = count(≤(el), s)

function combine!(acc::Entries, labelled_entry::LabelledEntry)
    entry = labelled_entry.entry
    push!(acc.list, entry)
    mergewith!(acc.labels, labelled_entry.labels) do l1, l2
        return isempty(l1) ? l1 : l2
    end
    mergewith!(union!, acc.summaries, Arguments(; map(Set{Any}, entry.group)...))
    mergewith!(extend_extrema, acc.summaries, map(extrema, entry.select))
    return acc
end

# Maybe add layout to Trace?
function add_entry!(entries_dict, labelled_entry)
    entry = labelled_entry.entry
    layout = (get(entry.group, :layout_y, 1), get(entry.group, :layout_x, 1))
    entries = get!(Entries, entries_dict, layout) # look up entries list or initialize empty
    combine!(entries, labelled_entry)
    return entries_dict
end

function axes_grid(fig, iterator)
    init = Dict{NTuple{2, Any}, Entries}()
    entries_dictionary = foldl(add_entry!, iterator; init)
    summaries_iter = (entries.summaries for entries in values(entries_dictionary))
    # Here we may want to control whether we link scales across axes
    summaries = foldl(summaries_iter, init=arguments()) do acc, v
        return mergewith!(join_summaries!, acc, v)
    end
    layout_summaries = map(sym -> get(summaries, dym, Set{Any}(1)), (:layout_y, :layout_x))
    M, N = map(length, layout_summaries)

    mat = Union{AxisEntries, Missing}[missing for _ in CartesianIndices((M, N))]
    for (datalayout, entries) in pairs(entries_dictionary)
        layout = map(apply_summary, layout_summaries, datalayout)
        axis = Axis(fig[layout...])
        mat[layout...] = AxisEntries(axis, entries)
    end
    return mat
end

