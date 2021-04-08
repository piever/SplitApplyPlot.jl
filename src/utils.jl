"""
    map_keys(f, nt::NamedTuple)

Apply function `f` to keys of `nt`. Return a `NamedTuple`.
"""
function map_keys(f, nt::NamedTuple)
    k = keys(nt)
    v = map(f, k)
    return NamedTuple{k}(v)
end

function cycle(scale, i)
    scale′ = to_value(scale)
    return scale′[mod1(i, length(scale′))]
end

"""
    apply_scale(scale, uniquevalues, value)

Return the value in `scale` corresponding to the index of `value` in `uniquevalues`.
Cycle through `scale` if it has less entries than `uniquevalues`.
"""
apply_scale(scale, uniquevalues, value) = cycle(scale, findfirst(==(value), uniquevalues))

apply_scale(f::Base.Callable, _, value) = f(value)

apply_scale(::Nothing, uniquevalues, value) = findfirst(==(value), uniquevalues)

"""
    iscontinuous(v::AbstractVector)

Determine whether `v` should be treated as a continuous or categorical vector.
"""
iscontinuous(::AbstractVector) = false
iscontinuous(::AbstractVector{<:Number}) = true
iscontinuous(::AbstractVector{<:Bool}) = false
