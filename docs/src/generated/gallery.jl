# # Example gallery
#
# Semi-curated collection of examples.
#
# ## Lines and markers
#

using SplitApplyPlot, CairoMakie

df = (x=rand(100), y=rand(100))
fig = Figure()
specs = data(df) * mapping(:x, :y)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("simplescatter.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](simplescatter.svg)
#

x = range(-π, π, length=100)
y = sin.(x)
df = (; x, y)
fig = Figure()
specs = data(df) * mapping(:x, :y) * visual(Lines)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("simplelines.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](simplelines.svg)
#

x = range(-π, π, length=100)
y = sin.(x)
df = (; x, y)
fig = Figure()
specs = data(df) * mapping(:x, :y) * (visual(Scatter) + visual(Lines))
plot!(fig, specs)
display(fig)
AbstractPlotting.save("simplescatterlines1.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](simplescatterlines1.svg)
#
x = range(-π, π, length=100)
y = sin.(x)
df1 = (; x, y)
df2 = (x = rand(10), y = rand(10))
fig = Figure()
m = mapping(:x, :y)
geoms = data(df) * visual(Lines) + data(df2) * visual(Scatter)
plot!(fig, m * geoms)
display(fig)
AbstractPlotting.save("simplescatterlines2.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](simplescatterlines2.svg)
#
# ## Faceting
#
# Still needs to automatically do things to axes, decorate, etc.

df = (x=rand(100), y=rand(100), i=rand(["a", "b", "c"], 100), j=rand(["d", "e", "f"], 100))
fig = Figure()
specs = data(df) * mapping(:x, :y, layout_x=:i, layout_y=:j)
ag = plot!(fig, specs)
hideinnerdecorations!(ag)
linkaxes!(ag...)
display(fig)
AbstractPlotting.save("facetscatter.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](facetscatter.svg)
#

df = (x=rand(100), y=rand(100), l=rand(["a", "b", "c", "d", "e", "f"], 100))
specs = data(df) * mapping(:x, :y, layout=:l) # FIXME: does not work...
"Not yet implemented" #hide

#

df1 = (x=rand(100), y=rand(100), i=rand(["a", "b", "c"], 100), j=rand(["d", "e", "f"], 100))
df2 = (x=[0, 1], y=[0.5, 0.5], i=fill("a", 2), j=fill("e", 2)) # FIXME: do we need a smarter way to pass layout?
fig = Figure()
m = mapping(:x, :y, layout_x=:i, layout_y=:j)
geoms = data(df1) * visual(Scatter) + data(df2) * visual(Lines)
ag = plot!(fig, m * geoms)
hideinnerdecorations!(ag)
linkaxes!(ag...)
display(fig)
AbstractPlotting.save("facetscatterlines.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](facetscatterlines.svg)
#