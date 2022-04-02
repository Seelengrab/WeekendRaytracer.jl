function ray_color(r::ray, world::hittable)
    rec = Ref(hit_record())
    if hit(world, r, 0, Inf, rec)
        return 0.5 * (rec[].normal + color(1,1,1))
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

    # World
    world = hittable_list()
    add!(world, sphere(point3(0,0,-1), 0.5))
    add!(world, sphere(point3(0,-100.5,-1), 100))

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
            pixel_color = ray_color(r, world)
            write_color(stdout, pixel_color)
        end
    end

    print(stderr, "\nDone.\n")
    print(stderr, "Took ", (now()-start_time), ".\n")
end
