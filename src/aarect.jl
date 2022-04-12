struct xy_rect <: hittable
    x0::Float64
    x1::Float64
    y0::Float64
    y1::Float64
    k::Float64
    mp::material
end

struct xz_rect <: hittable
    x0::Float64
    x1::Float64
    z0::Float64
    z1::Float64
    k::Float64
    mp::material
end

struct yz_rect <: hittable
    y0::Float64
    y1::Float64
    z0::Float64
    z1::Float64
    k::Float64
    mp::material
end

function bounding_box(rec::xy_rect, _::Float64, _::Float64)
        return true, aabb(point3(rec.x0, rec.y0, rec.k - 0.0001),
                          point3(rec.x1, rec.y1, rec.k + 0.0001))
end

function bounding_box(rec::xz_rect, _::Float64, _::Float64)
        return true, aabb(point3(rec.x0, rec.k - 0.0001, rec.z0),
                          point3(rec.x1, rec.k + 0.0001, rec.z1))
end

function bounding_box(rec::yz_rect, _::Float64, _::Float64)
        return true, aabb(point3(rec.k - 0.0001, rec.y0, rec.z0),
                          point3(rec.k + 0.0001, rec.y1, rec.z1))
end

function hit(rec::T, r::ray, t_min::Float64, t_max::Float64) where T <: Union{xy_rect,xz_rect,yz_rect}
    o = origin(r)
    d = direction(r)
    r_a,r_b,r_c,d_a,d_b,d_c = if T <: xy_rect
        o.x,o.y,o.z,d.x,d.y,d.z
    elseif T <: xz_rect
        o.x,o.z,o.y,d.x,d.z,d.y
    else
        o.y,o.z,o.x,d.y,d.z,d.x
    end

    t = (rec.k - r_c) / d_c
    if (t < t_min || t > t_max)
        return false, hit_record()
    end

    a = r_a + t*d_a
    b = r_b + t*d_b

    if (a < getfield(rec, 1) || a > getfield(rec, 2) ||
        b < getfield(rec, 3) || b > getfield(rec, 4))
        return false, hit_record()
    end

    u = (a - getfield(rec, 1)) / (getfield(rec, 2) - getfield(rec, 1))
    v = (b - getfield(rec, 3)) / (getfield(rec, 4) - getfield(rec, 3))
    outward_normal = vec3(0,0,1)
    ff, fn = face_normal(r, outward_normal)
    ret = hit_record(at(r, t),
                     fn,
                     rec.mp,
                     t,u,v,ff)
    return true, ret
end
