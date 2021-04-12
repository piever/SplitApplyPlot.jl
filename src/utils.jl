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

function hideinnerdecorations!(axes_mat::Matrix{<:Union{AxisEntries, Missing}})
    foreach(axes_mat[1:end-1, :]) do ax
        isa(ax, AxisEntries) && hidexdecorations!(Axis(ax))
    end
    foreach(axes_mat[:, 2:end]) do ax
        isa(ax, AxisEntries) && hideydecorations!(Axis(ax))
    end
end

uniquesort(v) = collect(uniquesorted(v))