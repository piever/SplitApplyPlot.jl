var documenterSearchIndex = {"docs":
[{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"EditURL = \"https://github.com/piever/SplitApplyPlot.jl/blob/master/docs/src/generated/entries.jl\"","category":"page"},{"location":"generated/entries/#AxisEntries","page":"AxisEntries","title":"AxisEntries","text":"","category":"section"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"The key ingredient for data representations are AxisEntries.","category":"page"},{"location":"generated/entries/#The-AxisEntries-type","page":"AxisEntries","title":"The AxisEntries type","text":"","category":"section"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"An AxisEntries object is made of four components:","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"axis,\nentries.","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"using SplitApplyPlot, CairoMakie\nresolution = (600, 600)\nfig = Figure(; resolution)\nN = 11\nrg = range(1, 2, length=N)\nae = AxisEntries(\n    Axis(fig[1, 1]),\n    [\n        Entry(\n            Scatter,\n            arguments(rg, cosh.(rg), color=1:N, marker=fill(\"b\", N));\n            markersize = 15\n        ),\n        Entry(\n            Scatter,\n            arguments(rg, sinh.(rg), color=1:N, marker=fill(\"c\", N));\n            markersize = 15\n        ),\n    ],\n    arguments(\"x\", \"y\", color=\"identity\", marker=\"function\"), #labels\n    arguments(\n        identity,\n        log10,\n        color=identity,\n        marker=LittleDict(\"a\" => :circle, \"b\" => :utriangle, \"c\" => :dtriangle), #scales\n    ),\n)\nplot!(ae)\ndisplay(fig)\nAbstractPlotting.save(\"axisentries.svg\", AbstractPlotting.current_scene()); nothing #hide","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"(Image: )","category":"page"},{"location":"generated/entries/#Generating-AxisEntries-objects","page":"AxisEntries","title":"Generating AxisEntries objects","text":"","category":"section"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"Generating AxisEntries objects by hand is extremely laborious. SplitApplyPlot provides a simple way to generate them from data.","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"using RDatasets\nmpg = RDatasets.dataset(\"ggplot2\", \"mpg\")\nresolution = (600, 600)\nfig = Figure(; resolution)\nag = splitapplyplot!(\n    Scatter,\n    fig,\n    mpg,\n    :Displ => automatic => \"Displacement\",\n    :Cty => automatic => \"City miles\",\n    color=:Cyl => categoricalscale => \"Cylinders\",\n)","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"This operation returns a grid of AxisEntries and plots them to the original figure:","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"display(fig)\nAbstractPlotting.save(\"splitapplyplot.svg\", fig); nothing #hide","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"(Image: )","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"layout_x and layout_y can be used to return a less trivial grid of axis plots.","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"resolution = (1200, 1200)\nfig = Figure(; resolution)\nag = splitapplyplot!(\n    Scatter,\n    fig,\n    mpg,\n    :Displ => automatic => \"Displacement\",\n    :Cty => automatic => \"City miles\",\n    color=:Cyl => categoricalscale => \"Cylinders\",\n    layout_x=:Drv => categoricalscale => \"Drive train\",\n    layout_y=:Fl => categoricalscale => \"Fuel type\",\n)","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"The figure looks as follows:","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"display(fig)\nAbstractPlotting.save(\"splitapplyplot_grid.svg\", fig); nothing #hide","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"(Image: )","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"The figure can then be further cleaned up by working with the matrix of axes:","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"hideinnerdecorations!(ag)\nlinkaxes!(ag...)\ndisplay(fig)\nAbstractPlotting.save(\"splitapplyplot_grid_clean.svg\", fig); nothing #hide","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"(Image: )","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"","category":"page"},{"location":"generated/entries/","page":"AxisEntries","title":"AxisEntries","text":"This page was generated using Literate.jl.","category":"page"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"CurrentModule = SplitApplyPlot","category":"page"},{"location":"#SplitApplyPlot","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"","category":"section"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"Documentation for SplitApplyPlot.","category":"page"},{"location":"API/#API","page":"API","title":"API","text":"","category":"section"},{"location":"API/","page":"API","title":"API","text":"","category":"page"},{"location":"API/","page":"API","title":"API","text":"Modules = [SplitApplyPlot]","category":"page"},{"location":"API/#SplitApplyPlot.AxisEntries","page":"API","title":"SplitApplyPlot.AxisEntries","text":"AxisEntries(axis::Union{Axis, Nothing}, entries::Vector{Entry}, labels, scales)\n\nDefine all ingredients to make plots on an axis. Each scale can be either an ordered dictionary (for discrete collections), such as LittleDict(\"a\" => \"red\", \"b\" => \"blue\"), or a pair giving an interval and a function, such as (0, 10) => log10. Other scales may be supported in the future.\n\n\n\n\n\n","category":"type"},{"location":"API/#SplitApplyPlot.Entries-Tuple{Any}","page":"API","title":"SplitApplyPlot.Entries","text":"Entries(iterator)\n\nReturn a unique Entries object from an iterator of Entries. Scales and labels are combined.\n\n\n\n\n\n","category":"method"},{"location":"API/#SplitApplyPlot.iscontinuous-Tuple{AbstractVector{T} where T}","page":"API","title":"SplitApplyPlot.iscontinuous","text":"iscontinuous(v::AbstractVector)\n\nDetermine whether v should be treated as a continuous or categorical vector.\n\n\n\n\n\n","category":"method"}]
}
