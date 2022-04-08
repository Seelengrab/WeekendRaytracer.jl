"""
A virtual texture.

Required methods:

    * value(::texture, u::Float64, v::Float64)
"""
abstract type texture end

"""
    value(::texture, u::Float64, v::Float64) -> color

Returns the value of the given texture at the given (u,v) coordinates.
"""
function value end

struct solid_color <: texture
    color_value::color
end
solid_color() = solid_color(zero(color))
solid_color(red::Float64, green::Float64, blue::Float64) = solid_color(color(red, green, blue))
value(sc::solid_color, _::Float64, _::Float64) = sc.color_value
