const ArrayLike = Union{AbstractArray, Tuple}
const StringLike = Union{AbstractString, Symbol}

function cycle(v::AbstractVector, i::Int)
    ax = axes(v, 1)
    return v[first(ax) + mod(i - first(ax), length(ax))]
end

"""
    iscontinuous(v::AbstractArray)

Determine whether `v` should be treated as a continuous or categorical vector.
"""
iscontinuous(::AbstractArray) = false
iscontinuous(::AbstractArray{<:Number}) = true

isaxis2d(::Axis) = true
isaxis2d(::Any) = false

isaxis(::Axis) = true
isaxis(::Axis3) = true
isaxis(::Any) = false

for sym in [:hidexdecorations!, :hideydecorations!, :hidedecorations!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = Axis(ae)
        isaxis2d(axis) && $sym(axis; kwargs...)
    end
end

for sym in [:linkxaxes!, :linkyaxes!, :linkaxes!]
    @eval function $sym(ae::AxisEntries, aes::AxisEntries...)
        axs = filter(isaxis2d, map(Axis, (ae, aes...)))
        isempty(axs) || $sym(axs...)
    end
end

function hideinnerdecorations!(aes::Matrix{AxisEntries})
    options = (label=true, ticks=true, minorticks=true, grid=false, minorgrid=false)
    foreach(ae -> hidexdecorations!(ae; options...), aes[1:end-1, :])
    foreach(ae -> hideydecorations!(ae; options...), aes[:, 2:end])
end

function deleteemptyaxes!(aes::Matrix{AxisEntries})
    for ae in aes
        if isempty(ae.entries)
            delete!(Axis(ae))
        end
    end
end

extend_extrema((l1, u1), (l2, u2)) = min(l1, l2), max(u1, u2)

function assert_equal(a, b)
    @assert a == b
    return a
end

function unnest(arr::AbstractArray{<:AbstractArray})
    inner_size = mapreduce(size, assert_equal, arr)
    outer_size = size(arr)
    flattened = reduce(vcat, map(vec, vec(arr)))
    return reshape(flattened, inner_size..., outer_size...)
end

unnest(arr::NTuple{<:Any, <:AbstractArray}) = unnest(collect(arr))

adjust_index(rg1, rg2, idx::Integer) = idx in rg2 ? idx : only(rg2)
adjust_index(rg1, rg2, idxs::AbstractArray) = map(idx -> adjust_index(rg1, rg2, idx), idxs)
adjust_index(rg1, rg2, ::Colon) = rg1 == rg2 ? Colon() : fill(only(rg2), length(rg1))

maybewrap(x::ArrayLike) = x
maybewrap(x) = fill(x)

unwrap(x) = x
unwrap(x::AbstractArray{<:Any, 0}) = x[]
