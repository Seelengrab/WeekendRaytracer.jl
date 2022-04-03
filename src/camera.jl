struct camera
    origin::point3
    lower_left_corner::point3
    horizontal::vec3
    vertical::vec3
end

function camera(lookfrom::point3, lookat::point3, vup::vec3, vfov::Float64, aspect_ratio::Float64)
    theta = deg2rad(vfov)
    h = tan(theta/2)
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    w = unit_vector(lookfrom - lookat)
    u = unit_vector(cross(vup, w))
    v = cross(w, u)

    origin = lookfrom
    horizontal = viewport_width * u
    vertical = viewport_height * v
    lower_left_corner = origin - horizontal/2 - vertical/2 - w

    camera(origin, lower_left_corner, horizontal, vertical)
end

function get_ray(c::camera, s::Float64, t::Float64)
    return ray(c.origin, c.lower_left_corner + s*c.horizontal + t*c.vertical - c.origin)
end
