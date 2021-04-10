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
ap = AxisPlot(
    Axis(fig[1, 1]),
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
#
# # Generating `AxisPlot` objects
#
# Generating `AxisPlot` objects by hand is extremely laborious. SplitApplyPlot provides
# a simple way to generate them from data.

using RDatasets
diamonds = RDatasets.dataset("ggplot2", "diamonds")
resolution = (600, 600)
fig = Figure(; resolution)
axisplots(fig, diamonds, (color=:Clarity,), arguments(:Carat, :Depth))

# `layout_x` and `layout_y` can be used to return a less trivial grid of axis plots.
resolution = (1200, 1200)
fig = Figure(; resolution)
ap = axisplots(
    fig,
    diamonds,
    (color=:Clarity, layout_x=:Cut, layout_y=:Color),
    arguments(:Carat, :Depth)
)

# The result can then be plotted as follows:
foreach(plot!, skipmissing(ap)) # some combination of facets may be missing
fig
AbstractPlotting.save("axisplot_grid.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](axisplot_grid.svg)
#
# # Generating `AxisPlot` objects