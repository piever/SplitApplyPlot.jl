using RDatasets: dataset
using SplitApplyPlot, CairoMakie
mpg = dataset("ggplot2", "mpg");
mpg.IsAudi = mpg.Manufacturer .== "audi"

data(mpg) *
    mapping(:Displ, :Hwy, col=:IsAudi => nonnumeric) *
    visual(QQPlot, qqline=:fit) |> draw