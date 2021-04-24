# Apply default faceting look to a grid of `AxisEntries`

function facet_wrap!(fig, aes::AbstractMatrix{AxisEntries})
    scale = get(aes[1].scales, :layout, nothing)
    isnothing(scale) && return
    linkaxes!(aes...)
    for ae in aes
        ax = Axis(ae)
        entries = ae.entries
        vs = Iterators.filter(
            !isnothing,
            (get(entry.mappings, :layout, nothing) for entry in entries)
        )
        it = iterate(vs)
        if isnothing(it)
            delete!(ax)
        else
            v, _ = it
            ax.title[] = string(first(v))
        end
    end
    return
end

# F. Greimel implementation from AlgebraOfGraphics

# TODO: add configuration options here (esp. to determine when / how to link)
function facet_grid!(fig, aes::AbstractMatrix{AxisEntries})
    M, N = size(aes)
    row_scale, col_scale = map(sym -> get(aes[1].scales, sym, nothing), (:row, :col))
    all(isnothing, (row_scale, col_scale)) && return
    hideinnerdecorations!(aes)
    linkaxes!(aes...)
    if !isnothing(row_scale)
        for ae in aes
            Axis(ae).ylabelvisible[] = false
        end
        row_dict = Dict(zip(row_scale.plot, row_scale.data))
        for m in 1:M
            Box(fig[m, N, Right()], color=:gray85, strokevisible=true)
            Label(fig[m, N, Right()], string(row_dict[m]); rotation=-π/2)
        end
        protrusion = lift(
            (xs...) -> maximum(x -> x.left, xs),
            (MakieLayout.protrusionsobservable(Axis(ae)) for ae in aes[:, 1])...
        )
        # TODO: here and below, set in such a way that one can change padding after the fact?
        padding = lift(protrusion, Axis(aes[1]).ylabelpadding) do val, p
            return (0f0, val + p, 0f0, 0f0)
        end
        Label(fig[:, 1, Left()], Axis(aes[1]).ylabel; rotation=π/2, padding)
    end
    if !isnothing(col_scale)
        for ae in aes
            Axis(ae).xlabelvisible[] = false
        end
        col_dict = Dict(zip(col_scale.plot, col_scale.data))
        for n in 1:N
            Box(fig[1, n, Top()], color=:gray85, strokevisible=true)
            Label(fig[1, n, Top()], string(col_dict[n]))
        end
        protrusion = lift(
            (xs...) -> maximum(x -> x.bottom, xs),
            (MakieLayout.protrusionsobservable(Axis(ae)) for ae in aes[M, :])...
        )
        padding = lift(protrusion, Axis(aes[1]).xlabelpadding) do val, p
            return (0f0, 0f0, 0f0, val + p)
        end
        Label(fig[M, :, Bottom()], Axis(aes[1]).xlabel; padding)
    end
    return
end

function facet!(fig, aes::AbstractMatrix{AxisEntries})
    facet_wrap!(fig, aes)
    facet_grid!(fig, aes)
    return
end

function facet!(fg::FigureGrid)
    facet!(fg.figure, fg.grid)
    return fg
end