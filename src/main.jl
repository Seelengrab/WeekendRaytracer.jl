function main()
    # Image
    image_width = 256
    image_height = 256

    # Render
    print(stdout, "P3\n", image_width, ' ', image_height, "\n255\n")

    for j in image_height-1:-1:0
        for i in 0:image_width-1
            r = i / (image_width-1)
            g = j / (image_height-1)
            b = 0.25

            ir = round(Int, 255.999 * r)
            ig = round(Int, 255.999 * g)
            ib = round(Int, 255.999 * b)

            print(stdout, ir, ' ', ig, ' ', ib, '\n')
        end
    end
end
