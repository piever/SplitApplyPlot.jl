using SplitApplyPlot

df = (
    x=rand(100),
    y=rand(100),
    z=rand(100),
    c=rand(Bool, 100),
    d=rand(Bool, 100),
    e=rand(Bool, 100),
)

grp = Group(marker=:c, layout_x=:d, layout_y=:e, axis=(title=:e,))
m = Mapping(:x, :y, color=:z)

fig = Figure()
@time draw(fig, df, grp, m, axis=(xticklabelrotation=π/2,)) do ax, args, attrs
    scatter!(ax, args...; attrs...)
end


fig

ax = Axis(fig[1, 1])

ax.title[] = false;