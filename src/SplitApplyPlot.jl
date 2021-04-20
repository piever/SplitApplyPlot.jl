module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, GroupPerm, StructArray
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
using KernelDensity: kde
using DataAPI: refarray

export hideinnerdecorations!, deleteemptyaxes!
export arguments, Entry, Entries, AxisEntries
export categoricalscale, CategoricalScale, continuousscale, automatic
export Density, Linear, Visual
export density, linear, visual, data, mapping

include("arguments.jl")
include("scales.jl")
include("entries.jl")
include("data.jl")
include("utils.jl")
include("algebra/spec.jl")
include("algebra/speclist.jl")
include("transformations/grouping.jl")
include("transformations/visual.jl")
include("transformations/linear.jl")
include("transformations/density.jl")

end
