using SplitApplyPlot

df = (
    x=rand(100),
    y=rand(100),
    z=rand(100),
    c=rand(Bool, 100),
    d=rand(Bool, 100),
    e=rand(Bool, 100),
)

fig = Figure()
grp = Group(marker=:c, layout_x=:d, layout_y=:e, axis=(title=:e,))
m = Mapping(:x, :y, color=:z)

draw(fig, df, grp, m) do ax, args, attrs
    @show keys(attrs)
    scatter!(ax, args...; attrs...)
end


fig

ax = Axis(fig[1, 1])

ax.title[] = false;