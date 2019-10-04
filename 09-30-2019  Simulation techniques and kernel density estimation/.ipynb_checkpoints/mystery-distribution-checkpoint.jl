
function mysteryRV()
    U = rand()
    if U < 0.4
        -1
    elseif U < 0.6
        -0.5
    else
        2 + 0.5randn()
    end
end