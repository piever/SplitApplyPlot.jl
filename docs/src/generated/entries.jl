# # Entries
#
# The key ingredient for data representations are `AxisEntries`.
#
# ## The `AxisEntries` type
#
# An `AxisEntries` object is
# made of four components:
# - axis,
# - entries.

using SplitApplyPlot, CairoMakie
resolution = (600, 600)
fig = Figure(; resolution)
N = 11
rg = range(1, 2, length=N)
ae = AxisEntries(
    Axis(fig[1, 1]),
    [
        Entry(
            Scatter,
            arguments(rg, cosh.(rg), color=1:N, marker=fill("b", N));
            markersize = 15
        ),
        Entry(
            Scatter,
            arguments(rg, sinh.(rg), color=1:N, marker=fill("c", N));
            markersize = 15
        ),
    ],
    arguments(
        identity,
        log10,
        color=identity,
        marker=CategoricalScale(["a", "b", "c"], [:circle, :utriangle, :dtriangle]), #scales
    ),
    arguments("x", "y", color="identity", marker="function"), #labels
)
plot!(ae)
display(fig)
AbstractPlotting.save("axisentries.svg", AbstractPlotting.current_scene()); nothing #hide

# ![](axisentries.svg)
#
