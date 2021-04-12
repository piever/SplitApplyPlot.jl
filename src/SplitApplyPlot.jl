module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting
using AbstractPlotting: PlotFunc

export draw, draw!, mapping, hideinnerdecorations!
export arguments, axisplots, AxisPlot, Trace, DiscreteScale, ContinuousScale

include("arguments.jl")
include("axisplot.jl")
include("entries.jl")
include("utils.jl")

end
