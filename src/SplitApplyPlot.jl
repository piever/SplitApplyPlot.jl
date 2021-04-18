module SplitApplyPlot

using Tables: columns, getcolumn
using StructArrays: uniquesorted, finduniquesorted, components, GroupPerm, StructArray
using OrderedCollections: LittleDict
using Colors: RGB
using AbstractPlotting
using AbstractPlotting: automatic, PlotFunc
import AbstractPlotting.MakieLayout: hidexdecorations!,
                                     hideydecorations!,
                                     hidedecorations!,
                                     linkaxes!,
                                     linkxaxes!,
                                     linkyaxes!
using PooledArrays: PooledArray
using DataAPI: refarray

export hideinnerdecorations!, deleteemptyaxes!
export arguments, Entry, Entries, AxisEntries
export splitapplyplot!
export categoricalscale, continuousscale, automatic
export Linear, Visual
export linear, visual, data, mapping
export LittleDict

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

end
