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
    reclight = diffuse_light(color(4,4,4))

    push!(objects, sphere(point3(0,-1000,0), 1000, pertext))
    glass = dielectric(1.5)
    push!(objects, sphere(point3(0,2,0), 2, pertext))
    #push!(objects, sphere(point3(0,7,0), 2, reclight))

    rec = xy_rect(3,5,1,3,-2, reclight)

    return hittable_list(Dict(sphere => objects, xy_rect => [rec]))
end

function cornell_box()
    list = hittable_list()

    red = lambertian(color(.65,.05,.05))
    white = lambertian(color(.73,.73,.73))
    green = lambertian(color(.12,.45,.15))
    light = diffuse_light(color(15,15,15))

    add!(list, yz_rect(0,555,0,555,555, green))
    add!(list, yz_rect(0,555,0,555,0, red))
    add!(list, xz_rect(213,343,227,332,554, light))
    add!(list, xz_rect(0,555,0,555,0, white))
    add!(list, xz_rect(0,555,0,555,555, white))
    add!(list, xy_rect(0,555,0,555,555, white))

    box1 = box(point3(0,0,0), point3(165, 330, 165), white)
    box1 = y_rotate(box1, 15.0)
    box1 = translate(box1, vec3(256,0,295))
    add!(list, box1)

    box2 = box(point3(0,0,0), point3(165, 165, 165), white)
    box2 = y_rotate(box2, -18.0)
    box2 = translate(box2, vec3(130,0,65))
    add!(list, box2)

    return list
end

function cornell_smoke()
    list = hittable_list()

    red = lambertian(color(.65,.05,.05))
    white = lambertian(color(.73,.73,.73))
    green = lambertian(color(.12,.45,.15))
    light = diffuse_light(color(7,7,7))

    add!(list, yz_rect(0,555,0,555,555, green))
    add!(list, yz_rect(0,555,0,555,0, red))
    add!(list, xz_rect(113,443,127,432,554, light))
    add!(list, xz_rect(0,555,0,555,0, white))
    add!(list, xz_rect(0,555,0,555,555, white))
    add!(list, xy_rect(0,555,0,555,555, white))

    box1 = box(point3(0,0,0), point3(165, 330, 165), white)
    box1 = y_rotate(box1, 15.0)
    box1 = translate(box1, vec3(256,0,295))
    add!(list, constant_medium(box1, 0.01, color(0,0,0)))

    box2 = box(point3(0,0,0), point3(165, 165, 165), white)
    box2 = y_rotate(box2, -18.0)
    box2 = translate(box2, vec3(130,0,65))
    add!(list, constant_medium(box2, 0.01, color(1,1,1)))

    return list
end

function final_scene()
    boxes1 = box[]

    ground = lambertian(color(0.48,0.83,0.53))

    boxes_per_side = 20
    for i in 0:boxes_per_side-1, j in 0:boxes_per_side-1
        w = 100.0
        x0 = -1000.0 + i*w
        z0 = -1000.0 + j*w
        y0 = 0.0
        x1 = x0 + w
        y1 = rand(BoundedFloat64(1.0,101.0))
        z1 = z0 + w

        push!(boxes1, box(point3(x0,y0,z0), point3(x1,y1,z1), ground))
    end

    objects = hittable_list()

    add!(objects, bvh(boxes1, 0.0, 1.0))

    light = diffuse_light(color(7,7,7))
    add!(objects, xz_rect(123,423,147,412,554, light))

    center1 = point3(400,400,200)
    center2 = center1 + vec3(30,0,0)

    moving_sphere_material = lambertian(color(0.7,0.3,0.1))
    add!(objects, moving_sphere(center1, center2, 0.0, 1.0, 50.0, moving_sphere_material))

    add!(objects, sphere(point3(260, 150, 45), 50.0, dielectric(1.5)))
    add!(objects, sphere(point3(0.0,150.0,145.0), 50.0, metal(color(0.8,0.8,0.9), 1.0)))

    boundary = sphere(point3(360,150,145), 70, dielectric(1.5))
    add!(objects, boundary)
    add!(objects, constant_medium(boundary, 0.2, color(0.2,0.4,0.9)))
    boundary =sphere(point3(0,0,0), 5000, dielectric(1.5))
    add!(objects, constant_medium(boundary, 0.0001, color(1,1,1)))

    emat = lambertian(image_texture("assets/earthmap.jpg"))
    add!(objects, sphere(point3(400,200,400), 100, emat))
    pertext = noise_texture(0.1)
    add!(objects, sphere(point3(220,280,300), 80, lambertian(pertext)))

    boxes2 = sphere[]
    white = lambertian(color(0.73,0.73,0.73))
    ns = 1000
    for _ in 1:ns
        push!(boxes2, sphere(rand(BoundedVec3(0,165)), 10, white))
    end

    add!(objects, translate(
        y_rotate(bvh(boxes2, 0.0, 1.0), 15.0),
        vec3(-100, 270, 395)))

    return objects
end

function render!(buffer, world, cam, max_depth, samples_per_pixel, background)
    image_height, image_width = size(buffer)
    Threads.@threads :dynamic for i in 1:image_width
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
    samples_per_pixel = 200
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
    elseif scene == 7
        world = simple_light()
        samples_per_pixel = 400
        background = color(0,0,0)
        lookfrom = point3(26,3,6)
        lookat = point3(0,2,0)
        vfov = 20.0
    elseif scene == 8
        world = cornell_box()
        aspect_ratio = 1.0
        image_width = 600
        samples_per_pixel = 200
        background = color(0,0,0)
        lookfrom = point3(278,278,-800)
        lookat = point3(278,278,0)
        vfov = 40.0
    elseif scene == 9
        world = cornell_smoke()
        aspect_ratio = 1.0
        image_width = 600
        samples_per_pixel = 200
        background = color(0,0,0)
        lookfrom = point3(278,278,-800)
        lookat = point3(278,278,0)
        vfov = 40.0
    else
        world = final_scene()
        aspect_ratio = 1.0
        image_width = 800
        samples_per_pixel = 10000
        background = color(0,0,0)
        lookfrom = point3(478,278, -600)
        lookat = point3(278, 278, 0)
        vfov = 40.0
    end
    println(stderr, "World generation took ", now() - worldgen, '.')

    # Camera
    vup = vec3(0, 1, 0)
    dist_to_focus = 10.0
    image_height = trunc(Int, image_width / aspect_ratio)
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
