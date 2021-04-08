using SplitApplyPlot, CairoMakie

df = (
    x=rand(100),
    y=rand(100),
    z=rand(100),
    c=rand(Bool, 100),
    d=rand(Bool, 100),
    e=rand(Bool, 100),
)

fig = Figure()
splitapplyplot(Scatter, fig, df, (marker=:c, layout_x=:d, layout_y=:e), :x, :y, color=:z)
display(fig)

fig = Figure()
splitapplyplot(Scatter, fig, df, (marker=:c, layout_x=:d, layout_y=:e, title=:e), :x, :y, color=:z)
display(fig)