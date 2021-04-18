# # Entries and transformations
#
# Entries can be transformed and accumulated as follows:
#

using RDatasets, SplitApplyPlot, CairoMakie
mpg = RDatasets.dataset("ggplot2", "mpg")
resolution = (600, 600)
fig = Figure(; resolution)
e = Entries()
e(
    Visual(linewidth=10) ∘ Linear(),
    mpg,
    :Displ => automatic => "Displacement",
    :Cty => automatic => "City miles",
)
e(
    Visual(Scatter),
    mpg,
    :Displ => automatic => "Displacement",
    :Cty => automatic => "City miles",
    color=:Cyl => categoricalscale => "Cylinders",
)
ag = plot!(fig, e)
display(fig)
AbstractPlotting.save("entries.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](entries.svg)
#