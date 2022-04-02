mutable struct hit_record
    p::point3
    normal::vec3
    t::Float64
    front_face::Bool
end
hit_record() = hit_record(point3(0,0,0),vec3(0,0,0),-Inf,false)

function set_face_normal!(hr::hit_record, r::ray, outward_normal::vec3)
    hr.front_face = dot(direction(r), outward_normal) < 0
    hr.normal = hr.front_face ? outward_normal : -outward_normal
end

abstract type hittable end

"""
    hit(::hittable, ::ray, t_min::Real, t_max::Real, ::Ref{hit_record})

Returns whether or not the given `<: hittable` is hit by the given ray.
"""
function hit end
