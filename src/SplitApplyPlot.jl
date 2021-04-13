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

export hideinnerdecorations!, fillmissingaxes!
export arguments, Entry, AxisEntries
export splitapplyplot!
export categoricalscale, continuousscale, automatic
export LittleDict

include("arguments.jl")
include("scales.jl")
include("entries.jl")
include("data.jl")
include("utils.jl")

end
