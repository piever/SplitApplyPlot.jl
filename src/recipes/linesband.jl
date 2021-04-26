"""
    linesband(xs, ys, lower, upper; kwargs...)

Line plot with a shaded ribbon around it.
## Attributes
$(ATTRIBUTES)
"""
@recipe(LinesBand) do scene
    l_theme = default_theme(scene, Lines)
    Attributes(
        color = l_theme.color,
        colormap = l_theme.colormap,
        colorrange = get(l_theme.attributes, :colorrange, automatic),
        linestyle = l_theme.linestyle,
        linewidth = l_theme.linewidth,
        alphamultiplier = 0.5,
    )
end

function AbstractPlotting.plot!(p::LinesBand)
    lines!(p, p[1:2]...;
        color = p.color,
        linestyle = p.linestyle,
        linewidth = p.linewidth,
        colormap = p.colormap,
        colorrange = p.colorrange,
    )
    if length(p) == 2
        lower, upper = lift(zero, p[2]), p[2]
    else
        lower, upper = p[3], p[4]
    end
    meshcolor = lift(p.color, p.alphamultiplier) do color, alphamultiplier
        rgba = to_color(color)
        r, g, b, α = red(rgba), green(rgba), blue(rgba), alpha(rgba)
        return RGBA(r, g, b, α * alphamultiplier)
    end
    band!(p, p[1], lower, upper; color = meshcolor)
end
