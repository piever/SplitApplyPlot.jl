# # Statistical plots

using SplitApplyPlot, CairoMakie, CSV, HTTP, DataFrames

url = "https://cdn.jsdelivr.net/gh/allisonhorst/palmerpenguins@433439c8b013eff3d36c847bb7a27fa0d7e353d8/inst/extdata/penguins.csv"
penguins = dropmissing(CSV.read(HTTP.get(url).body, DataFrame, missingstring="NA"))

data(penguins) *
    mapping(:bill_length_mm, :bill_depth_mm, col=:sex) *
    visual(QQPlot, qqline=:fit) |> draw
