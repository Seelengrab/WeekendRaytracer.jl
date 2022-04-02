function main()
    # Image
    image_width = 256
    image_height = 256
    start_time = now()

    # Render
    print(stdout, "P3\n", image_width, ' ', image_height, "\n255\n")

    for j in image_height-1:-1:0
        print(stderr, "\rScanlines remaining: ", j, ' ')
        flush(stderr)
        for i in 0:image_width-1
            pixel_color = color(i / (image_width-1), j / (image_height-1), 0.25)
            write_color(stdout, pixel_color)
        end
    end

    print(stderr, "\nDone.\n")
    print(stderr, "Took ", (now()-start_time), ".\n")
end
