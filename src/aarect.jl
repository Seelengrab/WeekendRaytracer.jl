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

function hit(rec::Union{xy_rect, yz_rect, xz_rect}, r::ray, t_min::Float64, t_max::Float64)
    ori = origin(r)
    dir = direction(r)

    ori_a, ori_b, ori_c, dir_a, dir_b, dir_c = if rec isa xy_rect
        ori.x, ori.y, ori.z, dir.x, dir.y, dir.z
    elseif rec isa xz_rect
        ori.x, ori.z, ori.y, dir.x, dir.z, dir.y
    else
        ori.y, ori.z, ori.x, dir.y, dir.z, dir.x
    end

    t = (rec.k - ori_c) / dir_c
    if (t < t_min || t > t_max)
        return false, hit_record()
    end

    ax_a = ori_a + t*dir_a
    ax_b = ori_b + t*dir_b

    if (ax_a < getfield(rec, 1) || ax_a > getfield(rec, 2) ||
        ax_b < getfield(rec, 3) || ax_b > getfield(rec, 4))
        return false, hit_record()
    end

    u = (ax_a - getfield(rec, 1)) / (getfield(rec, 2) - getfield(rec, 1))
    v = (ax_b - getfield(rec, 3)) / (getfield(rec, 4) - getfield(rec, 3))
    outward_normal = vec3(rec isa yz_rect, rec isa xz_rect, rec isa xy_rect)
    ff, fn = face_normal(r, outward_normal)
    ret = hit_record(at(r, t),
                     fn,
                     rec.mp,
                     t,u,v,ff)
    return true, ret
end
