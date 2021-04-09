var documenterSearchIndex = {"docs":
[{"location":"generated/tutorial/","page":"-","title":"-","text":"EditURL = \"https://github.com/piever/SplitApplyPlot.jl/blob/master/docs/src/generated/tutorial.jl\"","category":"page"},{"location":"generated/tutorial/","page":"-","title":"-","text":"using SplitApplyPlot, CairoMakie\n\ndf = (\n    x=rand(100),\n    y=rand(100),\n    z=rand(100),\n    c=rand(Bool, 100),\n    d=rand(Bool, 100),\n    e=rand(Bool, 100),\n)\n\ndraw(Scatter, df, (marker=:c, layout_x=:d, layout_y=:e), mapping(:x, :y, color=:z))\n\ndraw(\n    Scatter,\n    df,\n    (marker=:c, layout_x=:d, layout_y=:e, title=:e),\n    mapping(:x, :y, color=:z)\n)\n\nfig = Figure()\naxes_mat = draw!(fig, df, (marker=:c, layout_x=:d, layout_y=:e), mapping(:x, :y, color=:z)) do ax, m\n    plot!(Scatter, ax, m)\n    ax.xticklabelrotation[] = π/2\nend\nhideinnerdecorations!(axes_mat)\nfig","category":"page"},{"location":"generated/tutorial/","page":"-","title":"-","text":"","category":"page"},{"location":"generated/tutorial/","page":"-","title":"-","text":"This page was generated using Literate.jl.","category":"page"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"CurrentModule = SplitApplyPlot","category":"page"},{"location":"#SplitApplyPlot","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"","category":"section"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"Documentation for SplitApplyPlot.","category":"page"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"","category":"page"},{"location":"","page":"SplitApplyPlot","title":"SplitApplyPlot","text":"Modules = [SplitApplyPlot]","category":"page"},{"location":"#SplitApplyPlot.apply_scale-Tuple{Any, Any, Any}","page":"SplitApplyPlot","title":"SplitApplyPlot.apply_scale","text":"apply_scale(scale, uniquevalues, value)\n\nReturn the value in scale corresponding to the index of value in uniquevalues. Cycle through scale if it has less entries than uniquevalues.\n\n\n\n\n\n","category":"method"},{"location":"#SplitApplyPlot.iscontinuous-Tuple{AbstractVector{T} where T}","page":"SplitApplyPlot","title":"SplitApplyPlot.iscontinuous","text":"iscontinuous(v::AbstractVector)\n\nDetermine whether v should be treated as a continuous or categorical vector.\n\n\n\n\n\n","category":"method"}]
}
