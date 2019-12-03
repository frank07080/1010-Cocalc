function ellipse!(μ,Σ;kw...)
    for i=1:3
        plot!([tuple((i*sqrt(Σ)*[cos(t),sin(t)]+μ)...) for t in range(0,stop=2π,length=100)];
              seriestype=:shape,linealpha=0.5,linecolor=:gray,fillalpha=[0.4,0.2,0.1][i],kw...)
    end
    current()
end

function mixtureplot(X₁,X₂,μ₀,Σ₀,μ₁,Σ₁,Π=nothing)
    scatter(X₁,X₂;fillalpha=0.5,markerstrokewidth=0.5,
        marker_z=Π,mc=ColorGradient([:lightblue,:orange]),
        colorbar=:false)
    ellipse!(μ₀,Σ₀,fillcolor=:lightblue)
    ellipse!(μ₁,Σ₁,fillcolor=:orange)
    plot!(;bg=:transparent,xlims=(-4.5,8.5),ylims=(-3.5,10.5),
        leg=false,ticks=:none,ratio=:equal)
end

