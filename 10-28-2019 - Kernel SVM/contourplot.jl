import Contour.contours
contours(x, y, f::Function, lvls) = contours(x, y, [f(a,b) for a in x, b in y], lvls)
function contourplot!(p, x, y, f::Function, lvls; kw...)
    for cl in levels(contours(x,y,f,lvls))
        lvl = level(cl) 
        for line in lines(cl)
            xs, ys = coordinates(line) # coordinates of this line segment
            plot!(p, xs, ys, primary = false; kw...)
        end
    end
    p
end
contourplot(x,y,f::Function,lvls; kw...) = contourplot!(plot(),x,y,f::Function,lvls; kw...)
contourplot!(x,y,f::Function,lvls; kw...) = contourplot!(current(),x,y,f::Function,lvls; kw...)