# # Analyses
#
# ## Histogram

using SplitApplyPlot, CairoMakie

df = (x=randn(100), y=randn(100), z=rand(["a", "b", "c"], 100))
data(df) * mapping(:x, layout=:z) * histogram(bins=5) * visual(x_gap=0) |> draw

data(df) * mapping(:x, :y, layout=:z) * histogram(bins=15) |> draw

# ## Density

using SplitApplyPlot, CairoMakie

df = (x=randn(1000), y=randn(1000), z=rand(["a", "b", "c"], 1000))
data(df) * mapping(:x, layout=:z) * SplitApplyPlot.density() |> draw

data(df) * mapping(:x, :y, layout=:z) * SplitApplyPlot.density(trim=true) |> draw

# ## Linear

using SplitApplyPlot, CairoMakie

df = (x=randn(30), y=randn(30), z=rand(["a", "b", "c"], 30))
specs = data(df) * mapping(:x, :y, color=:z) * (linear() + visual(Scatter))
draw(specs, axis=(; limits=(-2, 2, -2, 2)))