struct camera
    origin::point3
    lower_left_corner::point3
    horizontal::vec3
    vertical::vec3
    u::vec3
    v::vec3
    w::vec3
    lens_radius::Float64
    # shutter open/close time
    _time0::Float64
    _time1::Float64
end

function camera(lookfrom::point3, lookat::point3, vup::vec3, vfov::Float64, aspect_ratio::Float64, aperture::Float64, focus_dist::Float64, _time0::Float64, _time1::Float64)
    theta = deg2rad(vfov)
    h = tan(theta/2)
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    w = unit_vector(lookfrom - lookat)
    u = unit_vector(cross(vup, w))
    v = cross(w, u)

    origin = lookfrom
    horizontal = focus_dist * viewport_width * u
    vertical = focus_dist * viewport_height * v
    lower_left_corner = origin - horizontal/2 - vertical/2 - focus_dist*w

    camera(origin, lower_left_corner, horizontal, vertical, u,v,w,aperture/2, _time0, _time1)
end

function get_ray(c::camera, s::Float64, t::Float64)
    rd = c.lens_radius * rand(InUnitDisk())
    offset = c.u * rd.x + c.v * rd.y
    return ray(c.origin + offset,
               c.lower_left_corner + s*c.horizontal + t*c.vertical - c.origin - offset, rand(BoundedFloat64(c._time0, c._time1)))
end
