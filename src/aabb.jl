struct aabb
    minimum::point3
    maximum::point3
end
aabb() = aabb(zero(point3), zero(point3))

function box_compare(a, b, axis::Int)
    has_bba, bboxa = bounding_box(a, 0.0, 1.0)
    has_bbb, bboxb = bounding_box(b, 0.0, 1.0)

    (!has_bba || !has_bbb) && throw(ArgumentError("hittable doesn't have a bounding box: '$a'"))

    bboxa.minimum[axis] < bboxb.minimum[axis]
end

function hit(bbox::aabb, r::ray, t_min::Float64, t_max::Float64)
    @inbounds for a in 1:3
        invd = 1.0f0 / direction(r)[a]
        t0 = (bbox.minimum[a] - origin(r)[a]) * invd
        t1 = (bbox.maximum[a] - origin(r)[a]) * invd
        t0, t1 = invd < 0.0f0 ? (t1,t0) : (t0,t1)
        t_min = max(t0, t_min)
        t_max = min(t1, t_max)
        t_max <= t_min && return false
    end

    return true
end

function surrounding_box(b0::aabb, b1::aabb)
    small = point3(min(b0.minimum.x, b1.minimum.x),
                   min(b0.minimum.y, b1.minimum.y),
                   min(b0.minimum.z, b1.minimum.z))
    big = point3(max(b0.maximum.x, b1.maximum.x),
                 max(b0.maximum.y, b1.maximum.y),
                 max(b0.maximum.z, b1.maximum.z))
    return aabb(small, big)
end
