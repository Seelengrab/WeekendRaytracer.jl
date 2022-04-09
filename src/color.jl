function write_color(io::IO, pixel_color::color, samples_per_pixel::Int)
    r = pixel_color.x
    g = pixel_color.y
    b = pixel_color.z

    scale = 1.0 / samples_per_pixel
    r = sqrt(scale * r) * !isnan(r)
    g = sqrt(scale * g) * !isnan(g)
    b = sqrt(scale * b) * !isnan(b)

    print(io, unsafe_trunc(Int, 256.0 * clamp(r, 0.0, 0.999)), ' ',
              unsafe_trunc(Int, 256.0 * clamp(g, 0.0, 0.999)), ' ',
              unsafe_trunc(Int, 256.0 * clamp(b, 0.0, 0.999)), '\n')
end
