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
