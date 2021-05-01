using SplitApplyPlot
using Documenter
using Literate, Glob
using CairoMakie

CairoMakie.activate!()

ENV["DATADEPS_ALWAYS_ACCEPT"] = true

# generate examples
GENERATED = joinpath(@__DIR__, "src", "generated")
SOURCE_FILES = Glob.glob("*.jl", GENERATED)
foreach(fn -> Literate.markdown(fn, GENERATED), SOURCE_FILES)

DocMeta.setdocmeta!(SplitApplyPlot, :DocTestSetup, :(using SplitApplyPlot); recursive=true)

makedocs(;
    modules=[SplitApplyPlot],
    authors="piever <pietro.vertechi@protonmail.com> and contributors",
    repo="https://github.com/piever/SplitApplyPlot.jl/blob/{commit}{path}#{line}",
    sitename="SplitApplyPlot.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://piever.github.io/SplitApplyPlot.jl",
        assets=["assets/favicon.ico"],
    ),
    pages=Any[
        "index.md",
        "generated/penguins.md",
        "generated/analyses.md",
        "generated/statistical_plots.md",
        "generated/entries.md",
        "generated/gallery.md",
        "API.md",
    ],
    strict = true,
)

deploydocs(;
    repo="github.com/piever/SplitApplyPlot.jl",
    push_preview = true,
)
