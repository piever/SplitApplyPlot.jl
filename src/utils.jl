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

for sym in [:hidexdecorations!, :hideydecorations!, :hidedecorations!]
    @eval function $sym(ae::AxisEntries; kwargs...)
        axis = Axis(ae)
        isnothing(axis) || $sym(axis; kwargs...)
    end
end

for sym in [:linkxaxes!, :linkyaxes!, :linkaxes!]
    @eval function $sym(ae::AxisEntries, aes::AxisEntries...)
        axs = filter(!isnothing, map(Axis, (ae, aes...)))
        $sym(axs...)
    end
end

function hideinnerdecorations!(aes::Matrix{AxisEntries})
    options = (label=true, ticks=true, minorticks=true, grid=false, minorgrid=false)
    foreach(ae -> hidexdecorations!(ae; options...), aes[1:end-1, :])
    foreach(ae -> hideydecorations!(ae; options...), aes[:, 2:end])
end

function deleteemptyaxes!(aes::Matrix{AxisEntries})
    for (i, ae) in enumerate(aes)
        if isempty(ae.entries)
            axis = Axis(ae)
            if !isnothing(axis)
                delete!(axis)
                aes[i] = AxisEntries(nothing, ae.entries, ae.labels, ae.scales)
            end
        end
    end
end

uniquesort(v) = collect(uniquesorted(v))

extend_extrema((l1, u1), (l2, u2)) = min(l1, l2), max(u1, u2)

function newname(names, sym)
    newsym, i = sym, 1
    while newsym in names
        newsym = Symbol(sym, i)
        i += 1
    end
    return newsym
end
