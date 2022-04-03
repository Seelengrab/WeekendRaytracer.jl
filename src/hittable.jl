struct hit_record
    p::point3
    normal::vec3
    mat::material
    t::Float64
    front_face::Bool
end
hit_record() = hit_record(point3(0,0,0),vec3(0,0,0),lambertian(color(0,0,0)),-Inf,false)

function face_normal(r::ray, outward_normal::vec3)
    ff = dot(direction(r), outward_normal) < 0
    normal = ff ? outward_normal : -outward_normal
    return ff, normal
end

abstract type hittable end

"""
    hit(::hittable, ::ray, t_min::Real, t_max::Real) -> Tuple{Bool, hit_record}

Returns whether or not the given `<: hittable` is hit by the given ray. Saves the resulting data in the given `hit_record`.
"""
function hit end
