struct constant_medium{B,M} <: hittable
    boundary::B
    phase_function::M
    neg_inv_density::Float64
end
constant_medium(b::hittable, d::Float64, a::Union{texture, vec3}) = constant_medium(b, isotropic(a), -1.0/d)

function bounding_box(cm::constant_medium, time0::Float64, time1::Float64)
    return bounding_box(cm.boundary, time0, time1)
end

function hit(cm::constant_medium, r::ray, t_min::Float64, t_max::Float64)
    inb, rec1 = hit(cm.boundary, r, -Inf, Inf)
    !inb && return false, hit_record()

    inb, rec2 = hit(cm.boundary, r, rec1.t+0.0001, Inf)
    !inb && return false, hit_record()

    rec1_t = max(rec1.t, t_min)
    rec2_t = min(rec2.t, t_max)

    rec1_t >= rec2_t && return false, hit_record()

    rec1_t = max(rec1_t, 0.0)

    ray_length = r |> direction |> length
    distance_inside_boundary = (rec2_t - rec1_t) * ray_length
    hit_distance = cm.neg_inv_density * log(rand(Float64))

    hit_distance > distance_inside_boundary && return false, hit_record()

    rec_t = rec1_t + hit_distance / ray_length
    rec_p = at(r, rec_t)

    if rand(Float64) < 0.00001
        @debug "hit(constant_medium)" hit_distance rec_t rec_p
    end

    ret = hit_record(
        rec_p,
        vec3(1,0,0),
        cm.phase_function,
        rec_t, 0.0, 0.0, true)

    return true, ret
end
