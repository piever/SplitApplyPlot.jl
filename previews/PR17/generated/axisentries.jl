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
N = 11
rg = range(1, 2, length=N)
ae = AxisEntries(
    Axis(fig[1, 1]),
    [
        Entry(
            Scatter,
            arguments(rg, cosh.(rg), color=1:N, marker=fill("b", N));
            markersize = 15
        ),
        Entry(
            Scatter,
            arguments(rg, sinh.(rg), color=1:N, marker=fill("c", N));
            markersize = 15
        ),
    ],
    arguments("x", "y", color="identity", marker="function"), #labels
    arguments(
        identity,
        log10,
        color=identity,
        marker=LittleDict("a" => :circle, "b" => :utriangle, "c" => :dtriangle), #scales
    ),
)
plot!(ae)
display(fig)
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
ag = splitapplyplot!(
    Scatter,
    fig,
    mpg,
    :Displ => automatic => "Displacement",
    :Cty => automatic => "City miles",
    color=:Cyl => categoricalscale => "Cylinders",
)

# This operation returns a grid of `AxisEntries` and plots them to the original figure:

display(fig)
AbstractPlotting.save("splitapplyplot.svg", fig); nothing #hide

# ![](splitapplyplot.svg)

# `layout_x` and `layout_y` can be used to return a less trivial grid of axis plots.
resolution = (1200, 1200)
fig = Figure(; resolution)
ag = splitapplyplot!(
    Scatter,
    fig,
    mpg,
    :Displ => automatic => "Displacement",
    :Cty => automatic => "City miles",
    color=:Cyl => categoricalscale => "Cylinders",
    layout_x=:Drv => categoricalscale => "Drive train",
    layout_y=:Fl => categoricalscale => "Fuel type",
)

# The figure looks as follows:

display(fig)
AbstractPlotting.save("splitapplyplot_grid.svg", fig); nothing #hide

# ![](splitapplyplot_grid.svg)
#
# The figure can then be further cleaned up by working with the matrix of axes:

hideinnerdecorations!(ag)
linkaxes!(ag...)
display(fig)
AbstractPlotting.save("splitapplyplot_grid_clean.svg", fig); nothing #hide

# ![](splitapplyplot_grid_clean.svg)