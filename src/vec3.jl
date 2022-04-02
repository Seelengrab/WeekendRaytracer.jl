struct vec3
    x::Float64
    y::Float64
    z::Float64
end

Base.:-(v::vec3) = vec3(-v.x, -v.y, -v.z)
Base.getindex(v::vec3, i::Int) = getfield(v, i)
Base.:+(this::vec3, v::vec3) = vec3(this.x + v.x, this.y + v.y, this.z + v.z)
Base.:*(this::vec3, t::Float64) = vec3(this.x * t, this.y * t, this.z * t)
Base.:/(this::vec3, t::Float64) = vec3 * 1.0/t
Base.length(v::vec3) = sqrt(length²(v))
length²(v::vec3) = v.x*v.x + v.y*v.y + v.z*v.z

const point3 = vec3
const color = vec3
