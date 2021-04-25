# # Analyses
#
# ## Histogram
#
# ```@docs
# histogram
# ```

using SplitApplyPlot, CairoMakie

df = (x=randn(1000), y=randn(1000), z=rand(["a", "b", "c"], 1000))
specs = data(df) * mapping(:x, layout=:z) * histogram(bins=range(-2, 2, length=15))
draw(specs)

#

specs = data(df) * mapping(:x, dodge=:z, color=:z) * histogram(bins=range(-2, 2, length=15))
draw(specs)

#

specs = data(df) * mapping(:x, stack=:z, color=:z) * histogram(bins=range(-2, 2, length=15))
draw(specs)

#

data(df) * mapping(:x, :y, layout=:z) * histogram(bins=15) |> draw

# ## Density
#
# ```@docs
# SplitApplyPlot.density
# ```

using SplitApplyPlot, CairoMakie

df = (x=randn(5000), y=randn(5000), z=rand(["a", "b", "c", "d"], 5000))
data(df) * mapping(:x, layout=:z) * SplitApplyPlot.density() |> draw

#

data(df) * mapping(:x, :y, layout=:z) * SplitApplyPlot.density(npoints=50) |> draw

#

specs = data(df) * mapping(:x, :y, layout=:z) *
    visual(Surface, colormap=:cividis) *
    SplitApplyPlot.density(npoints=50)
draw(specs, axis=(type=Axis3, zticks=0:0.1:0.2, limits=(nothing, nothing, (0, 0.2))))

# ## Frequency

df = (x=rand(["a", "b", "c"], 100), y=rand(["a", "b", "c"], 100), z=rand(["a", "b", "c"], 100))
specs = data(df) * mapping(:x, :y, layout=:z) * SplitApplyPlot.frequency()
draw(specs)

# ## Linear

using SplitApplyPlot, CairoMakie

df = (x=randn(30), y=randn(30), z=rand(["a", "b", "c"], 30))
specs = data(df) * mapping(:x, :y, color=:z) * (linear() + visual(Scatter))
draw(specs, axis=(; limits=(-2, 2, -2, 2)))

#