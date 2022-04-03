function ray_color(r::ray, world::hittable, depth::Int)
    # stop infinite recursion
    if depth <= 0
        return color(0,0,0)
    end

    got_hit, rec = hit(world, r, 0.001, Inf)
    if got_hit
        scat, scattered, attenuation = scatter(rec.mat, r, rec)
        if scat
            return attenuation * ray_color(scattered, world, depth-1)
        end
        return color(0,0,0)
    end

    unit_direction = unit_vector(direction(r))
    t = 0.5*(unit_direction.y + 1.0)
    return (1.0-t)*color(1.0, 1.0, 1.0) + t*color(0.5, 0.7, 1.0)
end

function main(io_out=stdout)
    # Image
    aspect_ratio = 16 / 9
    image_width = 400
    image_height = trunc(Int, image_width / aspect_ratio)
    samples_per_pixel = 100
    max_depth = 50

    # World
    world = hittable_list()

    material_ground = lambertian(color(0.8,0.8,0.0))
    material_center = lambertian(color(0.1,0.2,0.5))
    material_left = dielectric(1.5)
    material_right = metal(color(0.8,0.6,0.2), 0.0)

    add!(world, sphere(point3( 0.0, -100.5, -1.0), 100.0, material_ground))
    add!(world, sphere(point3( 0.0,    0.0, -1.0),   0.5, material_center))
    add!(world, sphere(point3(-1.0,    0.0, -1.0),   0.5, material_left))
    add!(world, sphere(point3(-1.0,    0.0, -1.0), -0.45, material_left))
    add!(world, sphere(point3( 1.0,    0.0, -1.0),   0.5, material_right))

    # Camera
    lookfrom = point3(3,3,2)
    lookat =point3(0,0,-1)
    vup = vec3(0,1,0)
    dist_to_focus = length((lookfrom - lookat))
    aperture = 2.0
    cam = camera(lookfrom, lookat, vup, 20.0, aspect_ratio, aperture, dist_to_focus)

    # Render
    start_time = now()
    print(io_out, "P3\n", image_width, ' ', image_height, "\n255\n")

    for j in image_height-1:-1:0
        print(stderr, "\rScanlines remaining: ", j, ' ')
        flush(stderr)
        for i in 0:image_width-1
            pixel_color = color(0,0,0)
            for _ in 0:samples_per_pixel
                u = (i + rand(Float64)) / (image_width-1)
                v = (j + rand(Float64)) / (image_height-1)
                r = get_ray(cam, u, v)
                pixel_color += ray_color(r, world, max_depth)
            end
            write_color(io_out, pixel_color, samples_per_pixel)
        end
    end

    print(stderr, "\nDone.\n")
    print(stderr, "Took ", (now()-start_time), ".\n")
end
