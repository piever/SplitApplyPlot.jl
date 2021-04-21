struct SpecList
    specs::Vector{Spec}
end

Base.convert(::Type{SpecList}, s::Spec) = SpecList([s])
Base.convert(::Type{SpecList}, s::SpecList) = s

Base.getindex(v::SpecList, i::Int) = v.specs[i]
Base.length(v::SpecList) = length(v.specs)
Base.eltype(::Type{SpecList}) = Spec
Base.iterate(v::SpecList, args...) = iterate(v.specs, args...)

const OneOrMoreSpecs = Union{SpecList, Spec}

function Base.:+(s1::OneOrMoreSpecs, s2::OneOrMoreSpecs)
    l1::SpecList, l2::SpecList = s1, s2
    return SpecList(vcat(l1.specs, l2.specs))
end

function Base.:*(s1::OneOrMoreSpecs, s2::OneOrMoreSpecs)
    l1::SpecList, l2::SpecList = s1, s2
    return SpecList([el1 * el2 for el1 in l1 for el2 in l2])
end

summarize(v) = iscontinuous(v) ? extrema(v) : Set{Any}(v)
merge_summaries!(s1::Set, s2::Set) = union!(s1, s2)
merge_summaries!(s1::Tuple, s2::Tuple) = extend_extrema(s1, s2)

function Entries(s::OneOrMoreSpecs, palettes=default_palettes())
    specs::SpecList = analyze(s)

    entries = map(specs) do spec
        return apply_context(spec.data, spec.entry)
    end

    labels = foldl(specs, init=nothing) do acc, spec
        entry = spec.entry
        mappings = entry.mappings
        return if isnothing(acc)
            map(String, mappings)
        else
            mergewith!(acc, spec) do x, y
                return isempty(String(y)) ? String(x) : String(y)
            end
        end
    end

    summaries = mapfoldl((a, b) -> mergewith!(merge_summaries!, a, b), entries, init=arguments()) do entry
        return map(summarize, entry.mappings)
    end

    scales = default_scales(summaries, palettes)
    return Entries(entries, scales, labels)
end

function AbstractPlotting.plot!(fig, s::OneOrMoreSpecs; axis=NamedTuple())
    return plot!(fig, Entries(s); axis)
end

function AbstractPlotting.plot(s::OneOrMoreSpecs; axis=NamedTuple(), figure=NamedTuple())
    return plot(Entries(s); axis, figure)
end
