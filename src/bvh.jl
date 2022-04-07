struct bvh_node <: hittable
    left::hittable
    right::hittable
    box::aabb
end

function bvh_node(src_objects::AbstracArray{<:hittable}, time0::Real, time1::Real)
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
        sort!(src_objects, by=comparator)

        new_len = div(length(src_objects), 2)

        left = bvh_node(@view(src_objects[begin:new_len]), time0, time1)
        right = bvh_node(@view(src_objects[new_len+1:end]), time0, time1)
    end

    hit_left, bbox_left = bounding_box(left, time0, time1)
    hit_right, bbox_right = bounding_box(right, time0, time1)

    (!hit_left || !hit_right) && throw(ArgumentError("No bounding box in bvh constructor."))

    bbox = surrounding_box(bbox_left, bbox_right)
    return bvh_node(left, right, bbox)
end

bounding_box(bvh::bvh_node, ::Real, ::Real) = return true, bvh.box

function hit(bvh::bvh_node, r::ray, t_min::Real, t_max::Real)
    !hit(bvh.box, r, t_min, t_max) && return false, hit_record()

    hit_left, rec_left = hit(bvh.left, r, t_min, t_max)
    hit_right, rec_right = hit(bvh.right, r, t_min, hit_left ? rec_left.t : t_max)

    return hit_left ? (hit_left, rec_left) : hit_right ? (hit_right, rec_right) : (false, hit_record)
end
