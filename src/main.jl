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

function two_spheres()
    objs = sphere[]
    checker = checker_texture_3D(color(0.2,0.3,0.1), color(0.9,0.9,0.9))
    push!(objs, sphere(point3(0,-10,0), 10, lambertian(checker)))
    push!(objs, sphere(point3(0, 10,0), 10, lambertian(checker)))

    return hittable_list(objs)
end

function earth()
    earth_texture = image_texture("assets/earthmap.jpg")
    earth_surface = lambertian(earth_texture)
    globe = sphere(point3(0,0,0), 2, earth_surface)

    return globe
end

function two_perlin_spheres()
    objs = sphere[]
    pertext = turbulent_texture(2)
    marbletext = marble_texture(2)
    push!(objs, sphere(point3(0,-1000,0), 1000, lambertian(pertext)))
    push!(objs, sphere(point3(0,2,0), 2, lambertian(marbletext)))

    return hittable_list(objs)
end

function random_scene()
    spheres = sphere[]
    msphers = moving_sphere[]

    ground_material = lambertian(color(0.5,0.5,0.5))
    checker = checker_texture_3D(color(0.2,0.3,0.1), color(0.9,0.9,0.9))
    push!(spheres, sphere(point3(0,-1000,0), 1000, lambertian(checker)))

    for a in -11:11
        for b in -11:11
            choose_mat = rand(Float64)
            center = point3(a + 0.9*rand(Float64), 0.2, b + 0.9*rand(Float64))

            if length(center - point3(4,0.2,0)) > 0.9
                if choose_mat < 0.8
                    # diffuse
                    albedo = rand(color) * rand(color)
                    center2 = center + vec3(0, rand(BoundedFloat64(0,.5)), 0)
                    sphere_material = lambertian(albedo)
                    push!(msphers, moving_sphere(center, center2, 0.0, 1.0, 0.2, sphere_material))
                elseif choose_mat < 0.95
                    # metal
                    albedo = rand(BoundedVec3(0.5, 1))
                    fuzz = rand(BoundedFloat64(0, 0.5))
                    sphere_material = metal(albedo, fuzz)
                    push!(spheres, sphere(center, 0.2, sphere_material))
                else
                    # glass
                    sphere_material = dielectric(1.5)
                    push!(spheres, sphere(center, 0.2, sphere_material))
                end
            end
        end
    end

    material1 = dielectric(1.5)
    push!(spheres, sphere(point3(0,1,0), 1.0, material1))

    material2 = lambertian(color(0.4,0.2,0.1))
    push!(spheres, sphere(point3(-4,1,0), 1.0, material2))

    material3 = metal(color(0.7,0.6,0.5), 0.0)
    push!(spheres, sphere(point3(4,1,0), 1.0, material3))

    return hittable_list(Dict(sphere => spheres, moving_sphere => msphers))
end

function render!(buffer, world, cam, max_depth, samples_per_pixel)
    image_height, image_width = size(buffer)
    Threads.@threads :static for i in 1:image_width
        print(stderr, "\rScanlines remaining: ", (image_width - i))
        flush(stderr)
        for j in 1:image_height
            pixel_color = color(0.0, 0.0, 0.0)
            for _ in 1:samples_per_pixel
                u = (i + rand(Float64)) / (image_width - 1)
                v = (j + rand(Float64)) / (image_height - 1)
                r = get_ray(cam, u, v)
                pixel_color += ray_color(r, world, max_depth)
            end
            @inbounds buffer[image_height-j+1, i] = pixel_color
        end
    end
end

function main(file_out)
    # Image
    aspect_ratio = 16 / 9
    image_width = 400
    image_height = trunc(Int, image_width / aspect_ratio)
    samples_per_pixel = 50
    max_depth = 16

    # World
    println(stderr, "Starting world generation..")
    worldgen = now()
    vfov = 40.0
    aperture = 0.0

    scene = 0
    if scene == 1
        world = random_scene()
        lookfrom = point3(13,2,3)
        lookat = point3(0,0,0)
        vfov = 20.0
        aperture = 0.1
    elseif scene == 2
        world = two_spheres()
        lookfrom = point3(13,2,3)
        lookat = point3(0,0,0)
        vfov = 20.0
    elseif scene == 3
        world = two_perlin_spheres()
        lookfrom = point3(13,2,3)
        lookat = point3(0,0,0)
        vfov = 20.0
    elseif scene == 4
        world = earth()
        lookfrom = point3(13,2,3)
        lookat = point3(0.0,0.0,0.0)
        vfov = 20.0
    end
    println(stderr, "World generation took ", now() - worldgen, '.')

    # Camera
    vup = vec3(0,1,0)
    dist_to_focus = 10.0
    cam = camera(lookfrom, lookat, vup, vfov, aspect_ratio, aperture, dist_to_focus, 0.0, 1.0)

    # Render
    output = Matrix{vec3}(undef, image_height, image_width)
    println(stderr, "Starting renderer with $(Threads.nthreads()) threads..")
    start_time = now()

    render!(output, world, cam, max_depth, samples_per_pixel
)
    render_time = now()

    println(stderr, "\nSaving file to '", file_out, '\'')
    FileIO.save(file_out, map(v -> get_rgb(v, samples_per_pixel), output))

    print(stderr, "Took ", (render_time - start_time), " to render and ", (now() - render_time), " to save.\n")
end
