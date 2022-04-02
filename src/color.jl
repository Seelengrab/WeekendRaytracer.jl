function write_color(io::IO, pixel_color::color)
     print(io, trunc(Int, 255.999 * pixel_color.x), ' ',
               trunc(Int, 255.999 * pixel_color.y), ' ',
               trunc(Int, 255.999 * pixel_color.z), '\n')
end
