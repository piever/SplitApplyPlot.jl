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
using SplitApplyPlot: CategoricalScale, ContinuousScale
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
        ContinuousScale(identity, (0, 1)),
        ContinuousScale(identity, (0, 1)),
        color=ContinuousScale(identity, (0, 1)),
        marker=CategoricalScale(["a", "b", "c"], [:circle, :utriangle, :dtriangle]), #scales
    ),
    arguments("x", "y", color="identity", marker="function"), #labels
)
plot!(ae)
display(fig)
