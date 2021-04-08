using SplitApplyPlot, CairoMakie

@time let
    df = (
        x=rand(100),
        y=rand(100),
        z=rand(100),
        c=rand(Bool, 100),
        d=rand(Bool, 100),
        e=rand(Bool, 100),
    )

    grp = mapping(marker=:c, layout_x=:d, layout_y=:e)
    m = mapping(:x, :y, color=:z)

    fig = Figure()
    draw(fig, df, grp, m) do ax, args, attrs
        scatter!(ax, args...; attrs...)
    end

    fig
    nothing
end

ax = Axis(fig[1, 1])

ax.title[] = false;