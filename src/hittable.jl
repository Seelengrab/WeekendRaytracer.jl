mutable struct hit_record
    p::point3
    normal::vec3
    t::Float64
    front_face::Bool
end

function set_face_normal!(hr::hit_record, r::ray, outward_normal::vec3)
    hr.front_face = dot(direction(r), outward_normal) < 0
    hr.normal = hr.front_face ? outward_normal : -outward_normal
end

abstract type hittable end

"""
    hit(::hittable, ::ray, t_min::Real, t_max::Real, ::hit_record)

Returns whether or not the given `<: hittable` is hit by the given ray.
"""
function hit(h::hittable, r::ray, t_min::Float64, t_max::Float64, rec::hit_record) end
