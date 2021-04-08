using SplitApplyPlot
using Documenter

DocMeta.setdocmeta!(SplitApplyPlot, :DocTestSetup, :(using SplitApplyPlot); recursive=true)

makedocs(;
    modules=[SplitApplyPlot],
    authors="piever <pietro.vertechi@protonmail.com> and contributors",
    repo="https://github.com/piever/SplitApplyPlot.jl/blob/{commit}{path}#{line}",
    sitename="SplitApplyPlot.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://piever.github.io/SplitApplyPlot.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/piever/SplitApplyPlot.jl",
)
