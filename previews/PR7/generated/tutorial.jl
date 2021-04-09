using SplitApplyPlot, CairoMakie

df = (
    x=rand(100),
    y=rand(100),
    z=rand(100),
    c=rand(Bool, 100),
    d=rand(Bool, 100),
    e=rand(Bool, 100),
)

draw(Scatter, df, (marker=:c, layout_x=:d, layout_y=:e), mapping(:x, :y, color=:z))

draw(
    Scatter,
    df,
    (marker=:c, layout_x=:d, layout_y=:e, title=:e),
    mapping(:x, :y, color=:z)
)

fig = Figure()
axes_mat = draw!(fig, df, (marker=:c, layout_x=:d, layout_y=:e), mapping(:x, :y, color=:z)) do ax, m
    plot!(Scatter, ax, m)
    ax.xticklabelrotation[] = π/2
end
hideinnerdecorations!(axes_mat)
fig