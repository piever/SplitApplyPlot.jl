struct Counter end

function cycle(scale, i)
    scale′ = to_value(scale)
    return scale′[mod1(i, length(scale′))]
end

cycle(::Counter, i) = i

"""
    apply_scale(scale, uniquevalues, value)

Return the value in `scale` corresponding to the index of `value` in `uniquevalues`.
Cycle through `scale` if it has less entries than `uniquevalues`.
"""
apply_scale(scale, uniquevalues, value) = cycle(scale, findfirst(==(value), uniquevalues))

apply_scale(f::Base.Callable, _, value) = f(value)

apply_scale(::Nothing, uniquevalues, value) = apply_scale(identity, uniquevalues, value)

"""
    iscontinuous(v::AbstractVector)

Determine whether `v` should be treated as a continuous or categorical vector.
"""
iscontinuous(::AbstractVector) = false
iscontinuous(::AbstractVector{<:Number}) = true
iscontinuous(::AbstractVector{<:Bool}) = false

function remove_fields(a::NamedTuple, as::NamedTuple...)
    return foldl(Base.structdiff, as, init=a)
end

function recurse_values(f, nts::NamedTuple...)
    return map((v...) -> recurse_values(f, v...), nts...)
end
recurse_values(f, vs...) = f(vs...)

function recurse_extract(scales, uniquevalues)
    k = keys(uniquevalues)
    v = map(k) do key
        scale, value = get(scales, key, nothing), uniquevalues[key]
        return value isa NamedTuple ? recurse_extract(scale, value) : scale
    end
    return NamedTuple{k}(v)
end