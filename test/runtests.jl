using SplitApplyPlot
using Test

@testset "utils" begin
    v1 = [1, 2, 7, 11]
    v2 = [1, 3, 4, 5.1]
    @test SplitApplyPlot.mergesorted(v1, v2) == [1, 2, 3, 4, 5.1, 7, 11]
    @test SplitApplyPlot.mergesorted(v2, v1) == [1, 2, 3, 4, 5.1, 7, 11]
    @test_throws ArgumentError SplitApplyPlot.mergesorted([2, 1], [1, 3])
    @test_throws ArgumentError SplitApplyPlot.mergesorted([1, 2], [10, 3])

    e1 = (-3, 11)
    e2 = (-5, 10)
    @test SplitApplyPlot.extend_extrema(e1, e2) == (-5, 11)
end
