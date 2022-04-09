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
end
noise_texture() = noise_texture(perlin())

function value(nt::noise_texture, _::Float64, _::Float64, p::point3)
    return color(1,1,1) * noise(nt.noise, p)
end
