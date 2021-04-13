module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using OrderedCollections: LittleDict
using AbstractPlotting
using Colors: RGB
using AbstractPlotting: automatic, PlotFunc

export hideinnerdecorations!
export arguments, Entry, AxisEntries
export LittleDict

include("arguments.jl")
include("scales.jl")
include("entries.jl")
include("utils.jl")

end
