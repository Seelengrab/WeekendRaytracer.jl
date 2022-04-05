function ray_color(r::ray, world::hittable, depth::Int)
    # stop infinite recursion
    if depth <= 0
        return color(0,0,0)
    end

    got_hit, rec = hit(world, r, 1e-4, Inf)
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

function random_scene()
    world = hittable_list()

    ground_material = lambertian(color(0.5,0.5,0.5))
    add!(world, sphere(point3(0,-1000,0), 1000, ground_material))

    for a in -11:11
        for b in -11:11
            choose_mat = rand(Float64)
            center = point3(a + 0.9*rand(Float64), 0.2, b + 0.9*rand(Float64))

            if length(center - point3(4,0.2,0)) > 0.9
                if choose_mat < 0.8
                    # diffuse
                    albedo = rand(color) * rand(color)
                    sphere_material = lambertian(albedo)
                    add!(world, sphere(center, 0.2, sphere_material))
                elseif choose_mat < 0.95
                    # metal
                    albedo = rand(BoundedVec3(0.5, 1))
                    fuzz = rand(BoundedFloat64(0, 0.5))
                    sphere_material = metal(albedo, fuzz)
                    add!(world, sphere(center, 0.2, sphere_material))
                else
                    # glass
                    sphere_material = dielectric(1.5)
                    add!(world, sphere(center, 0.2, sphere_material))
                end
            end
        end
    end

    material1 = dielectric(1.5)
    add!(world, sphere(point3(0,1,0), 1.0, material1))

    material2 = lambertian(color(0.4,0.2,0.1))
    add!(world, sphere(point3(-4,1,0), 1.0, material2))

    material3 = metal(color(0.7,0.6,0.5), 0.0)
    add!(world, sphere(point3(4,1,0), 1.0, material3))

    return world
end

function main(io_out=stdout)
    # Image
    aspect_ratio = 16 / 9
    image_width = 320
    image_height = trunc(Int, image_width / aspect_ratio)
    samples_per_pixel = 32
    max_depth = 16

    # World
    worldgen = now()
    world = random_scene()
    println(stderr, "World generation took ", now() - worldgen, '.')

    # Camera
    lookfrom = point3(13,2,3)
    lookat = point3(0,0,0)
    vup = vec3(0,1,0)
    dist_to_focus = 10.0
    aperture = 0.1
    cam = camera(lookfrom, lookat, vup, 20.0, aspect_ratio, aperture, dist_to_focus)

    # Render
    output = Matrix{vec3}(undef, image_height, image_width)
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
            output[j+1, i+1] = pixel_color
        end
    end
    render_time = now()

    for r in reverse(axes(output, 1))
        row = @view output[r, :]
        for x in row
            write_color(io_out, x, samples_per_pixel)
        end
    end

    print(stderr, "\nDone.\n")
    print(stderr, "Took ", (render_time - start_time), " to render and ", (now() - render_time), " to save.\n")
end
