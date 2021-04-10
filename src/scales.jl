struct DiscreteScale{S, T}
    scale::S
    uniquevalues::Vector{T}
end

DiscreteScale(scale) = DiscreteScale(scale, Union{}[])

function fit_to_data(scale::DiscreteScale, vs::AbstractVector...)
    uniques = map(uniquesort, vs)
    unique = uniquesort(vcat(uniques...))
    return DiscreteScale(scale.scale, unique)
end

(ds::DiscreteScale)(value) = apply_discrete_scale(ds.scale, ds.uniquevalues, value)

"""
    apply_discrete_scale(scale, uniquevalues, value)

Return the value in `scale` corresponding to the index of `value` in `uniquevalues`.
Cycle through `scale` if it has less entries than `uniquevalues`.
"""
apply_discrete_scale(scale, uniquevalues, value) = cycle(scale, findfirst(==(value), uniquevalues))

apply_discrete_scale(f::Base.Callable, _, value) = f(value)

apply_discrete_scale(::Nothing, uniquevalues, value) = apply_discrete_scale(identity, uniquevalues, value)

struct ContinuousScale{S, T}
    scale::S
    extrema::ClosedInterval{T}
end

ContinuousScale(scale) = ContinuousScale(scale, Inf..(-Inf))

function fit_to_data(scale::ContinuousScale, vs::AbstractVector...)
    extremas = map(extrema, vs)
    min, max = minimum(first, extremas), maximum(last, extremas)
    interval = ClosedInterval(min, max)
    return ContinuousScale(scale.scale, interval)
end

(cs::ContinuousScale)(values) = map(cs.scale, values) # FIXME: implement standard continuous scales
