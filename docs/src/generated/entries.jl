# # AxisEntries
#
# The key ingredient for data representations are `AxisEntries`.
#
# ## The `AxisEntries` type
#
# An `AxisEntries` object is
# made of four components:
# - axis,
# - entries.

using SplitApplyPlot, CairoMakie
resolution = (600, 600)
fig = Figure(; resolution)
ae = AxisEntries(
    Axis(fig[1, 1]),
    [
        Entry(
            Scatter,
            arguments(rand(10), rand(10), color=rand(10), marker=fill("b", 10));
            markersize = 10
        ),
        Entry(
            Scatter,
            arguments(rand(10), rand(10), color=rand(10), marker=fill("c", 10));
            attributes = Dict(:markersize => 10),
        ),
    ],
    arguments("weight", "height", color="age", marker="name"), #labels
    arguments(
        (0, 1) => identity,
        (0, 1) => identity,
        color=(0, 1) => identity,
        marker=LittleDict("a" => :circle, "b" => :utriangle, "c" => :dtriangle), #scales
    ),
)
plot!(ae)
fig
AbstractPlotting.save("axisentries.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](axisentries.svg)
#
# # Generating `AxisEntries` objects
#
# Generating `AxisEntries` objects by hand is extremely laborious. SplitApplyPlot provides
# a simple way to generate them from data.

using RDatasets
mpg = RDatasets.dataset("ggplot2", "mpg")
resolution = (600, 600)
fig = Figure(; resolution)
AxisEntriess(Scatter, fig, mpg, (color=:Cyl,), arguments(:Displ, :Cty))

# `layout_x` and `layout_y` can be used to return a less trivial grid of axis plots.
resolution = (1200, 1200)
fig = Figure(; resolution)
ap = AxisEntriess(
    Scatter,
    fig,
    mpg,
    (color=:Cyl, layout_x=:Drv, layout_y=:Fl),
    arguments(:Displ, :Cty)
)

# The result can then be plotted as follows:
foreach(plot!, skipmissing(ap)) # some combination of facets may be missing
fig
AbstractPlotting.save("axisentries_grid.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](axisentries_grid.svg)
#
# The future can then be further cleaned up by working with the matrix of axes:

hideinnerdecorations!(ap)
fig
AbstractPlotting.save("axisentries_grid_clean.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](axisentries_grid_clean.svg)

