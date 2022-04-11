function ray_color(r::ray, background::color, world::hittable, depth::Int)
    # stop infinite recursion
    if depth <= 0
        return color(0, 0, 0)
    end

    got_hit, rec = hit(world, r, 1e-4, Inf)::Tuple{Bool, hit_record}
    !got_hit && return background

    emitted_col = emitted(rec.mat, rec.u, rec.v, rec.p)

    scat, scattered, attenuation = scatter(rec.mat, r, rec)
    !scat && return emitted_col

    return emitted_col + attenuation * ray_color(scattered, background, world, depth - 1)
end

function two_spheres()
    objs = sphere[]
    checker = checker_texture_3D(color(0.2, 0.3, 0.1), color(0.9, 0.9, 0.9))
    push!(objs, sphere(point3(0, -10, 0), 10, lambertian(checker)))
    push!(objs, sphere(point3(0, 10, 0), 10, lambertian(checker)))

    return bvh(objs, 0.0, 1.0)
end

function earth()
    earth_texture = image_texture("assets/earthmap.jpg")
    earth_surface = lambertian(earth_texture)
    globe = sphere(point3(0, 0, 0), 2, earth_surface)

    return globe
end

function two_perlin_spheres()
    objs = sphere[]
    pertext = turbulent_texture(2)
    marbletext = marble_texture(2)
    push!(objs, sphere(point3(0, -1000, 0), 1000, lambertian(pertext)))
    push!(objs, sphere(point3(0, 2, 0), 2, lambertian(marbletext)))

    return bvh(objs, 0.0, 1.0)
end

function a_few_spheres()
    objs = sphere[ sphere(point3(0,0,-10+i), 1, lambertian(solid_color(rand(BoundedVec3(0.0,1.0))))) for i in 1:2:20 ]

    return bvh(objs, 0.0, 1.0)
end

function random_scene()
    spheres = sphere[]
    mspheres = moving_sphere[]

    earth_texture = image_texture("assets/earthmap.jpg")
    earth_surface = lambertian(earth_texture)
    checker = checker_texture_3D(color(0.2, 0.3, 0.1), color(0.9, 0.9, 0.9))
    push!(spheres, sphere(point3(0, -1000, 0), 1000, lambertian(checker)))

    for a in -11:11
        for b in -11:11
            choose_mat = rand(Float64)
            center = point3(a + 0.9 * rand(Float64), 0.2, b + 0.9 * rand(Float64))

            if length(center - point3(4, 0.2, 0)) > 0.9
                if choose_mat < 0.8
                    # diffuse
                    albedo = rand(color) * rand(color)
                    center2 = center + vec3(0, rand(BoundedFloat64(0, 0.5)), 0)
                    push!(mspheres, moving_sphere(center, center2, 0.0, 1.0, 0.2, lambertian(albedo)))
                elseif choose_mat < 0.95
                    # metal
                    albedo = rand(BoundedVec3(0.5, 1))
                    fuzz = rand(BoundedFloat64(0, 0.5))
                    push!(spheres, sphere(center, 0.2, metal(albedo, fuzz)))
                else
                    # glass
                    push!(spheres, sphere(center, 0.2, dielectric(1.5)))
                end
            end
        end
    end

    material1 = dielectric(1.5)
    push!(spheres, sphere(point3(0, 1, 0), 1.0, material1))

    material2 = earth_surface
    push!(spheres, sphere(point3(-4, 1, 0), 1.0, material2))

    material3 = metal(color(0.7, 0.6, 0.5), 0.0)
    push!(spheres, sphere(point3(4, 1, 0), 1.0, material3))

    return hittable_list(Dict(sphere => bvh(spheres, 0.0, 1.0), moving_sphere => bvh(mspheres, 0.0, 1.0)))
end

