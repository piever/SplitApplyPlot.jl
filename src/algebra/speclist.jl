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

function Entries(s::OneOrMoreSpecs)
    l::SpecList = s
    return foldl((f, x) -> f(x), l, init=Entries())
end

function AbstractPlotting.plot!(fig, s::OneOrMoreSpecs; axis=NamedTuple())
    return plot!(fig, Entries(s); axis)
end

function AbstractPlotting.plot(s::OneOrMoreSpecs; axis=NamedTuple(), figure=NamedTuple())
    return plot(Entries(s); axis, figure)
end
