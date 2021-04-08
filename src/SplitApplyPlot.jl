module SplitApplyPlot

using Tables: Tables
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting

export draw, Group, Mapping

include("utils.jl")
include("grouping.jl")

end
