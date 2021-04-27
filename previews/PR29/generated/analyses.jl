# # Analyses
#
# ## Histogram

using SplitApplyPlot, CairoMakie

df = (x=randn(1000), y=randn(1000), z=rand(["a", "b", "c"], 1000))
specs = data(df) * mapping(:x, layout=:z) * histogram(bins=range(-2, 2, length=15)) * visual()
draw(specs)
AbstractPlotting.save("hist.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](hist.svg)
#

data(df) * mapping(:x, :y, layout=:z) * histogram(bins=15) |> draw
AbstractPlotting.save("hist2D.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](hist2D.svg)
#

# ## Density

using SplitApplyPlot, CairoMakie

df = (x=randn(1000), y=randn(1000), z=rand(["a", "b", "c"], 1000))
data(df) * mapping(:x, layout=:z) * SplitApplyPlot.density() |> draw
AbstractPlotting.save("density.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](density.svg)
#

data(df) * mapping(:x, :y, layout=:z) * SplitApplyPlot.density(npoints=20) |> draw
AbstractPlotting.save("density2D.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](density2D.svg)
#

# ## Linear

using SplitApplyPlot, CairoMakie

df = (x=randn(30), y=randn(30), z=rand(["a", "b", "c"], 30))
specs = data(df) * mapping(:x, :y, color=:z) * (linear() + visual(Scatter))
draw(specs, axis=(; limits=(-2, 2, -2, 2)))
AbstractPlotting.save("linearanalysis.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](linearanalysis.svg)
#