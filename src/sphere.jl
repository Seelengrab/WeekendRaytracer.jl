struct sphere <: hittable
    center::point3
    radius::Float64
    mat::material
end
sphere() = sphere(point3(0,0,0), 0, lambertian(color(0,0,0)))

function get_uv(_::sphere, p::point3)
    # p: given a point on the sphere of radius one, centered at the origin
    # u: returned value in [0.0,1.0] of angle around the Y-Axis from X=-1
    # v: returned value in [0.0,1.0] of angle from Y=-1 to Y=+1
    #   <1 0 0> yields <0.50 0.50>        <-1 0 0> yields <0.00 0.50>
    #   <0 1 0> yields <0.50 1.00>        <0 -1 0> yields <0.50 0.00>
    #   <0 0 1> yields <0.25 0.50>        <0 0 -1> yields <0.75 0.50>

    theta = acos(-p.y)
    phi = atan(-p.z, p.x) + pi

    u = phi / 2pi
    v = theta / pi

    return u, v
end

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

function bounding_box(s::sphere, t0::Real, t1::Real)
    return true, aabb(s.center - vec3(s.radius, s.radius, s.radius),
                      s.center + vec3(s.radius, s.radius, s.radius))
end