function random_scene_homogenous()
    world = sphere[]

    ground_material = lambertian(color(0.5,0.5,0.5))
    push!(world, sphere(point3(0,-1000,0), 1000, ground_material))

    for a in -11:11
        for b in -11:11
            choose_mat = rand(Float64)
            center = point3(a + 0.9*rand(Float64), 0.2, b + 0.9*rand(Float64))

            if length(center - point3(4,0.2,0)) > 0.9
                if choose_mat < 0.8
                    # diffuse
                    albedo = rand(color) * rand(color)
                    sphere_material = lambertian(albedo)
                    push!(world, sphere(center, 0.2, sphere_material))
                elseif choose_mat < 0.95
                    # metal
                    albedo = rand(BoundedVec3(0.5, 1))
                    fuzz = rand(BoundedFloat64(0, 0.5))
                    sphere_material = metal(albedo, fuzz)
                    push!(world, sphere(center, 0.2, sphere_material))
                else
                    # glass
                    sphere_material = dielectric(1.5)
                    push!(world, sphere(center, 0.2, sphere_material))
                end
            end
        end
    end

    material1 = dielectric(1.5)
    push!(world, sphere(point3(0,1,0), 1.0, material1))

    material2 = lambertian(color(0.4,0.2,0.1))
    push!(world, sphere(point3(-4,1,0), 1.0, material2))

    material3 = metal(color(0.7,0.6,0.5), 0.0)
    push!(world, sphere(point3(4,1,0), 1.0, material3))

    return bvh(world)
end

function simple_light()
    objects = sphere[]

    pertext = lambertian(marble_texture(4))
    difflight = diffuse_light(color(0,0,8))
    reclight = diffuse_light(color(8,2,3))

    push!(objects, sphere(point3(0,-1000,0), 1000, pertext))
    glass = dielectric(1.5)
    push!(objects, sphere(point3(0,2,0), 2, glass))
    push!(objects, sphere(point3(0,7,0), 2, difflight))

    rec = xy_rect(3,5,1,3,-2, reclight)

    return hittable_list(Dict(sphere => objects, xy_rect => [rec]))
end

function render!(buffer, world, cam, max_depth, samples_per_pixel, background)
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
                pixel_color += ray_color(r, background, world, max_depth)
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
    samples_per_pixel = 32
    max_depth = 50

    # World
    println(stderr, "Starting world generation..")
    worldgen = now()
    vfov = 40.0
    aperture = 0.0
    background = color(0,0,0)

    scene = 0
    if scene == 1
        world = random_scene()
        background = color(0.7, 0.8, 1.0)
        lookfrom = point3(13, 2, 3)
        lookat = point3(0, 0, 0)
        vfov = 20.0
        aperture = 0.1
    elseif scene == 2
        world = two_spheres()
        background = color(0.7, 0.8, 1.0)
        lookfrom = point3(13, 2, 3)
        lookat = point3(0, 0, 0)
        vfov = 20.0
    elseif scene == 3
        world = two_perlin_spheres()
        background = color(0.7, 0.8, 1.0)
        lookfrom = point3(13, 2, 3)
        lookat = point3(0, 0, 0)
        vfov = 20.0
    elseif scene == 4
        world = earth()
        background = color(0.7, 0.8, 1.0)
        lookfrom = point3(13, 2, 3)
        lookat = point3(0.0, 0.0, 0.0)
        vfov = 20.0
    elseif scene == 5
        world = a_few_spheres()
        background = color(0.7, 0.8, 1.0)
        lookfrom = point3(33, 0, 0)
        lookat = point3(0.0, 0.0, 0.0)
        vfov = 20.0
    elseif scene == 6
        world = random_scene_homogenous()
        background = color(0.7, 0.8, 1.0)
        lookfrom = point3(13, 2, 3)
        lookat = point3(0, 0, 0)
        vfov = 20.0
        aperture = 0.1
    else
        world = simple_light()
        samples_per_pixel = 400
        background = color(0,0,0)
        lookfrom = point3(26,3,6)
        lookat = point3(0,2,0)
        vfov = 20.0
    end
    println(stderr, "World generation took ", now() - worldgen, '.')

    # Camera
    vup = vec3(0, 1, 0)
    dist_to_focus = 10.0
    cam = camera(lookfrom, lookat, vup, vfov, aspect_ratio, aperture, dist_to_focus, 0.0, 1.0)

    # Render
    output = Matrix{vec3}(undef, image_height, image_width)
    println(stderr, "Starting renderer with $(Threads.nthreads()) threads..")
    start_time = now()

    render!(output, world, cam, max_depth, samples_per_pixel, background)
    render_time = now()

    println(stderr, "\nSaving file to '", file_out, '\'')
    FileIO.save(file_out, map(v -> get_rgb(v, samples_per_pixel), output))

    print(stderr, "Took ", (render_time - start_time), " to render and ", (now() - render_time), " to save.\n")
end
