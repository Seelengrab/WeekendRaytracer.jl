struct camera
    origin::point3
    lower_left_corner::point3
    horizontal::vec3
    vertical::vec3
end

function camera(vfov::Float64, aspect_ratio::Float64)
    theta = deg2rad(vfov)
    h = tan(theta/2)
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    focal_length = 1.0

    origin = point3(0,0,0)
    horizontal = vec3(viewport_width,0,0)
    vertical = vec3(0,viewport_height,0)
    lower_left_corner = origin - horizontal/2 - vertical/2 - vec3(0,0,focal_length)

    camera(origin, lower_left_corner, horizontal, vertical)
end

function get_ray(c::camera, u::Float64, v::Float64)
    return ray(c.origin, c.lower_left_corner + u*c.horizontal + v*c.vertical - c.origin)
end
