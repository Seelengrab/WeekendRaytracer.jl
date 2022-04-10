"""
A virtual texture.

Required methods:

    * value(::texture, u::Float64, v::Float64)
"""
abstract type texture end

"""
    value(::texture, u::Float64, v::Float64, p::point3) -> color

Returns the value of the given texture of the given (u,v) coordinates  at point `p`.
"""
function value end

#####
# solid color
#####

struct solid_color <: texture
    color_value::color
end
solid_color() = solid_color(zero(color))
solid_color(red::Float64, green::Float64, blue::Float64) = solid_color(color(red, green, blue))
value(sc::solid_color, _::Float64, _::Float64, _::point3) = sc.color_value

#####
# checker texture
#####

struct checker_texture_3D{O<:texture,E<:texture} <: texture
    odd::O
    even::E
end
checker_texture_3D(c1::color,c2::color) = checker_texture_3D(solid_color(c1), solid_color(c2))

function value(ct::checker_texture_3D, u::Float64, v::Float64, p::point3)
    p = p*(10.0/pi)
    checker = floor(p.x)+floor(p.y)+floor(p.z)
    checker = modf(checker*0.5)[1]*2.0
    if isodd(checker)
        return value(ct.odd, u, v, p)
    else
        return value(ct.even, u, v, p)
    end
end

#####
# noise texture
#####

struct noise_texture <: texture
    noise::perlin
    scale::Float64
end
noise_texture(scale=0.0) = noise_texture(perlin(), scale)

function value(nt::noise_texture, _::Float64, _::Float64, p::point3)
    return color(1,1,1) * 0.5 * (1.0 + noise(nt.noise, nt.scale*p))
end

struct turbulent_texture <: texture
    noise::perlin
    scale::Float64
end
turbulent_texture(scale=0.0) = turbulent_texture(perlin(), scale)

function value(tt::turbulent_texture, _::Float64, _::Float64, p::point3)
    return color(1,1,1) * turbulence(tt.noise, tt.scale * p)
end

struct marble_texture <: texture
    noise::perlin
    scale::Float64
end
marble_texture(scale=0.0) = marble_texture(perlin(), scale)

function value(tt::marble_texture, _::Float64, _::Float64, p::point3)
    return color(1,1,1) * 0.5 * (1.0 + sin(tt.scale * p.z + 10*turbulence(tt.noise, tt.scale * p)))
end

#####
# image texture
#####

struct image_texture{T <: Matrix} <: texture
    data::T
end
image_texture(s::AbstractString) = image_texture(FileIO.load(s))

function value(it::image_texture, u::Float64, v::Float64, _::vec3)
    isempty(it.data) && return color(0,1,1)

    # Clamp input texture coordinates to [0,1] x [1,0]
    u = clamp(u, 0.0, 1.0)
    v = 1.0 - clamp(v, 0.0, 1.0) # Flip V to image coordinates

    height, width = size(it.data)

    i = unsafe_trunc(Int, u*width)
    j = unsafe_trunc(Int, v*height)

    # Clamp integer mapping, since actual coordinates should be less than 1.0
    i = min(i, width-1)
    j = min(j, height-1)

    pixel = it.data[j+1, i+1]

    return color(pixel.r, pixel.g, pixel.b)
end
