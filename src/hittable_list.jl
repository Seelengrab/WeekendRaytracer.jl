struct hittable_list <: hittable
    objects::Dict{DataType, Union{bvh, Vector{<:hittable}}}
end
hittable_list() = hittable_list(Dict{DataType, Union{bvh, Vector{<:hittable}}}())
hittable_list(v::T) where T <: hittable = hittable_list(Dict(T => [v]))
hittable_list(v::Vector{T}) where T <: hittable = hittable_list(Dict(T => v))

clear!(list::hittable_list) = empty!(list.objects)
function add!(list::hittable_list, object::T) where T <: hittable
    push!(get!(() -> T[], list.objects, T), object)
end
Base.values(t::hittable_list) = values(t.objects)

function hit(list::hittable_list, r::ray, t_min::Real, t_max::Real)
    hit_anything = false
    closest_so_far = t_max

    local rec = hit_record()
    for obj in values(list.objects)
        got_hit, temp_rec = hit(obj, r, t_min, closest_so_far)
        if got_hit
            hit_anything = true
            closest_so_far = temp_rec.t
            rec = temp_rec
        end
    end

    return hit_anything, rec
end

@inline function hit(list::Vector{T}, r::ray, t_min::Real, t_max::Real)::Tuple{Bool, hit_record} where T <: hittable
    hit_anything = false
    closest_so_far = t_max

    local rec = hit_record()
    for obj in list
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

    local output_box = aabb()
    first_box = true
    for obj in values(hl.objects)
        bounded, temp_box = bounding_box(obj, t0, t1)
        !bounded && return false, output_box
        output_box = first_box ? temp_box : surrounding_box(output_box, temp_box)
        first_box = false
    end

    return true, output_box
end
