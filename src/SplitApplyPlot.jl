module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting
using AbstractPlotting: PlotFunc
using IntervalSets

export draw, draw!, mapping, hideinnerdecorations!
export arguments, axisplots, AxisPlot, Trace, DiscreteScale, ContinuousScale
export ..

include("axisplot.jl")
include("scales.jl")
include("utils.jl")
include("draw.jl")

end
