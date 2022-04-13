struct box <: hittable
    box_min::point3
    box_max::point3
    sides::hittable_list

    function box(p0::point3, p1::point3, mat::material)
        sides = hittable_list()

        add!(sides, xy_rect(p0.x, p1.x, p0.y, p1.y, p1.z, mat))
        add!(sides, xy_rect(p0.x, p1.x, p0.y, p1.y, p0.z, mat))

        add!(sides, xz_rect(p0.x, p1.x, p0.z, p1.z, p1.y, mat))
        add!(sides, xz_rect(p0.x, p1.x, p0.z, p1.z, p0.y, mat))

        add!(sides, yz_rect(p0.y, p1.y, p0.z, p1.z, p1.x, mat))
        add!(sides, yz_rect(p0.y, p1.y, p0.z, p1.z, p0.x, mat))

        return new(p0, p1, sides)
    end
end

function bounding_box(b::box, _::Float64, _::Float64)
    return true, aabb(b.box_min, b.box_max)
end

hit(b::box, r::ray, t_min::Float64, t_max::Float64) = hit(b.sides, r, t_min, t_max)
