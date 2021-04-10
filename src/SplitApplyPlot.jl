module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, StructArray
using AbstractPlotting
using IntervalSets

export draw, draw!, mapping, hideinnerdecorations!
export arguments, axisplots, AxisPlot, DiscreteScale, ContinuousScale
export ..

include("utils.jl")
include("scales.jl")
include("axisplot.jl")
include("draw.jl")

end
