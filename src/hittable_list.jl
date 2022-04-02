struct hittable_list <: hittable
    objects::Vector{hittable}
end
hittable_list() = hittable_list(hittable[])

clear!(list::hittable_list) = empty!(list.objects)
add!(list::hittable_list, object::hittable) = push!(list.objects, object)

function hit(list::hittable_list, r::ray, t_min::Real, t_max::Real, rec::Ref{hit_record})
    temp_rec = Ref(hit_record())
    hit_anything = false
    closest_so_far = t_max

    for object in list.objects
        if hit(object, r, t_min, closest_so_far, temp_rec)
            hit_anything = true
            closest_so_far = temp_rec[].t
            rec[] = temp_rec[]
        end
    end

    return hit_anything
end
