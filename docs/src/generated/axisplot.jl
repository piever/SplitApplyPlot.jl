# # AxisPlots
#
# The key ingredient for data representations are `AxisPlot`s. An `AxisPlot` is
# made of four components:
# - axis,
# - list of traces,
# - scales,
# - labels.

using SplitApplyPlot, CairoMakie
resolution = (600, 600)
fig = Figure(; resolution)
ax = Axis(fig[1, 1])
ap = AxisPlot(
    ax,
    [
        arguments(rand(10), rand(10), color=rand(10), marker="b"),
        arguments(rand(10), rand(10), color=rand(10), marker="c"),
    ],
    arguments(
        ContinuousScale(identity, 0..1),
        ContinuousScale(identity, 0..1),
        color=ContinuousScale(identity, 0..1),
        marker=DiscreteScale([:circle, :xcross, :utriangle], ["a", "b", "c"]),
    ),
    arguments("weight", "height", color="age", marker="name"),
)
plot!(ap)
fig
AbstractPlotting.save("axisplot.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](axisplot.svg)
