struct perlin
    point_count::Int
    ranvec::Vector{vec3}
    perm_x::Vector{Int}
    perm_y::Vector{Int}
    perm_z::Vector{Int}
    function perlin(point_count=256)
        ranvec = rand(BoundedVec3(-1.0,1.0), point_count)
        perm_x = perlin_generate_perm(point_count)
        perm_y = perlin_generate_perm(point_count)
        perm_z = perlin_generate_perm(point_count)
        new(point_count, ranvec, perm_x, perm_y, perm_z)
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
    # hermitian smoothing
    uf = uf*uf*(3.0-2.0*uf)
    vf = vf*vf*(3.0-2.0*vf)
    wf = wf*wf*(3.0-2.0*wf)

    i = unsafe_trunc(Int, ui)
    j = unsafe_trunc(Int, vi)
    k = unsafe_trunc(Int, wi)
    c = Array{vec3}(undef,2,2,2)

    @inbounds for di in 0:1, dj in 0:1, dk in 0:1
        c[di+1,dj+1,dk+1] = gen.ranvec[
            (gen.perm_x[((i+di) & (gen.point_count-1)) + 1] ⊻
             gen.perm_y[((j+dj) & (gen.point_count-1)) + 1] ⊻
             gen.perm_z[((k+dk) & (gen.point_count-1)) + 1]) + 1
        ]
    end

    return trilinear_interpolate(c, uf, vf, wf)
end

function turbulence(n::perlin, p::point3, depth=7)
    accum = 0.0
    temp_p = p
    weight = 1.0

    for _ in 1:depth
        accum += weight * noise(n, temp_p)
        weight *= 0.5
        temp_p *= 2.0
    end

    return abs(accum)
end

function trilinear_interpolate(c, u::Float64, v::Float64, w::Float64)
    uu = u*u*(3.0-2.0*u)
    vv = v*v*(3.0-2.0*v)
    ww = w*w*(3.0-2.0*w)
    accum = 0.0

    for i in 0:1, j in 0:1, k in 0:1
        weight = vec3(u-i, v-j, w-k)
        accum += (i*u + (1-i) * (1-u)) *
                 (j*v + (1-j) * (1-v)) *
                 (k*w + (1-k) * (1-w)) *
                 dot(c[i+1,j+1,k+1], weight)
    end

    return accum
end
