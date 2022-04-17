struct hit_record
    p::point3
    normal::vec3
    mat::material
    t::Float64
    u::Float64
    v::Float64
    front_face::Bool
end
hit_record() = hit_record(point3(0,0,0),vec3(0,0,0),lambertian(color(0,0,0)),-Inf,0.0,0.0,false)

function face_normal(r::ray, outward_normal::vec3)
    ff = dot(direction(r), outward_normal) < 0.0
    normal = ff ? outward_normal : -outward_normal
    return ff, normal
end

abstract type hittable end

"""
    hit(::hittable, ::ray, t_min::Real, t_max::Real) -> Tuple{Bool, hit_record}

Returns whether or not the given `<: hittable` is hit by the given ray. Saves the resulting data in the given `hit_record`.
"""
function hit end

"""
    bounding_box(::hittable, time0::Float64, time1::Float64)

Returns the bounding box for the given `<: hittable`, covering the time interval `[t0,t1]`.
"""
function bounding_box end

struct translate{T} <: hittable
    ptr::T
    offset::vec3
end

function hit(t::translate, r::ray, t_min::Float64, t_max::Float64)
    moved_r = ray(origin(r) - t.offset, direction(r), time(r))
    got_hit, rec = hit(t.ptr, moved_r, t_min, t_max)
    !got_hit && return false, hit_record()

    ff, n = face_normal(moved_r, rec.normal)
    ret = hit_record(
            rec.p + t.offset,
            n,
            rec.mat,
            rec.t, rec.u, rec.v,
            ff)

    return true, ret
end

function bounding_box(t::translate, time0::Float64, time1::Float64)
    hasbb, bb = bounding_box(t.ptr, time0, time1)
    !hasbb && return false, aabb()

    return true, aabb(bb.minimum + t.offset, bb.maximum + t.offset)
end

struct y_rotate{T} <: hittable
    ptr::T
    sin_theta::Float64
    cos_theta::Float64
    hasbox::Bool
    bbox::aabb

    function y_rotate(p::T, angle::Float64) where T <: hittable
        radians = deg2rad(angle)
        sin_theta = sin(radians)
        cos_theta = cos(radians)
        hasbox, bbox = bounding_box(p, 0.0, 1.0)

        minx = miny = minz =  Inf
        maxx = maxy = maxz = -Inf

        for i in 0:1, j in 0:1, k in 0:1
            x = i*bbox.maximum.x + (1-i)*bbox.minimum.x
            y = j*bbox.maximum.y + (1-j)*bbox.minimum.y
            z = k*bbox.maximum.z + (1-k)*bbox.minimum.z

            newx =  cos_theta*x + sin_theta*z
            newz = -sin_theta*x + cos_theta*z

            minx = min(minx, newx)
            miny = min(miny, y)
            minz = min(minz, newz)
            maxx = max(maxx, newx)
            maxy = max(maxy, y)
            maxz = max(maxz, newz)
        end

        bbox = aabb(vec3(minx, miny, minz), vec3(maxx, maxy, maxz))
        new{T}(p, sin_theta, cos_theta, hasbox, bbox)
    end
end

function hit(yr::y_rotate, r::ray, t_min::Float64, t_max::Float64)
    ori = origin(r)
    dir = direction(r)

    ori_x = yr.cos_theta*ori.x - yr.sin_theta*ori.z
    ori_z = yr.sin_theta*ori.x + yr.cos_theta*ori.z

    dir_x = yr.cos_theta*dir.x - yr.sin_theta*dir.z
    dir_z = yr.sin_theta*dir.x + yr.cos_theta*dir.z

    rotated_r = ray(vec3(ori_x, ori.y, ori_z), vec3(dir_x, dir.y, dir_z), time(r))
    got_hit, rec = hit(yr.ptr, rotated_r, t_min, t_max)
    !got_hit && return false, hit_record()

    p_x =  yr.cos_theta*rec.p.x + yr.sin_theta*rec.p.z
    p_z = -yr.sin_theta*rec.p.x + yr.cos_theta*rec.p.z

    norm_x =  yr.cos_theta*rec.normal.x + yr.sin_theta*rec.normal.z
    norm_z = -yr.sin_theta*rec.normal.x + yr.cos_theta*rec.normal.z

    ff,n = face_normal(rotated_r, vec3(norm_x, rec.normal.y, norm_z))
    ret = hit_record(
        vec3(p_x, rec.p.y, p_z),
        n,
        rec.mat,
        rec.t, rec.u, rec.v, ff)

    return true, ret
end
