module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting

export splitapplyplot

include("utils.jl")
include("grouping.jl")

end
