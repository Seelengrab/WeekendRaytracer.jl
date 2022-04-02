function hit_sphere(center::point3, radius::Float64, r::ray)
    oc = origin(r) - center
    a = length²(direction(r))
    half_b = dot(oc, direction(r))
    c = length²(oc) - radius*radius
    discriminant = half_b*half_b - a*c

    if discriminant < 0
        return -1.0
    else
        return (-half_b - sqrt(discriminant)) / a
    end
end

function ray_color(r::ray)
    t = hit_sphere(point3(0,0,-1), 0.5, r)
    if t > 0.0
        N = unit_vector(at(r, t) - vec3(0,0,-1))
        return 0.5 * color(N.x+1, N.y+1, N.z+1)
    end
    unit_direction = unit_vector(direction(r))
    t = 0.5*(unit_direction.y + 1.0)
    return (1.0-t)*color(1.0, 1.0, 1.0) + t*color(0.5, 0.7, 1.0)
end

function main()
    # Image
    aspect_ratio = 16 / 9
    image_width = 400
    image_height = trunc(Int, image_width / aspect_ratio)
    start_time = now()

    # Camera
    viewport_height = 2.0
    viewport_width = aspect_ratio * viewport_height
    focal_length = 1.0

    origin = point3(0,0,0)
    horizontal = vec3(viewport_width,0,0)
    vertical = vec3(0,viewport_height,0)
    lower_left_corner = origin - horizontal/2 - vertical/2 - vec3(0,0,focal_length)

    # Render
    print(stdout, "P3\n", image_width, ' ', image_height, "\n255\n")

    for j in image_height-1:-1:0
        print(stderr, "\rScanlines remaining: ", j, ' ')
        flush(stderr)
        for i in 0:image_width-1
            u = i / (image_width-1)
            v = j / (image_height-1)
            r = ray(origin, lower_left_corner + u*horizontal + v*vertical - origin)
            pixel_color = ray_color(r)
            write_color(stdout, pixel_color)
        end
    end

    print(stderr, "\nDone.\n")
    print(stderr, "Took ", (now()-start_time), ".\n")
end
