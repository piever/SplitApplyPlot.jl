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
        axs = Broadcast.combine_axes(mappings.positional..., values(mappings.named)...)
        iter = (get(mappings, k, nothing) for (k, v) in scales.named if isgrouping(k => v))
        grouping_cols = Tuple(Iterators.filter(t -> t isa AbstractVector, iter))
        foreach(indices_iterator(grouping_cols)) do idxs
            for c in CartesianIndices(Base.tail(axs))
                submappings = map(mappings) do v
                    I = ntuple(ndims(v)) do n
                        i = n == 1 ? idxs : c[n-1]
                        return adjust_index(axs[n], axes(v, n), i)
                    end
                    return view(v, I...)
                end
                new_entry = Entry(entry.plottype, submappings, entry.attributes)
                push!(flattened_entries, new_entry)
            end
        end
    end
    return Entries(flattened_entries, scales, labels)
end

# function group(le::LabelledEntry; unsplittable=())
#     les = LabelledEntry[]
#     mappings = le.mappings
#     axs = Broadcast.combine_axes(mappings.positional..., values(mappings.named)...)
#     iter = (m for (k, m) in mappings.named
#         if m isa AbstractVector && !iscontinuous(m) && k ∉ unsplittable)
#     grouping_cols = Tuple(iter)
#     foreach(indices_iterator(grouping_cols)) do idxs
#         for c in CartesianIndices(Base.tail(axs))
#             submappings = map(mappings) do v
#                 I = ntuple(ndims(v)) do n
#                     i = n == 1 ? idxs : c[n-1]
#                     return adjust_index(axs[n], axes(v, n), i)
#                 end
#                 return view(v, I...)
#             end
#             new_entry = LabeledEntry(le.plottype, submappings, le.labels, le.attributes)
#             push!(les, new_entry)
#         end
#     end
#     return les
# end