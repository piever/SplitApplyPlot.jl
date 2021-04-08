module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting
using OrderedCollections: LittleDict

export draw

include("utils.jl")
include("grouping.jl")

end
