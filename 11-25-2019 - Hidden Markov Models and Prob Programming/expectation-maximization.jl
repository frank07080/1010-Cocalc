using Printf 

"""
Gives P(Z_k = 1 | All other variables)
 Inputs
 - x: The vector of (observed) X variables
 - z: The current sample of Z variables
 - θ: The vector parameters in the form [q, σ²]
 - k: The index of the Z variable of interest
Outputs
 The probability that Z_k = 1 given all other variables
"""
function conditional_probability(x, z, θ, j)
    # Extract density parameters
    q, σ² = θ
    σ = sqrt(σ²)
    n = length(x)
    𝒩₁ = Normal(1, σ)
    𝒩₀ = Normal(0, σ)

    if j == 1
        joint = (q*(z[j+1] == 1) + (1-q)*(z[j+1] == 0))*pdf(𝒩₁, x[j])
        marginal = joint + (q*(z[j+1] == 0) +
        (1-q)*(z[j+1] == 1))*pdf(𝒩₀,x[j])
    elseif j == n
        joint = (q*(z[j-1] == 1) + (1-q)*(z[j-1] == 0))*pdf(𝒩₁, x[j])
        marginal = joint + (q*(z[j-1] == 0) +
        (1-q)*(z[j-1] == 1))*pdf(𝒩₀,x[j])
    else
        joint = (q*(z[j-1] == 1) + (1-q)*(z[j-1] == 0))*(q*(z[j+1] == 1) +
         (1-q)*(z[j+1] == 0))*pdf(𝒩₁,x[j])
        marginal = joint + (q*(z[j-1] == 0) + (1-q)*(z[j-1] == 1))*(q*(z[j+1] == 0) +
        (1-q)*(z[j+1] == 1))*pdf(𝒩₀, x[j])
    end
    joint/marginal
end


"""
Performs one single Gibbs sampler iteration of Z
Inputs
 - x: The vector of (observed) X variables
 - z: The current sample of Z variables
 - θ: The vector parameters in the form [q, σ²]
 - j: The index of the Z variable of interest
 Outputs
 A Z sample where each index of Z is sampled by conditioning on all other
 variables
"""
function get_single_gibbs_sample!(x, z, θ)
    n = length(x)
    for j = 1:n
        z[j] = rand() < conditional_probability(x, z, θ, j)
    end
end

"""
Returns a sample of Z, drawn from a
Inputs
 - x: The vector of (observed) X variables
 - θ: The vector parameters in the form [q, σ²]
 Outputs
A Z sample where Z ~ P(Z|X = x)
"""
function gibbs_sampler(x, θ)
    n = length(x)
    z = rand(0:1, n)
    for i = 1:75
        get_single_gibbs_sample!(x, z, θ)
    end
    z
end

"""
Estimates the values of a,b,c (as defined in example) via Monte Carlo
Inputs
 - x: The vector of (observed) X variables
 - θ: The vector parameters in the form [q, σ²]
 Outputs
 A vector in the form [a,b,c] representing a MC estimate of a,b, and c
"""
function estimate_a_b_c(x, θ)
    n = length(x)

    # Number of MC samples
    num_samples = 100

    # Estimate sum
    total_a = 0
    total_b = 0
    total_c = 0

    for k = 1:num_samples
        z_samples = gibbs_sampler(x, θ)
        estimate_a = sum(z_samples[1:(n-1)] .== z_samples[2:n])
        estimate_b = sum(z_samples[1:(n-1)] .!= z_samples[2:n])
        estimate_c = sum((x - z_samples).^2)

        total_a += estimate_a
        total_b += estimate_b
        total_c += estimate_c
    end

    return [total_a, total_b, total_c]./num_samples
end

"""
Performs EM algorithm to estimate θ
 Inputs
 - x: The vector of (observed) X variables
 Outputs
 An estimate of θ = [q, σ²]
"""
function em_algorithm(x)
    # Initialize θ parameter [q, σ²]
    θ = [0.5, 1]

    num_iterations = 500

    for i = 1:num_iterations
        a, b, c = estimate_a_b_c(x, θ)
        q = a/(a+b)
        σ² = c/(a+b+1)
        θ = [q, σ²]
        print(stderr,'\r')
        printstyled(stderr, "k = $i, $θ", color=:green)
    end

    θ
end