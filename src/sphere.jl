struct sphere <: hittable
    center::point3
    radius::Float64
    mat::material
end
sphere() = sphere(point3(0,0,0), 0, lambertian(color(0,0,0)))

@inline function hit(s::sphere, r::ray, t_min::Real, t_max::Real)
    oc = origin(r) - s.center
    a = length²(direction(r))
    half_b = dot(oc, direction(r))
    c = length²(oc) - s.radius*s.radius

    discriminant = half_b*half_b - a*c
    discriminant < 0 && return false, hit_record()
    sqrtd = sqrt(discriminant)

    root = (-half_b - sqrtd) / a
    if root < t_min || t_max < root
        root = (-half_b + sqrtd) / a
        if root < t_min || t_max < root
            return false, hit_record()
        end
    end

    t = root
    p = at(r, t)
    outward_normal = (p - s.center) / s.radius
    ff, normal = face_normal(r, outward_normal)
    rec = hit_record(p,
                     normal,
                     s.mat,
                     t,
                     ff)

    return true, rec
end
