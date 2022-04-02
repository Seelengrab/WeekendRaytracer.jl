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
    samples_per_pixel = 100

    # World
    world = hittable_list()
    add!(world, sphere(point3(0,0,-1), 0.5))
    add!(world, sphere(point3(0,-100.5,-1), 100))

    start_time = now()
    # Camera
    cam = camera()

    # Render
    print(stdout, "P3\n", image_width, ' ', image_height, "\n255\n")

    for j in image_height-1:-1:0
        print(stderr, "\rScanlines remaining: ", j, ' ')
        flush(stderr)
        for i in 0:image_width-1
            pixel_color = color(0,0,0)
            for _ in 0:samples_per_pixel
                u = (i + rand(Float64)) / (image_width-1)
                v = (j + rand(Float64)) / (image_height-1)
                r = get_ray(cam, u, v)
                pixel_color += ray_color(r, world)
            end
            write_color(stdout, pixel_color, samples_per_pixel)
        end
    end

    print(stderr, "\nDone.\n")
    print(stderr, "Took ", (now()-start_time), ".\n")
end
