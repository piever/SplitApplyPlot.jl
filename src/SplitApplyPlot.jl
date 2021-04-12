module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting
using AbstractPlotting: PlotFunc

export hideinnerdecorations!
export arguments, Entry, AxisEntries, axes_grid

include("arguments.jl")
include("entries.jl")
include("utils.jl")

end
