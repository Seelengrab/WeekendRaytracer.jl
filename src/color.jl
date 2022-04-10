function get_rgb(pixel_color::color, samples_per_pixel::Int)
    r = pixel_color.x
    g = pixel_color.y
    b = pixel_color.z

    scale = 1.0 / samples_per_pixel
    r = sqrt(scale * r) * !isnan(r)
    g = sqrt(scale * g) * !isnan(g)
    b = sqrt(scale * b) * !isnan(b)

    ColorTypes.RGB{N0f8}(clamp(r, 0.0, 1.0),
                         clamp(g, 0.0, 1.0),
                         clamp(b, 0.0, 1.0))
end
