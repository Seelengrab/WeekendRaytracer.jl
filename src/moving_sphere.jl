struct moving_sphere <: hittable
    center0::point3
    center1::point3
    time0::Float64
    time1::Float64
    radius::Float64
    mat::material
end

function get_uv(_::moving_sphere, p::point3)
    # p: given a point on the sphere of radius one, centered at the origin
    # u: returned value in [0.0,1.0] of angle around the Y-Axis from X=-1
    # v: returned value in [0.0,1.0] of angle from Y=-1 to Y=+1
    #   <1 0 0> yields <0.50 0.50>        <-1 0 0> yields <0.00 0.50>
    #   <0 1 0> yields <0.50 1.00>        <0 -1 0> yields <0.50 0.00>
    #   <0 0 1> yields <0.25 0.50>        <0 0 -1> yields <0.75 0.50>

    theta = acos(-p.y)
    phi = atan(-p.z, p.x) + pi

    u = phi / 2pi
    v = theta / phi

    return u, v
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
    u,v = get_uv(s, outward_normal)
    rec = hit_record(p,
                     normal,
                     s.mat,
                     t,
                     u,
                     v,
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
