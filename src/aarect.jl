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

@generated function bounding_box(rec::T, _::Float64, _::Float64) where T <: Union{xy_rect,xz_rect,yz_rect}
    a0,a1,b0,b1,_,_ = fieldnames(T)
    return quote
        return true, aabb(point3(rec.$a0, rec.$b0, rec.k - 0.0001),
                          point3(rec.$a1, rec.$b1, rec.k + 0.0001))
    end
end

@generated function hit(rec::T, r::ray, t_min::Float64, t_max::Float64) where T <: Union{xy_rect,xz_rect,yz_rect}
    a0,a1,b0,b1,_,_ = fieldnames(T)
    return quote
        t = (rec.k - origin(r).z) / direction(r).z
        if (t < t_min || t > t_max)
            return false, hit_record()
        end

        x = origin(r).x + t*direction(r).x
        y = origin(r).y + t*direction(r).y

        if (x < rec.$a0 || x > rec.$a1 || y < rec.$b0 || y > rec.$b1)
            return false, hit_record()
        end

        u = (x - rec.$a0) / (rec.$a1 - rec.$a0)
        v = (y - rec.$b0) / (rec.$b1 - rec.$b0)
        outward_normal = vec3(0,0,1)
        ff, fn = face_normal(r, outward_normal)
        ret = hit_record(at(r, t),
                         fn,
                         rec.mp,
                         t,u,v,ff)
        return true, ret
    end
end
