function write_color(io::IO, pixel_color::color, samples_per_pixel::Int)
    r = pixel_color.x
    g = pixel_color.y
    b = pixel_color.z

    scale = 1.0 / samples_per_pixel
    r *= scale
    g *= scale
    b *= scale

    print(io, trunc(Int, 256 * clamp(r, 0.0, 0.999)), ' ',
              trunc(Int, 256 * clamp(g, 0.0, 0.999)), ' ',
              trunc(Int, 256 * clamp(b, 0.0, 0.999)), '\n')
end
