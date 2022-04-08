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

struct checker_texture{O<:texture,E<:texture} <: texture
    odd::O
    even::E
end
checker_texture(c1::color,c2::color) = checker_texture(solid_color(c1), solid_color(c2))

function value(ct::checker_texture, u::Float64, v::Float64, p::point3)
    factor = pi/10.0
    checker = floor(factor*p.x)+floor(factor*p.y)+floor(factor*p.z)
    checker = modf(checker*0.5)[1]*2.0
    if isodd(checker)
        return value(ct.odd, u, v, p)
    else
        return value(ct.even, u, v, p)
    end
end
