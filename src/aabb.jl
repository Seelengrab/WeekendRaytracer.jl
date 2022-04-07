struct aabb
    maximum::point3
    minimum::point3
end

function hit(bbox::aabb, r::ray, t_min::Float64, t_max::Float64)
    ret = true

    @inbounds for a in 1:3
        invd = 1.0f0 / direction(r)[a]
        t0 = min((bbox.minimum[a] - origin(ray)[a]) * invd,
                 (bbox.maximum[a] - origin(ray)[a]) * invd)
        t1 = max((bbox.minimum[a] - origin(ray)[a]) * invd,
                 (bbox.maximum[a] - origin(ray)[a]) * invd)
        t0, t1 = invd < 0.0f0 ? t1,t0 : t0,t1
        t_min = max(t0, t_min)
        t_max = min(t1, t_max)
        ret &= t_max > t_min
    end

    return ret
end
