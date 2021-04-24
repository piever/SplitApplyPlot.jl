module SplitApplyPlot

using Tables: rows, columns, getcolumn, columnnames
using StructArrays: components, GroupPerm, StructArray
using Colors: RGB
using AbstractPlotting
using AbstractPlotting: automatic, Automatic, PlotFunc
import AbstractPlotting.MakieLayout: hidexdecorations!,
                                     hideydecorations!,
                                     hidedecorations!,
                                     linkaxes!,
                                     linkxaxes!,
                                     linkyaxes!
using PooledArrays: PooledArray
using KernelDensity: kde, pdf
using StatsBase: fit, histrange, Histogram, normalize, weights, AbstractWeights, sturges
using DataAPI: refarray
import FileIO

export hideinnerdecorations!, deleteemptyaxes!
export arguments, Entry, Entries, AxisEntries
export renamer, nonnumeric
export density, histogram, linear, visual, data, dims, mapping
export draw, draw!
export facet!

include("arguments.jl")
include("scales.jl")
include("entries.jl")
include("utils.jl")
include("facet.jl")
include("helpers.jl")
include("algebra/layer.jl")
include("algebra/layers.jl")
include("algebra/processing.jl")
include("transformations/grouping.jl")
include("transformations/visual.jl")
include("transformations/linear.jl")
include("transformations/density.jl")
include("transformations/histogram.jl")

end
