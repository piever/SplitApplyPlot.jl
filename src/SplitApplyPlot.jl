module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting

export draw, draw!, mapping, hideinnerdecorations!

include("utils.jl")
include("mapping.jl")
include("draw.jl")

end
