struct sphere <: hittable
    center::point3
    radius::Float64
end
sphere() = sphere(point3(0,0,0), 0)

function hit(s::sphere, r::ray, t_min::Real, t_max::Real, rec::Ref{hit_record})
    oc = origin(r) - s.center
    a = length²(direction(r))
    half_b = dot(oc, direction(r))
    c = length²(oc) - s.radius*s.radius

    discriminant = half_b*half_b - a*c
    discriminant < 0 && return false
    sqrtd = sqrt(discriminant)

    root = (-half_b - sqrtd) / a
    if root < t_min || t_max < root
        root = (-half_b + sqrtd) / a
        if root < t_min || t_max < root
            return false
        end
    end

    rec[].t = root
    rec[].p = at(r, rec[].t)
    outward_normal =(rec[].p - s.center) / s.radius
    set_face_normal!(rec[], outward_normal)

    return true
end
