struct vec3
    x::Float64
    y::Float64
    z::Float64
end

Base.:-(v::vec3) = vec3(-v.x, -v.y, -v.z)
Base.getindex(v::vec3, i::Int) = getfield(v, i)
Base.:+(this::vec3, v::vec3) = vec3(this.x + v.x, this.y + v.y, this.z + v.z)
Base.:*(this::vec3, t::Float64) = vec3(this.x * t, this.y * t, this.z * t)
Base.:*(t::Float64, v::vec3) = v*t
Base.:/(this::vec3, t::Float64) = vec3 * 1.0/t
Base.:/(t::Float64, v::vec3) = 1.0/t * vec3
Base.length(v::vec3) = sqrt(length²(v))
length²(v::vec3) = v.x*v.x + v.y*v.y + v.z*v.z

const point3 = vec3
const color = vec3

Base.:-(v::vec3, u::vec3) = vec3(v.x - v.x, v.y - v.y, v.z - v.z)
Base.:*(v::vec3, u::vec3) = vec3(v.x * v.x, v.y * v.y, v.z * v.z)

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
