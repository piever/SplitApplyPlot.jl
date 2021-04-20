# # Example gallery
#
# Semi-curated collection of examples.
#
# ## Lines and markers
#
# ### A simple scatter plot

using SplitApplyPlot, CairoMakie

df = (x=rand(100), y=rand(100))
fig = Figure()
specs = data(df) * mapping(:x, :y)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("simplescatter.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](simplescatter.svg)
#
# ### A simple lines plot

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
# ### Lines and scatter combined plot

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
df2 = (x=rand(10), y=rand(10))
fig = Figure()
m = mapping(:x, :y)
geoms = data(df) * visual(Lines) + data(df2) * visual(Scatter)
plot!(fig, m * geoms)
display(fig)
AbstractPlotting.save("simplescatterlines2.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](simplescatterlines2.svg)
#
# ### Linear regression on a scatter plot
#
df = (x=rand(100), y=rand(100), z=rand(100))
fig = Figure()
m = data(df) * mapping(:x, :y)
geoms = linear() + visual(Scatter) * mapping(color=:z)
plot!(fig, m * geoms)
display(fig)
AbstractPlotting.save("linefit.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](linefit.svg)
#

# ## Faceting
#
# Still needs to automatically do things to axes, decorate, etc.
# ### Facet grid

df = (x=rand(100), y=rand(100), i=rand(["a", "b", "c"], 100), j=rand(["d", "e", "f"], 100))
fig = Figure()
specs = data(df) * mapping(:x, :y, col=:i, row=:j)
ag = plot!(fig, specs)
facet!(fig, ag)
display(fig)
AbstractPlotting.save("facetscatter.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](facetscatter.svg)
#
# ### Facet wrap

df = (x=rand(100), y=rand(100), l=rand(["a", "b", "c", "d", "e"], 100))
fig = Figure()
specs = data(df) * mapping(:x, :y, layout=:l)
ag = plot!(fig, specs)
SplitApplyPlot.facet!(fig, ag)
display(fig)
AbstractPlotting.save("facetwrapscatter.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](facetwrapscatter.svg)
#

# ### Embedding facets
#
# All SplitApplyPlot plots can be inserted in any figure position, where the rest
# of the figure is managed by vanilla Makie.
# For example

df = (x=rand(100), y=rand(100), i=rand(["a", "b", "c"], 100), j=rand(["d", "e", "f"], 100))
resolution = (1200, 600)
fig = Figure(; resolution)
ax = Axis(fig[1, 1])
text!(ax, "Some plot")
specs = data(df) * mapping(:x, :y, col=:i, row=:j)
subfig = fig[1, 2]
ag = plot!(subfig, specs)
facet!(subfig, ag)
for ae in ag
    Axis(ae).xticklabelrotation[] = π/2
end
display(fig)
AbstractPlotting.save("nestedfacet.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](nestedfacet.svg)

# ### Adding traces to only some subplots

df1 = (x=rand(100), y=rand(100), i=rand(["a", "b", "c"], 100), j=rand(["d", "e", "f"], 100))
df2 = (x=[0, 1], y=[0.5, 0.5], i=fill("a", 2), j=fill("e", 2))
fig = Figure()
m = mapping(:x, :y, col=:i, row=:j)
geoms = data(df1) * visual(Scatter) + data(df2) * visual(Lines)
ag = plot!(fig, m * geoms)
facet!(fig, ag)
display(fig)
AbstractPlotting.save("facetscatterlines.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](facetscatterlines.svg)
#
# ## Statistical analyses
#
# ### Density plot

df = (x=randn(1000), c=rand(["a", "b"], 1000))
fig = Figure()
specs = data(df) * mapping(:x, color=:c) * SplitApplyPlot.density(bandwidth=0.5)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("density.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](density.svg)
#
# Using the recipe from AbstractPlotting also works (let us try to figure out whether we need an analysis or not).

df = (x=randn(1000), c=rand(["a", "b"], 1000))
fig = Figure()
specs = data(df) * mapping(:x, col=:c) * visual(AbstractPlotting.Density)
ag = plot!(fig, specs)
facet!(fig, ag)
display(fig)
AbstractPlotting.save("densityvisual.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](densityvisual.svg)
#

df = (x=randn(1000), c=rand(["a", "b"], 1000))
fig = Figure()
specs = data(df) * mapping(:x, color=:c) * SplitApplyPlot.density(bandwidth=0.5) *
    visual(orientation=:vertical)
"Not yet supported" # hide

# ## Discrete scales
#
# By default categorical ticks, as well as names from legend entries, are taken from the 
# value of the variable converted to a string. Scales can be equipped with labels to
# overwrite that

df = (x=rand(["a", "b", "c"], 100), y=rand(100))
fig = Figure()
specs = data(df) * mapping(:x, :y) * visual(BoxPlot)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("boxplot.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](boxplot.svg)
#

df = (x=rand(["a", "b", "c"], 100), y=rand(100))
fig = Figure()
xscale = (labels=["label1", "label2", "label3"],)
specs = data(df) *
    mapping(
        :x => xscale,
        :y
    ) * visual(BoxPlot)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("relabel.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](relabel.svg)
#
# The order can also be changed by tweaking the scale
fig = Figure()
xscale = (uniquevalues=["b", "a", "c"],)
specs = data(df) *
    mapping(
        :x => xscale,
        :y
    ) * visual(BoxPlot)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("reorder.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](reorder.svg)
#
# ## Continuous scales

fig = Figure()
x = 1:100
y = @. sqrt(x) + 20x + 100 # FIXME: things closer to zero fail spuriosly and ylims are "off"
df = (; x, y)
specs = data(df) *
    mapping(
        :x,
        :y => log => "√x + 20x + 100 (log scale)",
    ) * visual(Lines)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("logscale.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](logscale.svg)
#
# ## Custom scales
#
# Sometimes, there is no default palettes for a specific attribute. In that
# case, the user can pass their own.

using Colors
fig = Figure()
x=repeat(1:20, inner=20)
y=repeat(1:20, outer=20)
u=cos.(x)
v=sin.(y)
c=rand(Bool, length(x))
d=rand(Bool, length(x))
df = (; x, y, u, v, c, d)
colors = [colorant"#E24A33", colorant"#348ABD"]
heads = ['▲', '●']
specs = data(df) *
    mapping(:x, :y, :u, :v) *
    mapping(arrowhead=:c=>(palette=heads,)) *
    mapping(arrowcolor=:d=>(palette=colors,)) *
    visual(Arrows, arrowsize=10, lengthscale=0.3)
plot!(fig, specs)
display(fig)
AbstractPlotting.save("arrows.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](arrows.svg)
#