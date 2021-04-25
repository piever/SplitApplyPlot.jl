const Mean = let
    init() = (0, 0.0)
    op((n, sum), val) = n + 1, sum + val
    value((n, sum)) = sum / n
    (; init, op, value)
end

const Counter = let
    init() = 0
    op(n, _) = n + 1
    value(n) = n
    (; init, op, value)
end

# Investigate link with transducers, potentially had shim to support OnlineStats
function _reducer(agg, sorted_summaries::Tuple, values...)
    init, op, value = agg.init, agg.op, agg.value
    results = map(_ -> init(), CartesianIndices(map(length, sorted_summaries)))
    keys, data = head(values), last(values)
    sa = StructArray(map(fast_hashed, keys))
    perm = sortperm(sa)
    for idxs in GroupPerm(sa, perm)
        key = sa[perm[first(idxs)]]
        acc = init()
        for idx in idxs
            val = data[perm[idx]]
            acc = op(acc, val)
        end
        I = map(searchsortedfirst, sorted_summaries, key)
        results[I...] = value(acc)
    end
    return results
end

struct ReducerAnalysis
    options::Dict{Symbol, Any}
end

function (r::ReducerAnalysis)(le::Entry)
    summaries = Tuple(map(summary∘getvalue, le.mappings.positional[1:end-1]))
    sorted_summaries = map(sort∘collect, summaries)
    return splitapply(le) do entry
        mappings = entry.mappings
        labels, values = map(getlabel, mappings.positional), map(getvalue, mappings.positional)
        results = _reducer(r.options[:agg], sorted_summaries, values...)
        result = (values..., results)
        labeled_result = map(Labeled, labels, result)
        default_plottype = categoricalplottypes[length(labels)]
        return Entry(
            AbstractPlotting.plottype(entry.plottype, default_plottype),
            arguments(labeled_result...),
            entry.attributes
        )
    end
end

"""
    reducer(args...)

Compute the expected value of the last argument conditioned on the preceding ones.
"""
reducer(; agg=Mean) = Layer((ReducerAnalysis(; agg),))