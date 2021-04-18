using RDatasets, SplitApplyPlot, CairoMakie
mpg = RDatasets.dataset("ggplot2", "mpg")
resolution = (600, 600)
fig = Figure(; resolution)
ag = splitapplyplot!(
    Linear(),
    fig,
    mpg,
    :Displ => automatic => "Displacement",
    :Cty => automatic => "City miles",
    color=:Cyl => categoricalscale => "Cylinders",
)
