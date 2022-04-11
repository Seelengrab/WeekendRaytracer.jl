abstract type bvh <: hittable end
struct bvh_uniform{T} <: bvh
    left::Union{bvh_uniform{T}, T}
    right::Union{bvh_uniform{T}, T}
    box::aabb
end

struct bvh_mixed <: bvh
    left::hittable
    right::hittable
    box::aabb
end

bvh(l::T, r::T, box::aabb) where T <: hittable = bvh_uniform(l, r, box)
bvh(l::T, r::U, box::aabb) where {T,U} = bvh_mixed(l, r, box)

function bvh(objs::AbstractVector{<:bvh}, t0::Real=0.0, t1::Real=1.0)
    isone(length(objs)) && return only(objs)
    mid = div(length(objs), 2)
    l = bvh(@view(objs[begin:mid]), t0, t1)
    r = bvh(@view(objs[mid+1:end]), t0, t1)
    bvh(l, r, surrounding_box(l.box, r.box))
end

function bvh(src_objects::AbstractVector{<:hittable}, time0::Real=0.0, time1::Real=1.0)
    axis = rand(1:3)
    comparator(a,b) = box_compare(a,b,axis)

    if isone(length(src_objects))
        left = right = only(src_objects)
    elseif length(src_objects) == 2
        a = src_objects[begin]
        b = src_objects[end]
        if comparator(a,b)
            left = a
            right = b
        else
            left = b
            right = a
        end
    else
        sort!(src_objects, lt=comparator)

        new_len = div(length(src_objects), 2)

        left = bvh(@view(src_objects[begin:new_len+1]), time0, time1)
        right = bvh(@view(src_objects[new_len+1:end]), time0, time1)
    end

    hit_left, bbox_left = bounding_box(left, time0, time1)
    hit_right, bbox_right = bounding_box(right, time0, time1)

    (!hit_left || !hit_right) && throw(ArgumentError("No bounding box in bvh constructor."))

    bbox = surrounding_box(bbox_left, bbox_right)
    return bvh(left, right, bbox)
end

bounding_box(bvh::bvh, ::Real, ::Real) = return true, bvh.box

@inline function hit(bvh::bvh, r::ray, t_min::Real, t_max::Real)::Tuple{Bool, hit_record}
    boxhit = hit(bvh.box, r, t_min, t_max)
    !boxhit && return false, hit_record()

    hit_left, rec_left = hit(bvh.left, r, t_min, t_max)
    hit_right, rec_right = hit(bvh.right, r, t_min, hit_left ? rec_left.t : t_max)

    # we hit right last with t_max of left, so check it first
    if hit_right
        return true, rec_right
    elseif hit_left
        return true, rec_left
    else
        return false, hit_record()
    end
end
