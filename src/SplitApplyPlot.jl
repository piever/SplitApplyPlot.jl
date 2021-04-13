module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using OrderedCollections: LittleDict
using AbstractPlotting
using AbstractPlotting: PlotFunc

export hideinnerdecorations!
export arguments, Entry, AxisEntries
export LittleDict

include("arguments.jl")
include("entries.jl")
include("utils.jl")

end
