struct Counter end

cycle(v, i) = v[mod1(i, length(v))]

cycle(::Counter, i) = i

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

function hideinnerdecorations!(axes_mat::Matrix{<:Union{AxisPlot, Missing}})
    foreach(axes_mat[1:end-1, :]) do ax
        isa(ax, AxisPlot) && hidexdecorations!(Axis(ax))
    end
    foreach(axes_mat[:, 2:end]) do ax
        isa(ax, AxisPlot) && hideydecorations!(Axis(ax))
    end
end

uniquesort(v) = collect(uniquesorted(v))