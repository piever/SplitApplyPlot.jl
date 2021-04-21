function fast_hashed(v::AbstractVector)
    w = refarray(v)
    return isbitstype(eltype(w)) ? refarray(PooledArray(w)) : w
end

function indices_iterator(cols)
    isempty(cols) && return Ref(Colon())
    grouping_sa = StructArray(map(fast_hashed, cols))
    gp = GroupPerm(grouping_sa)
    return (sortperm(gp)[rg] for rg in gp)
end

function isgrouping((k, v),)
    unsplittable_attrs = (:dodge, :stack)
    return k ∉ unsplittable_attrs && isa(v, CategoricalScale)
end

# Here we decide how to split entries in order to plot them
function split_entries(e::Entries, isgrouping=isgrouping)
    entries, scales, labels = e.entries, e.scales, e.labels
    flattened_entries = Entry[]
    for entry in entries
        mappings = entry.mappings
        iter = (get(mappings, k, nothing) for (k, v) in scales.named if isgrouping(k => v))
        grouping_cols = Tuple(Iterators.filter(!isnothing, iter))
        foreach(indices_iterator(grouping_cols)) do idxs
            submappings = map(v -> view(v, idxs), mappings)
            new_entry = Entry(entry.plottype, submappings, entry.attributes)
            push!(flattened_entries, new_entry)
        end
    end
    return Entries(flattened_entries, scales, labels)
end

# function transform_by_group(f, data, mappings)
#     labels = copy(mappings)
#     discrete_labels = Dict{Symbol, Any}()
#     new_labels = nothing
#     for (k, v) in pairs(labels.named)
#         if !iscontinuous(data[k])
#             pop!(labels.named, k)
#             discrete_labels[k] = v
#         end
#     end
#     grouping_cols = filter(!iscontinuous, Tuple(data))
#     result = foldl(indices_iterator(grouping_cols), init=nothing) do acc, idxs
#         subdata = map(v -> view(v, idxs), data)
#         # consider name deduplication
#         new_data, new_labels = f(subdata, labels)
#         l = length(new_data[new_labels[1]])
#         discrete_data = map(col -> fill(first(col), l), subdata)
#         all_data = merge(discrete_data, new_data)
#         return isnothing(acc) ? map(collect, new_data) : map(append!, acc, new_data)
#     end
#     return result, mergewith!((_, b) -> b, new_labels, discrete_labels)
# end