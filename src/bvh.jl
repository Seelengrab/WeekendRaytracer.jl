struct bvh_node <: hittable
    left::hittable
    right::hittable
    box::aabb
end

bounding_box(bvh::bvh_node, ::Real, ::Real) = return true, bvh.box

function hit(bvh::bvh_node, r::ray, t_min::Real, t_max::Real)
    !hit(bvh.box, r, t_min, t_max) && return false, hit_record()

    hit_left, rec_left = hit(bvh.left, r, t_min, t_max)
    hit_right, rec_right = hit(bvh.right, r, t_min, hit_left ? rec_left.t : t_max)

    return hit_left ? (hit_left, rec_left) : hit_right ? (hit_right, rec_right) : (false, hit_record)
end
