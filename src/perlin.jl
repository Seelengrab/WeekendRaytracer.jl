struct perlin
    point_count::Int
    ranfloat::Vector{Float64}
    perm_x::Vector{Int}
    perm_y::Vector{Int}
    perm_z::Vector{Int}
    function perlin(point_count=256)
        ranfloat = rand(Float64, point_count)
        perm_x = perlin_generate_perm(point_count)
        perm_y = perlin_generate_perm(point_count)
        perm_z = perlin_generate_perm(point_count)
        new(point_count, ranfloat, perm_x, perm_y, perm_z)
    end
end

function perlin_generate_perm(point_count::Int)
    p = collect(0:point_count-1)
    permute!(p, point_count)
end

function permute!(p::Vector{Int}, n::Int)
    for i in n:-1:2
        target = rand(1:n)
        p[i], p[target] = p[target], p[i]
    end
    p
end

function noise(gen::perlin, p::point3)
    # unsafe_trunc is fine here, since we generate noise anyway
    # the logical and also bounds the value, so we're good!
    i = ((unsafe_trunc(Int, 4.0*p.x)) & (gen.point_count-1)) + 1
    j = ((unsafe_trunc(Int, 4.0*p.y)) & (gen.point_count-1)) + 1
    k = ((unsafe_trunc(Int, 4.0*p.z)) & (gen.point_count-1)) + 1
    return @inbounds gen.ranfloat[(gen.perm_x[i] ⊻ gen.perm_y[j] ⊻ gen.perm_z[k]) + 1]
end
