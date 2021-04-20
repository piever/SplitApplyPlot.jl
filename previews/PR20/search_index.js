var documenterSearchIndex = {"docs":
[{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"EditURL = \"https://github.com/piever/SplitApplyPlot.jl/blob/master/docs/src/generated/gallery.jl\"","category":"page"},{"location":"generated/gallery/#Example-gallery","page":"Example gallery","title":"Example gallery","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"Semi-curated collection of examples.","category":"page"},{"location":"generated/gallery/#Lines-and-markers","page":"Example gallery","title":"Lines and markers","text":"","category":"section"},{"location":"generated/gallery/#A-simple-scatter-plot","page":"Example gallery","title":"A simple scatter plot","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"using SplitApplyPlot, CairoMakie\n\ndf = (x=rand(100), y=rand(100))\nfig = Figure()\nspecs = data(df) * mapping(:x, :y)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"simplescatter.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#A-simple-lines-plot","page":"Example gallery","title":"A simple lines plot","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"x = range(-π, π, length=100)\ny = sin.(x)\ndf = (; x, y)\nfig = Figure()\nspecs = data(df) * mapping(:x, :y) * visual(Lines)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"simplelines.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Lines-and-scatter-combined-plot","page":"Example gallery","title":"Lines and scatter combined plot","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"x = range(-π, π, length=100)\ny = sin.(x)\ndf = (; x, y)\nfig = Figure()\nspecs = data(df) * mapping(:x, :y) * (visual(Scatter) + visual(Lines))\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"simplescatterlines1.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"x = range(-π, π, length=100)\ny = sin.(x)\ndf1 = (; x, y)\ndf2 = (x=rand(10), y=rand(10))\nfig = Figure()\nm = mapping(:x, :y)\ngeoms = data(df) * visual(Lines) + data(df2) * visual(Scatter)\nplot!(fig, m * geoms)\ndisplay(fig)\nAbstractPlotting.save(\"simplescatterlines2.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Linear-regression-on-a-scatter-plot","page":"Example gallery","title":"Linear regression on a scatter plot","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=rand(100), y=rand(100), z=rand(100))\nfig = Figure()\nm = data(df) * mapping(:x, :y)\ngeoms = linear() + visual(Scatter) * mapping(color=:z)\nplot!(fig, m * geoms)\ndisplay(fig)\nAbstractPlotting.save(\"linefit.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Faceting","page":"Example gallery","title":"Faceting","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"Still needs to automatically do things to axes, decorate, etc.","category":"page"},{"location":"generated/gallery/#Facet-grid","page":"Example gallery","title":"Facet grid","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=rand(100), y=rand(100), i=rand([\"a\", \"b\", \"c\"], 100), j=rand([\"d\", \"e\", \"f\"], 100))\nfig = Figure()\nspecs = data(df) * mapping(:x, :y, col=:i, row=:j)\nag = plot!(fig, specs)\nhideinnerdecorations!(ag)\nlinkaxes!(ag...)\ndisplay(fig)\nAbstractPlotting.save(\"facetscatter.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/#Facet-wrap","page":"Example gallery","title":"Facet wrap","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=rand(100), y=rand(100), l=rand([\"a\", \"b\", \"c\", \"d\", \"e\", \"f\"], 100))\nfig = Figure()\nspecs = data(df) * mapping(:x, :y, layout=:l=>(palette=t -> fldmod1(t, 2),))\nag = plot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"facetwrapscatter.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Embedding-facets","page":"Example gallery","title":"Embedding facets","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"All SplitApplyPlot plots can be inserted in any figure position, where the rest of the figure is managed by vanilla Makie. For example","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=rand(100), y=rand(100), i=rand([\"a\", \"b\", \"c\"], 100), j=rand([\"d\", \"e\", \"f\"], 100))\nresolution = (1200, 600)\nfig = Figure(; resolution)\nax = Axis(fig[1, 1])\ntext!(ax, \"Some plot\")\nspecs = data(df) * mapping(:x, :y, col=:i, row=:j)\nag = plot!(fig[1, 2:3], specs)\nhideinnerdecorations!(ag)\nlinkaxes!(ag...)\ndisplay(fig)\nAbstractPlotting.save(\"nestedfacet.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Adding-traces-to-only-some-subplots","page":"Example gallery","title":"Adding traces to only some subplots","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df1 = (x=rand(100), y=rand(100), i=rand([\"a\", \"b\", \"c\"], 100), j=rand([\"d\", \"e\", \"f\"], 100))\ndf2 = (x=[0, 1], y=[0.5, 0.5], i=fill(\"a\", 2), j=fill(\"e\", 2))\nfig = Figure()\nm = mapping(:x, :y, col=:i, row=:j)\ngeoms = data(df1) * visual(Scatter) + data(df2) * visual(Lines)\nag = plot!(fig, m * geoms)\nhideinnerdecorations!(ag)\nlinkaxes!(ag...)\ndisplay(fig)\nAbstractPlotting.save(\"facetscatterlines.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Statistical-analyses","page":"Example gallery","title":"Statistical analyses","text":"","category":"section"},{"location":"generated/gallery/#Density-plot","page":"Example gallery","title":"Density plot","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=randn(1000), c=rand([\"a\", \"b\"], 1000))\nfig = Figure()\nspecs = data(df) * mapping(:x, color=:c) * SplitApplyPlot.density(bandwidth=0.5)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"density.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"Using the recipe from AbstractPlotting also works (let us try to figure out whether we need an analysis or not).","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=randn(1000), c=rand([\"a\", \"b\"], 1000))\nfig = Figure()\nspecs = data(df) * mapping(:x, col=:c) * visual(AbstractPlotting.Density)\nag = plot!(fig, specs)\nhideinnerdecorations!(ag)\nlinkaxes!(ag...)\ndisplay(fig)\nAbstractPlotting.save(\"densityvisual.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=randn(1000), c=rand([\"a\", \"b\"], 1000))\nfig = Figure()\nspecs = data(df) * mapping(:x, color=:c) * SplitApplyPlot.density(bandwidth=0.5) *\n    visual(orientation=:vertical)\n\"Not yet supported\" # hide","category":"page"},{"location":"generated/gallery/#Discrete-scales","page":"Example gallery","title":"Discrete scales","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"By default categorical ticks, as well as names from legend entries, are taken from the value of the variable converted to a string. Scales can be equipped with labels to overwrite that","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=rand([\"a\", \"b\", \"c\"], 100), y=rand(100))\nfig = Figure()\nspecs = data(df) * mapping(:x, :y) * visual(BoxPlot)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"boxplot.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"df = (x=rand([\"a\", \"b\", \"c\"], 100), y=rand(100))\nfig = Figure()\nxscale = (labels=[\"label1\", \"label2\", \"label3\"],)\nspecs = data(df) *\n    mapping(\n        :x => xscale,\n        :y\n    ) * visual(BoxPlot)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"relabel.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"The order can also be changed by tweaking the scale","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"fig = Figure()\nxscale = (uniquevalues=[\"b\", \"a\", \"c\"],)\nspecs = data(df) *\n    mapping(\n        :x => xscale,\n        :y\n    ) * visual(BoxPlot)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"reorder.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Continuous-scales","page":"Example gallery","title":"Continuous scales","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"fig = Figure()\nx = 1:100\ny = @. sqrt(x) + 20x + 100 # FIXME: things closer to zero fail spuriosly and ylims are \"off\"\ndf = (; x, y)\nspecs = data(df) *\n    mapping(\n        :x,\n        :y => log => \"√x + 20x + 100 (log scale)\",\n    ) * visual(Lines)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"logscale.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/#Custom-scales","page":"Example gallery","title":"Custom scales","text":"","category":"section"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"Sometimes, there is no default palettes for a specific attribute. In that case, the user can pass their own.","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"using Colors\nfig = Figure()\nx=repeat(1:20, inner=20)\ny=repeat(1:20, outer=20)\nu=cos.(x)\nv=sin.(y)\nc=rand(Bool, length(x))\nd=rand(Bool, length(x))\ndf = (; x, y, u, v, c, d)\ncolors = [colorant\"#E24A33\", colorant\"#348ABD\"]\nheads = ['▲', '●']\nspecs = data(df) *\n    mapping(:x, :y, :u, :v) *\n    mapping(arrowhead=:c=>(palette=heads,)) *\n    mapping(arrowcolor=:d=>(palette=colors,)) *\n    visual(Arrows, arrowsize=10, lengthscale=0.3)\nplot!(fig, specs)\ndisplay(fig)\nAbstractPlotting.save(\"arrows.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"(Image: )","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"","category":"page"},{"location":"generated/gallery/","page":"Example gallery","title":"Example gallery","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"EditURL = \"https://github.com/piever/SplitApplyPlot.jl/blob/master/docs/src/generated/entries.jl\"","category":"page"},{"location":"generated/entries/#Entries","page":"Entries","title":"Entries","text":"","category":"section"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"The key ingredient for data representations are AxisEntries.","category":"page"},{"location":"generated/entries/#The-AxisEntries-type","page":"Entries","title":"The AxisEntries type","text":"","category":"section"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"An AxisEntries object is made of four components:","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"axis,\nentries.","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"using SplitApplyPlot, CairoMakie\nresolution = (600, 600)\nfig = Figure(; resolution)\nN = 11\nrg = range(1, 2, length=N)\nae = AxisEntries(\n    Axis(fig[1, 1]),\n    [\n        Entry(\n            Scatter,\n            arguments(rg, cosh.(rg), color=1:N, marker=fill(\"b\", N));\n            markersize = 15\n        ),\n        Entry(\n            Scatter,\n            arguments(rg, sinh.(rg), color=1:N, marker=fill(\"c\", N));\n            markersize = 15\n        ),\n    ],\n    arguments(\"x\", \"y\", color=\"identity\", marker=\"function\"), #labels\n    arguments(\n        identity,\n        log10,\n        color=identity,\n        marker=CategoricalScale([\"a\", \"b\", \"c\"], [:circle, :utriangle, :dtriangle]), #scales\n    ),\n)\nplot!(ae)\ndisplay(fig)\nAbstractPlotting.save(\"axisentries.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"(Image: )","category":"page"},{"location":"generated/entries/#Transforming-and-accumulating-Entries","page":"Entries","title":"Transforming and accumulating Entries","text":"","category":"section"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"Generating AxisEntries objects by hand is extremely laborious. SplitApplyPlot provides a simple way to generate them from data.","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"using RDatasets\nmpg = RDatasets.dataset(\"ggplot2\", \"mpg\")\nentries = Entries()\nentries(\n    Visual(Scatter),\n    mpg,\n    :Displ => \"Displacement\",\n    :Cty => \"City miles\",\n    color=:Cyl => categoricalscale => \"Cylinders\",\n)\nentries(\n    Visual(linewidth=5) ∘ Linear(),\n    mpg,\n    :Displ => \"Displacement\",\n    :Cty => \"City miles\",\n    color=:Cyl => categoricalscale => \"Cylinders\",\n)\nresolution = (600, 600)\nfig = Figure(; resolution)\nag = plot!(fig, entries)","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"This operation returns a grid of AxisEntries and plots them to the original figure:","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"display(fig)\nAbstractPlotting.save(\"splitapplyplot.svg\", fig); nothing #hide","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"(Image: )","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"col and row can be used to return a less trivial grid of axis plots.","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"resolution = (1200, 1200)\nfig = Figure(; resolution)\nentries = Entries()\nentries(\n    Visual(Scatter),\n    mpg,\n    :Displ => \"Displacement\",\n    :Cty => \"City miles\",\n    color=:Cyl => categoricalscale => \"Cylinders\",\n    col=:Fl => categoricalscale => \"Fuel type\",\n    row=:Drv => categoricalscale => \"Drive train\"\n)\nentries(\n    Visual(linewidth=5) ∘ Linear(),\n    mpg,\n    :Displ => \"Displacement\",\n    :Cty => \"City miles\",\n    color=:Cyl => categoricalscale => \"Cylinders\",\n)\nag = plot!(fig, entries)","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"The figure looks as follows:","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"display(fig)\nAbstractPlotting.save(\"splitapplyplot_grid.svg\", fig); nothing #hide","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"(Image: )","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"The figure can then be further cleaned up by working with the matrix of axes:","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"hideinnerdecorations!(ag)\nlinkaxes!(ag...)\ndisplay(fig)\nAbstractPlotting.save(\"splitapplyplot_grid_clean.svg\", fig); nothing #hide","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"(Image: )","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"As there is a lot of repetition within the entries that are added to the plot, the standard interface to generate these entries is an algebra that allows us to factor out the common part.","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"","category":"page"},{"location":"generated/entries/","page":"Entries","title":"Entries","text":"This page was generated using Literate.jl.","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"EditURL = \"https://github.com/piever/SplitApplyPlot.jl/blob/master/docs/src/generated/tutorial.jl\"","category":"page"},{"location":"generated/tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"Here we will see what are the basic building blocks of SplitApplyPlot, and how to combine them to create complex plots based on tables or other formats.","category":"page"},{"location":"generated/tutorial/#Basic-building-blocks","page":"Tutorial","title":"Basic building blocks","text":"","category":"section"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"The most important functions are mapping, and visual. mapping determines the mappings from data to plot. Its positional arguments correspond to the x, y or z axes of the plot, whereas the keyword arguments correspond to plot attributes that can vary continuously or discretely, such as color or markersize. Variables in mapping are split according to the categorical attributes in it, and then converted to plot attributes using a default palette. visual can be used to give data-independent visual information about the plot (plotting function or attributes).","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"Finally, data determines what is the dataset to be used.","category":"page"},{"location":"generated/tutorial/#Operations","page":"Tutorial","title":"Operations","text":"","category":"section"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"The outputs of mapping, visual, and data can be combined with + or *, to generate the specification of a complex plot.","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"The operation + is used to create separate layers. a + b has as many layers as la + lb, where la and lb are the number of layers in a and b respectively.","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"The operation a * b create la * lb layers, where la and lb are the number of layers in a and b respectively. Each layer of a * b contains the combined information of the corresponding layer in a and the corresponding layer in b. In simple cases, however, both a and b will only have one layer, and a * b simply combines the information.","category":"page"},{"location":"generated/tutorial/#Working-with-tables","page":"Tutorial","title":"Working with tables","text":"","category":"section"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"using RDatasets: dataset\nusing SplitApplyPlot, CairoMakie\nmpg = dataset(\"ggplot2\", \"mpg\");\ncols = mapping(:Displ => \"Displacement\", :Hwy => \"Highway miles\");\ngrp = mapping(color = :Cyl => categoricalscale => \"Cylinders\");\nscat = visual(Scatter)\npipeline = cols * scat\nfig = Figure()\nplot!(fig, data(mpg) * pipeline)\ndisplay(fig)\nAbstractPlotting.save(\"scatter.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"(Image: )","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"Now let's simply add grp to the pipeline to color according to :Cyl.","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"fig = Figure()\nplot!(fig, data(mpg) * grp * pipeline)\ndisplay(fig)\nAbstractPlotting.save(\"grouped_scatter.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"(Image: ) Traces can be added together with +.","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"pipenew = cols * (scat + linear())\nfig = Figure()\nplot!(fig, data(mpg) * pipenew)\ndisplay(fig)\nAbstractPlotting.save(\"linear.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"(Image: ) We can put grouping in the pipeline (we get a warning because of a degenerate group).","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"fig = Figure()\nplot!(fig, data(mpg) * grp * pipenew)\ndisplay(fig)\nAbstractPlotting.save(\"grouped_linear.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"(Image: ) This is a more complex example, where we split the scatter plot, but do the linear regression with all the data.","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"different_grouping = grp * scat + linear()\nfig = Figure()\nplot!(fig, data(mpg) * cols * different_grouping)\ndisplay(fig)\nAbstractPlotting.save(\"semi_grouped.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"(Image: )","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"","category":"page"},{"location":"generated/tutorial/","page":"Tutorial","title":"Tutorial","text":"This page was generated using Literate.jl.","category":"page"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"CurrentModule = SplitApplyPlot","category":"page"},{"location":"#SplitApplyPlot","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"","category":"section"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"Documentation for SplitApplyPlot.","category":"page"},{"location":"API/#API","page":"API","title":"API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"","category":"page"},{"location":"API/","page":"API","title":"API","text":"Modules = [SplitApplyPlot]","category":"page"},{"location":"API/#SplitApplyPlot.AxisEntries","page":"API","title":"SplitApplyPlot.AxisEntries","text":"AxisEntries(axis::Union{Axis, Nothing}, entries::Vector{Entry}, labels, scales)\n\nDefine all ingredients to make plots on an axis. Each scale can be either a CategoricalScale (for discrete collections), such as CategoricalScale([\"a\", \"b\"], [\"red\", \"blue\"]), or a function, such as log10. Other scales may be supported in the future.\n\n\n\n\n\n","category":"type"},{"location":"API/#SplitApplyPlot.Entries-Tuple{Any}","page":"API","title":"SplitApplyPlot.Entries","text":"Entries(iterator)\n\nReturn a unique Entries object from an iterator of Entries. Scales and labels are combined.\n\n\n\n\n\n","category":"method"},{"location":"API/#SplitApplyPlot.iscontinuous-Tuple{AbstractVector{T} where T}","page":"API","title":"SplitApplyPlot.iscontinuous","text":"iscontinuous(v::AbstractVector)\n\nDetermine whether v should be treated as a continuous or categorical vector.\n\n\n\n\n\n","category":"method"}]
}
