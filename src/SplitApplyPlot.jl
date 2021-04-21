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
import FileIO

export hideinnerdecorations!, deleteemptyaxes!
export arguments, Entry, Entries, AxisEntries
export renamer, nonnumeric
export density, linear, visual, data, mapping
export facet!

include("arguments.jl")
include("scales.jl")
include("entries.jl")
include("utils.jl")
include("facet.jl")
include("data.jl")
include("helpers.jl")
include("algebra/layer.jl")
include("algebra/layers.jl")
include("algebra/consume.jl")
include("transformations/grouping.jl")
include("transformations/visual.jl")
# include("transformations/linear.jl")
# include("transformations/density.jl")

end
