struct moving_sphere <: hittable
    center0::point3
    center1::point3
    time0::Float64
    time1::Float64
    radius::Float64
    mat::material
end

@inline function hit(s::moving_sphere, r::ray, t_min::Real, t_max::Real)
    oc = origin(r) - center(s, time(r))
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
    outward_normal = (p - center(s, time(r))) / s.radius
    ff, normal = face_normal(r, outward_normal)
    rec = hit_record(p,
                     normal,
                     s.mat,
                     t,
                     ff)

    return true, rec
end

function center(s::moving_sphere, time::Float64)
    s.center0 + ((time - s.time0) / (s.time1 - s.time0)) * (s.center1 - s.center0)
end

function bounding_box(ms::moving_sphere, t0::Real, t1::Real)
    box0 = aabb(
        center(ms, t0) - vec3(ms.radius,ms.radius,ms.radius),
        center(ms, t0) + vec3(ms.radius,ms.radius,ms.radius))
    box1 = aabb(
        center(ms, t1) - vec3(ms.radius,ms.radius,ms.radius),
        center(ms, t1) + vec3(ms.radius,ms.radius,ms.radius))
    return true, surrounding_box(box0, box1)
end
