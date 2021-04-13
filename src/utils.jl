function cycle(v::AbstractVector, i::Int)
    ax = axes(v, 1)
    return v[first(ax) + mod(i - first(ax), length(ax))]
end

"""
    iscontinuous(v::AbstractVector)

Determine whether `v` should be treated as a continuous or categorical vector.
"""
iscontinuous(::AbstractVector) = false
iscontinuous(::AbstractVector{<:Number}) = true
iscontinuous(::AbstractVector{<:Bool}) = false

function getcolumns(cols, select)
    return map(name -> getcolumn(cols, name), select)
end

for sym in [:hidexdecorations!, :hideydecorations!, :hidedecorations!]
    @eval function $sym(ae::AxisEntries)
        axis = Axis(ae)
        isnothing(axis) || $sym(axis)
    end
end

for sym in [:linkxaxes!, :linkyaxes!, :linkaxes!]
    @eval function $sym(ae::AxisEntries, aes::AxisEntries...)
        axs = filter(!isnothing, map(Axis, (ae, aes...)))
        $sym(axs...)
    end
end

function hideinnerdecorations!(aes::Matrix{AxisEntries})
    foreach(hidexdecorations!, aes[1:end-1, :])
    foreach(hideydecorations!, aes[:, 2:end])
end

function fillmissingaxes!(aes::Matrix{AxisEntries})
    c = findfirst(has_axis, aes)
    fig = Axis(aes[c]).parent
    for c in CartesianIndices(aes)
        i, j = c[1], c[2]
        ae = aes[i, j]
        has_axis(ae) || (aes[i, j] = merge(ae, Axis(fig[i, j])))
    end
    return aes
end

uniquesort(v) = collect(uniquesorted(v))