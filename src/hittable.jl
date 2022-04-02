mutable struct hit_record
    p::point3
    normal::vec3
    t::Float64
end

abstract type hittable end

"""
    hit(::hittable, ::ray, t_min::Real, t_max::Real, ::hit_record)

Returns whether or not the given `<: hittable` is hit by the given ray.
"""
function hit(h::hittable, r::ray, t_min::Float64, t_max::Float64, rec::hit_record) end
