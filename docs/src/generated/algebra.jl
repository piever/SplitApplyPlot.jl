# # Algebra
#

using RDatasets, SplitApplyPlot, CairoMakie
mpg = RDatasets.dataset("ggplot2", "mpg")
resolution = (600, 600)
fig = Figure(; resolution)
cols = mapping(
    :Displ => automatic => "Displacement",
    :Cty => automatic => "City miles",
)
geoms = visual(linewidth=10) * linear() +
    visual(Scatter) * mapping(color=:Cyl => categoricalscale => "Cylinders")

plot!(fig, cols * geoms * data(mpg))
display(fig)

AbstractPlotting.save("regression.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](regression.svg)
#