struct xy_rect <: hittable
    x0::Float64
    x1::Float64
    y0::Float64
    y1::Float64
    k::Float64
    mp::material
end

function bounding_box(rec::xy_rect, _::Real, _::Real)
    return true, aabb(point3(rec.x0, rec.y0, rec.k - 0.0001),
                      point3(rec.x1, rec.y1, rec.k + 0.0001))
end

function hit(rec::xy_rect, r::ray, t_min::Float64, t_max::Float64)
    t = (rec.k - origin(r).z) / direction(r).z
    if (t < t_min || t > t_max)
        return false, hit_record()
    end

    x = origin(r).x + t*direction(r).x
    y = origin(r).y + t*direction(r).y

    if (x < rec.x0 || x > rec.x1 || y < rec.y0 || y > rec.y1)
        return false, hit_record()
    end

    u = (x - rec.x0) / (rec.x1 - rec.x0)
    v = (y - rec.y0) / (rec.y1 - rec.y0)
    outward_normal = vec3(0,0,1)
    ff, fn = face_normal(r, outward_normal)
    ret = hit_record(at(r, t),
                     fn,
                     rec.mp,
                     t,u,v,ff)
    return true, ret
end
