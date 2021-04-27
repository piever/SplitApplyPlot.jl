# # Statistical plots

using SplitApplyPlot, CairoMakie, PalmerPenguins, DataFrames

penguins = dropmissing(DataFrame(PalmerPenguins.load()))

data(penguins) *
    mapping(:bill_length_mm, :bill_depth_mm, col=:sex) *
    visual(QQPlot, qqline=:fit) |> draw
