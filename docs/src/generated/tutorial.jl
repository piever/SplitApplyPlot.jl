using SplitApplyPlot, CairoMakie

df = (
    x=rand(100),
    y=rand(100),
    z=rand(100),
    c=rand(Bool, 100),
    d=rand(Bool, 100),
    e=rand(Bool, 100),
)

grp = (marker=:c, layout_x=:d, layout_y=:e)

fig = Figure()
draw(Scatter, fig, df, grp, :x, :y, color=:z)
display(fig)