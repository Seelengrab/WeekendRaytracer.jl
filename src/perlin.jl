struct perlin
    point_count::Int
    ranfloat::Vector{Float64}
    perm_x::Vector{Int}
    perm_y::Vector{Int}
    perm_z::Vector{Int}
    function perlin(point_count=256)
        ranfloat = rand(Float64, point_count)
        any(<(0.0), ranfloat) && throw(ArgumentError("negative floats in perlin noise"))
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
    ui = floor(p.x)
    vi = floor(p.y)
    wi = floor(p.z)
    uf = p.x - ui
    vf = p.y - vi
    wf = p.z - wi

    i = unsafe_trunc(Int, ui)
    j = unsafe_trunc(Int, vi)
    k = unsafe_trunc(Int, wi)
    c = Array{Float64}(undef,2,2,2)

    @inbounds for di in 0:1, dj in 0:1, dk in 0:1
        c[di+1,dj+1,dk+1] = gen.ranfloat[
            (gen.perm_x[((i+di) & (gen.point_count-1)) + 1] ⊻
             gen.perm_y[((j+dj) & (gen.point_count-1)) + 1] ⊻
             gen.perm_z[((k+dk) & (gen.point_count-1)) + 1]) + 1
        ]
    end

    return trilinear_interpolate(c, uf, vf, wf)
end

function trilinear_interpolate(c, u::Float64, v::Float64, w::Float64)
    accum = 0.0

    for i in 0:1, j in 0:1, k in 0:1
        accum += (i*u + (1-i) * (1-u)) *
                 (j*v + (1-j) * (1-v)) *
                 (k*w + (1-k) * (1-w)) * c[i+1,j+1,k+1]
    end

    return accum
end
