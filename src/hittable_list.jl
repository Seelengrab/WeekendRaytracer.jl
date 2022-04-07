struct hittable_list <: hittable
    objects::Dict{Type{<:hittable},Vector{<:hittable}}
end
hittable_list() = hittable_list(Dict{Type{<:hittable},Vector{<:hittable}}())

clear!(list::hittable_list) = empty!(list.objects)
function add!(list::hittable_list, object::T) where T <: hittable
    push!(get!(list.objects, T, T[]), object)
end
Base.values(t::hittable_list) = values(t.objects)

function hit(list::hittable_list, r::ray, t_min::Real, t_max::Real)
    hit_anything = false
    closest_so_far = t_max

    local rec = hit_record()
    for obj in values(list)
        got_hit, temp_rec = hit(obj, r, t_min, closest_so_far)
        if got_hit
            hit_anything = true
            closest_so_far = temp_rec.t
            rec = temp_rec
        end
    end

    return hit_anything, rec
end

function hit(list::Vector{T}, r::ray, t_min::Real, t_max::Real) where T <: hittable
    hit_anything = false
    closest_so_far = t_max

    local rec = hit_record()
    for obj in values(list)
        got_hit, temp_rec = hit(obj, r, t_min, closest_so_far)
        if got_hit
            hit_anything = true
            closest_so_far = temp_rec.t
            rec = temp_rec
        end
    end

    return hit_anything, rec
end

function bounding_box(hl::hittable_list, t0::Real, t1::Real)
    isempty(hl) && return false, aabb()

    local temp_box = aabb()
    first_box = true
    for list in values(hl)
        for el in list
            bounded, box = bounding_box(el, t0, t1)
            !bounded && return false, aabb()
            output_box = first_box ? temp_box : surrounding_box(temp_box, box)
            first_box = false
        end
    end

    return true, temp_box
end
