struct vec3
    x::Float64
    y::Float64
    z::Float64
end

Base.:-(v::vec3) = vec3(-v.x, -v.y, -v.z)
Base.getindex(v::vec3, i::Int) = getfield(v, i)
Base.:+(this::vec3, v::vec3) = vec3(this.x + v.x, this.y + v.y, this.z + v.z)
Base.:*(this::vec3, t::Real) = vec3(this.x * t, this.y * t, this.z * t)
Base.:*(t::Real, v::vec3) = v*t
Base.:/(v::vec3, t::Real) = v * inv(t)
Base.:/(t::Real, v::vec3) = inv(t) * v
Base.length(v::vec3) = sqrt(length²(v))
length²(v::vec3) = v.x*v.x + v.y*v.y + v.z*v.z

const point3 = vec3
const color = vec3

Base.:-(v::vec3, u::vec3) = vec3(v.x - u.x, v.y - u.y, v.z - u.z)
Base.:*(v::vec3, u::vec3) = vec3(v.x * u.x, v.y * u.y, v.z * u.z)

function dot(u::vec3, v::vec3)
    return u.x * v.x +
           u.y * v.y +
           u.z * v.z
end

function cross(u::vec3, v::vec3)
    return vec3(u.y * v.z - u.z * v.y,
                u.z * v.x - u.x * v.z,
                u.x * v.y - u.y * v.x)
end

unit_vector(v::vec3) = v / length(v)

function Base.rand(rng::AbstractRNG, _::Random.SamplerType{vec3})
    vec3(rand(rng, Float64),rand(rng, Float64),rand(rng, Float64))
end

"""
A type for picking a random Float64 in [min, max).
"""
struct BoundedFloat64
    min::Float64
    max::Float64
end
Base.eltype(::Type{BoundedFloat64}) = Float64
Base.rand(_::AbstractRNG, b::Random.SamplerTrivial{BoundedFloat64}) = b[].min + (b[].max - b[].min) * rand(Float64)
Random.Sampler(_::Type{<:AbstractRNG}, bf64::BoundedFloat64, r::Random.Repetition) = Random.SamplerTrivial(bf64)

"""
A type for picking a random vector with bounded coordinates.
"""
struct BoundedVec3
    bound::BoundedFloat64
    BoundedVec3(min::Real, max::Real) = new(BoundedFloat64(float(min), float(max)))
end
Base.eltype(::Type{BoundedVec3}) = vec3
Random.Sampler(_::Type{<:AbstractRNG}, bv3::BoundedVec3, r::Random.Repetition) = Random.SamplerTrivial(bv3)

function Random.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{BoundedVec3})
    vec3(rand(rng, sp[].bound), rand(rng, sp[].bound), rand(rng, sp[].bound))
end

"""
A singleton type for picking a random vector in the unit sphere.
"""
struct InUnitSphere end
Base.eltype(::Type{InUnitSphere}) = vec3
Random.Sampler(_::Type{<:AbstractRNG}, us::InUnitSphere) = Random.SamplerTrivial(us)
function Random.rand(rng::AbstractRNG, _::Random.SamplerTrivial{InUnitSphere})
    while true
        p = rand(rng, BoundedVec3(-1,1))
        length²(p) >= 1.0 && continue
        return p
    end
end

"""
A singleton type for picking a random vector with length 1.
"""
struct UnitVector end
Base.eltype(::Type{UnitVector}) = vec3
Random.Sampler(_::Type{<:AbstractRNG}, us::UnitVector) = Random.SamplerTrivial(us)
Random.rand(rng::AbstractRNG, _::Random.SamplerTrivial{UnitVector}) = unit_vector(rand(rng, InUnitSphere()))

"""
A type for picking a random vector in the same hemisphere as the given normal.
"""
struct InHemisphere
    normal::vec3
end
Base.eltype(::Type{InHemisphere}) = vec3
Random.Sampler(_::Type{<:AbstractRNG}, hemi::InHemisphere, _::Random.Repetition) = Random.SamplerTrivial(hemi)
function Random.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{InHemisphere})
    in_unit_sphere = rand(rng, InUnitSphere())

    if dot(in_unit_sphere, sp[].normal) > 0.0
        return in_unit_sphere
    else
        return -in_unit_sphere
    end
end
